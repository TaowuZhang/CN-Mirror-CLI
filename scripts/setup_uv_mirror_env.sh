#!/usr/bin/env bash
set -euo pipefail

# 将 UV 安装器的 GitHub 基址设置为你的镜像前缀，
# 使官方命令 `curl -Ls https://astral.sh/uv/install.sh | sh` 也能走镜像。

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
CONF_PATH="${XGET_CONF_PATH:-$ROOT_DIR/xget.conf}"

# 默认值（无 xget.conf 时）
XGET_PREFIX="${XGET_PREFIX:-}"
XGET_PREFIX_MODE="${XGET_PREFIX_MODE:-}"

if [[ -f "$CONF_PATH" ]]; then
  # shellcheck disable=SC1090
  source "$CONF_PATH"
fi

derive_base() {
  local prefix="${XGET_PREFIX:-}"
  local mode="${XGET_PREFIX_MODE:-}"
  if [[ -n "$prefix" ]]; then
    prefix="${prefix%/}"
    if [[ "$mode" == "path" ]]; then
      echo "$prefix/gh"
    else
      # GHProxy 风格：前缀 + 原始 URL
      echo "$prefix/https://github.com"
    fi
  else
    # 无自定义前缀则回退 GHProxy 常用域
    echo "https://mirror.ghproxy.com/https://github.com"
  fi
}

BASE="$(derive_base)"
echo "[setup] UV_INSTALLER_GITHUB_BASE_URL=$BASE"

append_export() {
  local file="$1"
  local line="export UV_INSTALLER_GITHUB_BASE_URL=\"$BASE\""
  if [[ -f "$file" ]]; then
    if ! grep -q "UV_INSTALLER_GITHUB_BASE_URL" "$file"; then
      printf "\n# CN-Mirror-CLI: uv installer mirror base\n%s\n" "$line" >> "$file"
      echo "[setup] appended to $file"
    else
      # 更新为最新值
      sed -i '' "s|^export UV_INSTALLER_GITHUB_BASE_URL=.*$|$line|" "$file" || true
      echo "[setup] updated in $file"
    fi
  else
    printf "# CN-Mirror-CLI: uv installer mirror base\n%s\n" "$line" >> "$file"
    echo "[setup] created $file"
  fi
}

# 写入常用 shell 初始化文件（zsh/bash）
append_export "$HOME/.zshrc"
append_export "$HOME/.bashrc"

echo "[setup] done. Open a new terminal or run: source ~/.zshrc"