#!/usr/bin/env bash
set -euo pipefail

# 安全发布脚本：推送前自动取消 git 镜像重写，必要时启用代理；可选恢复镜像。
# 使用：
#   bash ./publish.sh                  # 正常推送（如检测到本地代理则自动使用）
#   RESTORE_MIRROR=1 bash ./publish.sh # 推送后恢复国内镜像重写
# 环境变量：
#   REPO_NAME        仓库名（默认用本地项目目录名）
#   REMOTE_NAME      远程名（默认 origin）
#   ALL_PROXY        若已设置则直接使用该代理；否则尝试 7890/1080

log() { echo "[$(date '+%H:%M:%S')] $*"; }

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

export PATH="$HOME/.local/bin:$PATH"

REPO_NAME=${REPO_NAME:-$(basename "$(git rev-parse --show-toplevel)")}
REMOTE_NAME=${REMOTE_NAME:-origin}
RESTORE=${RESTORE_MIRROR:-0}
BRANCH=$(git rev-parse --abbrev-ref HEAD)

log "publish: repo=$REPO_NAME remote=$REMOTE_NAME branch=$BRANCH"

# 1) 确认 gh 登录
if ! gh auth status >/dev/null 2>&1; then
  log "gh 未登录，尝试浏览器登录..."
  gh auth login --web --git-protocol https --hostname github.com || {
    log "gh 登录失败，请手动执行 gh auth login"; exit 1; }
fi

# 2) 若无 origin 则创建远程（不立即推送）
if ! git remote get-url "$REMOTE_NAME" >/dev/null 2>&1; then
  log "未检测到远程 $REMOTE_NAME，创建 GitHub 仓库 $REPO_NAME..."
  gh repo create "$REPO_NAME" --public --source=. --remote="$REMOTE_NAME" || {
    log "创建远程失败"; exit 1; }
fi

# 3) 推送前取消 git 镜像重写
if [[ -x ./xget ]]; then
  log "推送前取消 git 镜像重写..."
  bash ./xget -c "set_git_mirror unset" || true
else
  log "未找到 xget，跳过镜像取消"
fi

# 4) 代理检测（如未设置 ALL_PROXY）
if [[ -z "${ALL_PROXY:-}" ]]; then
  for p in 7890 1080; do
    log "测试代理 socks5h://127.0.0.1:${p}"
    if ALL_PROXY="socks5h://127.0.0.1:${p}" curl -I -s -o /dev/null --connect-timeout 5 https://github.com/login; then
      export ALL_PROXY="socks5h://127.0.0.1:${p}"
      log "使用代理端口 ${p} 推送"
      break
    fi
  done
fi

# 5) 推送
log "推送到 $REMOTE_NAME/$BRANCH..."
ALL_PROXY="${ALL_PROXY:-}" git push -u "$REMOTE_NAME" "$BRANCH"

# 6) 可选恢复国内镜像重写
if [[ "$RESTORE" == "1" ]]; then
  if [[ -x ./xget ]]; then
    log "推送后恢复国内镜像重写..."
    bash ./xget -c "set_git_mirror cn" || true
  else
    log "未找到 xget，跳过镜像恢复"
  fi
fi

log "发布完成。"
