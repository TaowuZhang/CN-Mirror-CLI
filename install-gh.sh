#!/usr/bin/env bash
set -euo pipefail

# install-gh.sh – 无需 Homebrew 的 gh 安装脚本（用户目录）
# 依赖 curl 与 tar；可结合 xget-local 加速下载

VERSION="${VERSION:-2.53.0}"
ARCH="$(uname -m)"
case "$ARCH" in
  arm64) PKG="gh_${VERSION}_macOS_arm64.zip" ;;
  x86_64) PKG="gh_${VERSION}_macOS_amd64.zip" ;;
  *) echo "Unsupported arch: $ARCH"; exit 1 ;;
esac

URL="https://github.com/cli/cli/releases/download/v${VERSION}/${PKG}"
TMPDIR="$(mktemp -d)"
# 自动清理临时目录
cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT
DESTDIR="${HOME}/.local/bin"
mkdir -p "$DESTDIR"

echo "[install-gh] downloading $URL"
if [[ -x ./xget-local ]]; then
  bash ./xget-local -c "xget_download $URL $TMPDIR/$PKG"
else
  curl -fL -o "$TMPDIR/$PKG" "$URL"
fi

echo "[install-gh] extracting"
unzip -q "$TMPDIR/$PKG" -d "$TMPDIR"

GH_BIN_PATH="$(find "$TMPDIR" -type f -name gh -path '*/bin/gh' -print -quit)"
if [[ -z "$GH_BIN_PATH" ]]; then
  echo "[install-gh] gh binary not found after extract"; exit 1
fi

echo "[install-gh] installing to $DESTDIR"
install -m 0755 "$GH_BIN_PATH" "$DESTDIR/gh"
echo "[install-gh] gh installed: $DESTDIR/gh"

case ":$PATH:" in
  *":$DESTDIR:"*) 
    echo "[install-gh] PATH already contains $DESTDIR";;
  *)
    echo "[install-gh] add to PATH (temporary for this session):"
    echo "  export PATH=\"$DESTDIR:\$PATH\""
    echo "[install-gh] or persist by adding the above line to your shell rc (e.g., ~/.zshrc)";;
esac

echo "[install-gh] next: run 'gh auth login --web' to login"