# Xget 使用教程（自定义域名 540383401.xyz/xget*）

本教程面向你的已部署实例与本地工程，讲清楚“如何通过你的域名 `540383401.xyz/xget*` 调用 Xget”，以及“如何在本地项目 `/Users/jiajia/Documents/04-技术相关/02-Git仓库/GitHub/Xget` 进行开发与部署”。

- 域名前缀：`https://540383401.xyz/xget`
- 基本规则：在前缀后添加平台前缀，再拼接原平台路径即可
- 示例格式：`https://540383401.xyz/xget/<前缀>/<原路径>`

如果你选择将 Cloudflare Worker 绑定在子路径 `xget*`（而非域名根路径），请务必阅读下文“路径前缀兼容”一节，确保 Worker 能正确处理 `/xget` 前缀。

---

## 快速开始

- 直接访问（示例）：
  - GitHub Release 压缩包：
    `https://540383401.xyz/xget/gh/torvalds/linux/archive/refs/tags/v6.10.zip`
  - Hugging Face 模型文件：
    `https://540383401.xyz/xget/hf/bert-base-uncased/resolve/main/config.json`
  - npm 包 tarball：
    `https://540383401.xyz/xget/npm/lodash/-/lodash-4.17.21.tgz`
  - PyPI simple 索引：
    `https://540383401.xyz/xget/pypi/simple/requests/`
  - Jenkins 插件：
    `https://540383401.xyz/xget/jenkins/download/plugins/git/5.3.0/git.hpi`
  - 容器镜像（GHCR 清单）：
    `https://540383401.xyz/xget/cr/ghcr/v2/homebrew/core/bash/manifests/5.2.26`
  - AI 推理（Gemini API）：
    `https://540383401.xyz/xget/ip/gemini/v1beta/models/gemini-1.5-flash:generateContent`

- 命令行下载：
  - `wget https://540383401.xyz/xget/gh/torvalds/linux/archive/refs/tags/v6.10.zip`
  - `curl -L -O https://540383401.xyz/xget/gh/torvalds/linux/archive/refs/tags/v6.10.zip`
  - `aria2c -x16 https://540383401.xyz/xget/gh/torvalds/linux/archive/refs/tags/v6.10.zip`

---

## URL 规则与平台前缀

Xget 使用“平台前缀 + 平台原始路径”的一站式规则，常用前缀如下（挑选常见场景）：

- 代码仓库：
  - GitHub：`gh`（示例：`/gh/{owner}/{repo}/archive/refs/tags/{tag}.zip`）
  - GitLab：`gl`
  - Codeberg：`codeberg`
  - Gitea：`gitea`
- 模型与数据：
  - Hugging Face：`hf`（文件路径一般为 `/resolve/{branch}/{file}`）
  - arXiv：`arxiv`
- 包管理：
  - npm：`npm`（`/{name}/-/package-{version}.tgz` 或 `/{name}` 元数据）
  - PyPI：`pypi`（`/simple/{package}/` 列表），`pypi/files`（文件直链重写）
  - Maven Central：`maven`（`/org/apache/commons/commons-lang3/3.14.0/commons-lang3-3.14.0.jar`）
  - Homebrew：`homebrew`、`homebrew-api`、`homebrew-bottles`
  - CRAN（R）：`cran`，CPAN（Perl）：`cpan`
  - Packagist（Composer）：`packagist`
- Linux 发行版：
  - Debian：`debian`，Ubuntu：`ubuntu`，Fedora：`fedora`，openSUSE：`opensuse`
- Jenkins 更新中心与插件：`jenkins`
- 容器注册表（Docker/OCI）：
  - GHCR：`cr/ghcr`，GCR：`cr/gcr`，MCR：`cr/mcr`，ECR：`cr/ecr` 等
- AI 推理提供商（统一前缀 `ip/`）：
  - OpenAI：`ip/openai`，Gemini：`ip/gemini`，Hugging Face 路由器：`ip/huggingface`，Groq：`ip/groq` 等

组合方式非常直观：把原始域名替换为你的前缀 `https://540383401.xyz/xget`，并在路径最前面加上平台前缀。

---

## 常用场景示例

### Git 快速下载与配置

- 直接下载：
  - `curl -L -O https://540383401.xyz/xget/gh/torvalds/linux/archive/refs/tags/v6.10.zip`

- Git 全局自动重写（将常见平台自动走你自己的域名）：

```bash
# 将 GitHub 自动改写为你的 Xget 域名
git config --global url."https://540383401.xyz/xget/gh".insteadOf "https://github.com"
# 将 GitLab 自动改写为你的 Xget 域名
git config --global url."https://540383401.xyz/xget/gl".insteadOf "https://gitlab.com"
# 将 SourceForge 自动改写为你的 Xget 域名
git config --global url."https://540383401.xyz/xget/sourceforge".insteadOf "https://sourceforge.net"
# Android AOSP 自动改写
git config --global url."https://540383401.xyz/xget/aosp".insteadOf "https://android.googlesource.com"

# 验证
git config --global --get-regexp url
```

> 提示：Git 操作（clone/push/fetch）由 Worker 按协议透传头与内容类型；私有仓库仍需你的原始凭证。

### 包管理示例

- npm：
```bash
# 获取元数据
curl https://540383401.xyz/xget/npm/lodash
# 下载 tarball
curl -L -O https://540383401.xyz/xget/npm/lodash/-/lodash-4.17.21.tgz
```

- PyPI：
```bash
# Simple 索引浏览
curl https://540383401.xyz/xget/pypi/simple/requests/
# 文件直链（pypi/files 会自动重写原 files.pythonhosted.org 直链）
curl -L -O https://540383401.xyz/xget/pypi/files/packages/source/r/requests/requests-2.32.3.tar.gz
```

- Maven Central：
```bash
curl -L -O \
  https://540383401.xyz/xget/maven/org/apache/commons/commons-lang3/3.14.0/commons-lang3-3.14.0.jar
```

- Homebrew：
```bash
# API
curl https://540383401.xyz/xget/homebrew-api/api/formula.json
# 瓶子（ghcr 容器格式）
curl -I https://540383401.xyz/xget/cr/ghcr/v2/homebrew/core/bash/manifests/5.2.26
```

### Linux 发行版源（示例）

- Ubuntu `sources.list`（示例为 jammy）：
```bash
sudo bash -c 'cat >/etc/apt/sources.list <<EOF
deb https://540383401.xyz/xget/ubuntu jammy main restricted universe multiverse
deb https://540383401.xyz/xget/ubuntu jammy-updates main restricted universe multiverse
EOF'
sudo apt update
```

### Jenkins 插件

```bash
wget https://540383401.xyz/xget/jenkins/download/plugins/git/5.3.0/git.hpi
curl -L -O https://540383401.xyz/xget/jenkins/download/plugins/git/5.3.0/git.hpi
```

### 容器镜像（GHCR 示例）

```bash
# 拉取公开镜像时，Xget 会尝试匿名令牌；私有镜像需凭证
curl -I https://540383401.xyz/xget/cr/ghcr/v2/homebrew/core/bash/manifests/5.2.26
# 结合 Podman 直接使用 Xget 作为镜像源（高级配置可参见原 README）
```

### AI 推理 API（Gemini / OpenAI / Hugging Face 路由器）

```bash
# Gemini（与官方接口一致，仅域名变更）
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $GEMINI_API_KEY" \
  -d '{"contents":[{"parts":[{"text":"Hello"}]}]}' \
  https://540383401.xyz/xget/ip/gemini/v1beta/models/gemini-1.5-flash:generateContent

# OpenAI（chat completions）
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d '{"model":"gpt-4o-mini","messages":[{"role":"user","content":"Hello"}]}' \
  https://540383401.xyz/xget/ip/openai/v1/chat/completions

# Hugging Face 路由器（Inference）
curl https://540383401.xyz/xget/ip/huggingface/models/distilbert-base-uncased
```

---

## 本地开发（你的原始项目路径）

- 路径：`/Users/jiajia/Documents/04-技术相关/02-Git仓库/GitHub/Xget`
- 前置：Node.js 18+、npm、Cloudflare 账号

```bash
cd "/Users/jiajia/Documents/04-技术相关/02-Git仓库/GitHub/Xget"
npm install

# 本地启动（默认监听 http://localhost:8787/ ）
npm run dev

# 运行测试
npm run test:run
# 生成覆盖率
npm run test:coverage
# 代码检查与格式化
npm run lint
npm run format
```

> 本地开发默认在根路径（无 `/xget` 前缀）访问，例如：`http://localhost:8787/gh/...`。

---

## 部署到 Cloudflare Workers（绑定子路径 xget*）

你可以通过 Wrangler 或控制台将 Worker 绑定到你的域名子路径：

- `wrangler.toml` 关键字段（示例）：

```toml
name = "xget"
main = "src/index.js"
compatibility_date = "2024-10-22"
compatibility_flags = ["nodejs_compat"]
workers_dev = false

# 将 Worker 绑定到你的域名子路径
routes = [
  { pattern = "540383401.xyz/xget*", zone_name = "540383401.xyz" }
]

[observability]
enabled = true
head_sampling_rate = 1
[placement]
mode = "smart"
```

- 部署：

```bash
# 登录并部署
wrangler login
npm run deploy
```

部署完成后：
- 自定义路径访问：`https://540383401.xyz/xget/gh/torvalds/linux/archive/refs/tags/v6.10.zip`
- Worker 根域（如启用）：`https://<worker>.<subdomain>.workers.dev/...`

---

## 路径前缀兼容（关键）

当前 Worker 路由解析逻辑默认期望平台前缀位于根路径（如 `/gh/...`、`/gl/...`）。当你把 Worker 绑定到子路径 `/xget*` 时，原始请求路径会是 `/xget/gh/...`，需要在进入路由解析前剥离 `/xget`。

如你使用本仓库的标准代码，请在 `src/index.js` 的请求处理阶段加入前缀剥离（示意）：

```js
// 在解析平台前加入：
const url = new URL(request.url);
let effectivePath = url.pathname;

// 兼容子路径路由：剥离 /xget 前缀
if (effectivePath.startsWith('/xget/')) {
  effectivePath = effectivePath.replace(/^\/xget/, '');
}

// 后续按 effectivePath 继续平台识别与 transform
```

> 如果你的部署是绑定在域名根（`540383401.xyz/*`），则无需上述剥离，直接使用 `/gh/...`、`/hf/...` 等路径即可。

---

## 环境变量与安全

在 Cloudflare 控制台可为 Worker 设置环境变量以定制行为：

- `TIMEOUT_SECONDS`（默认 30）
- `MAX_RETRIES`（默认 3）
- `RETRY_DELAY_MS`（默认 1000）
- `CACHE_DURATION`（默认 1800）
- `ALLOWED_METHODS`（默认 `GET,HEAD`；Git/容器/推理场景自动扩展到 `POST,PUT,PATCH`）
- `ALLOWED_ORIGINS`（默认 `*`；如需限制来源可设置具体域）
- `MAX_PATH_LENGTH`（默认 2048）

安全建议：
- 私有仓库/私有镜像需原平台凭证；Xget 仅透传请求头。
- 对生产域名建议将 `ALLOWED_ORIGINS` 收敛到你的来源域，减少滥用风险。
- 如需“仅自己可用”，建议在 Worker 校验自定义授权头（例如 `Authorization: Bearer <token>` 或 `X-Xget-Key: <secret>`）。配合脚本的 `XGET_AUTH_HEADER`（在本地 `xget.conf` 设置），仅当请求携带正确请求头才放行，否则返回 403。

---

## 常见问题

- 访问没有提速？首次请求可能未命中边缘缓存；相同资源的后续请求会显著提升。
- Git 操作失败？确认已使用正确平台前缀；对于私有仓库，请确保凭证有效。
- 绑定子路径后 302 跳转到 GitHub？通常是未剥离 `/xget` 前缀导致平台识别失败，请参考“路径前缀兼容”。

---

## 结语

现在你可以用自己的域名 `540383401.xyz/xget*` 一站式加速 Git、包管理、镜像与 AI 推理接口。遇到实际问题，优先检查：URL 前缀、平台前缀是否正确、是否已为子路径绑定启用前缀剥离。祝使用顺利！