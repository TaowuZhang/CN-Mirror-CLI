# CN-Mirror-CLI – GitHub 加速下载与镜像切换工具

> 注：项目已重命名为 CN-Mirror-CLI；命令脚本保持 `xget` 与 `xget-local`。

> 注：项目已重命名为 cnmirror-cli；命令脚本保持 `xget` 与 `xget-local`。

一个轻量的 Bash 脚本，统一处理 GitHub 资源的加速下载、仓库克隆镜像切换、Homebrew 镜像环境变量配置以及 npm registry 切换。支持与 Cloudflare Workers 的 Xget 前缀集成，提供自动测速选择最快代理前缀的能力。

## 特性
- 统一入口：`xget_download`、`xget_clone`、`set_git_mirror`、`set_brew_mirror`、`npm_mirror_*`
- 前缀级联下载：优先使用 `XGET_PREFIX`，再尝试多组 GHProxy，最后回源
- 自动测速：`xget_autoselect` 选择当前最快的代理前缀
- Git 镜像重写：可切换 `gitclone` 或 `ghproxy`，并支持取消
- Homebrew 镜像：设置瓶子域与 Brew/Core Git 仓库的镜像地址（非持久，按会话）
- npm registry 切换：默认使用 `npmmirror`，一键设置和恢复

## 两个版本
- `xget-local`：国内镜像源本地真实使用版本（不依赖 Cloudflare），仅使用 GHProxy 与 gitclone 加速
- `xget`：可发布到 GitHub 的完整版（支持 Xget Cloudflare 前缀、自动测速、多功能）

参考的 Xget 开源项目（用于自建 Cloudflare 前缀，功能更全面）：
- Xget 项目主页：https://github.com/xixu-me/Xget

## 安装与使用
```bash
### 本地版（xget-local）
```bash
chmod +x ./xget-local
./xget-local

# 仅使用国内镜像加速下载/克隆
bash ./xget-local -c 'xget_download https://github.com/cli/cli/releases/download/v2.53.0/gh_2.53.0_macOS_amd64.tar.gz gh.tar.gz'
bash ./xget-local -c 'xget_clone https://github.com/Homebrew/brew.git'
```

### 完整版（xget）
```bash
chmod +x ./xget
./xget

# 通过 -c 执行子命令
bash ./xget -c 'xget_download https://github.com/cli/cli/releases/download/v2.53.0/gh_2.53.0_macOS_amd64.tar.gz gh.tar.gz'
```
```

### 配置文件：`xget.conf`
你可以在同目录创建 `xget.conf` 来设置默认前缀与默认 Homebrew 镜像。例如：
```bash
# 自定义代理前缀（建议为你的 Cloudflare Worker）
export XGET_PREFIX="https://xget.example.workers.dev/"

# 默认 Homebrew 镜像站（tuna|ustc|bfsu）
export XGET_BREW_MIRROR_DEFAULT="bfsu"
```

脚本会在启动时自动加载该文件（如果存在）。也可通过环境变量 `XGET_CONF_PATH` 指定自定义路径。本地版不会使用 `XGET_PREFIX`，仅依赖国内镜像。

### 常用命令示例
```bash
# 1) 加速下载（优先 XGET_PREFIX → GHProxy → 回源）
bash ./xget -c 'xget_download https://github.com/cli/cli/releases/download/v2.53.0/gh_2.53.0_macOS_amd64.tar.gz gh.tar.gz'

# 2) 自动选择最快代理前缀（更新环境变量 XGET_PREFIX）
bash ./xget -c 'xget_autoselect'

# 3) 加速克隆（优先 XGET_PREFIX，否则使用 gitclone 重写）
bash ./xget -c 'xget_clone https://github.com/Homebrew/brew.git'

# 4) 切换 Git 全局镜像重写
bash ./xget -c 'set_git_mirror gitclone'
bash ./xget -c 'set_git_mirror ghproxy'
bash ./xget -c 'set_git_mirror unset'

# 5) 设置 Homebrew 镜像（按会话）
bash ./xget -c 'set_brew_mirror bfsu && show_brew_env'

# 6) 设置 npm registry（默认 npmmirror）
bash ./xget -c 'npm_mirror_set'
bash ./xget -c 'npm_mirror_unset'
```

## 与 Cloudflare Workers 的 Xget 集成（完整版）
如果你部署了自己的 Cloudflare Worker（例如 `https://xget.example.workers.dev/`），可直接作为 `XGET_PREFIX` 使用：
```bash
export XGET_PREFIX="https://xget.example.workers.dev/"
bash ./xget -c 'xget_download https://github.com/user/repo/releases/download/v1.0.0/app.tar.gz app.tar.gz'
```

建议你的 Worker 支持：
- 透传 `Range`、`ETag`/`If-None-Match`，提升大文件断点续传与缓存命中率
- 对 `releases`、`raw`、`gist` 等路径设置合理 TTL，避免缓存过期过短或过长
- 限速与配额管理，保护额度与成本；拒绝代理私有仓库授权请求（安全）

如果需要，我可以提供最小可用的 Worker 模板代码。Xget 的完整实现与技术解析可参考其仓库与文档（见上方链接）。

## 注意事项
- 第三方镜像可能存在稳定性与隐私风险，建议仅用于拉取公开资源，不进行登录、写操作
- 对下载的二进制文件建议校验签名或哈希（`shasum -a 256`）
- Git 全局镜像重写是持久的；Homebrew 镜像设置仅对当前终端会话有效

## 开发与发布
```bash
# 初始化 Git 仓库
git init
git add xget xget.conf README.md
git commit -m "feat: init xget CLI and config"

# 如果安装了 GitHub CLI（gh）且已登录，可以一键创建远程并推送
gh repo create xget --public --source=. --remote=origin --push --confirm

# 若未安装 gh，可在 GitHub 手动创建仓库，然后设置远程并推送
git remote add origin https://github.com/<your-username>/xget.git
git branch -M main
git push -u origin main
```

---
欢迎反馈与讨论：关于代理前缀选择、Cloudflare 部署细节、镜像策略优化等问题我都可以协助完善。
