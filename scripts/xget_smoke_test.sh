#!/usr/bin/env bash
set -euo pipefail

DOMAIN_PREFIX="${1:-https://540383401.xyz/xget}"

targets=(
  "$DOMAIN_PREFIX/gh/torvalds/linux/archive/refs/tags/v6.10.zip"
  "$DOMAIN_PREFIX/hf/bert-base-uncased/resolve/main/config.json"
  "$DOMAIN_PREFIX/npm/lodash/-/lodash-4.17.21.tgz"
  "$DOMAIN_PREFIX/pypi/simple/requests/"
  "$DOMAIN_PREFIX/jenkins/download/plugins/git/5.3.0/git.hpi"
  "$DOMAIN_PREFIX/cr/ghcr/v2/homebrew/core/bash/manifests/5.2.26"
)

echo "Testing Xget endpoints via: $DOMAIN_PREFIX"
printf "%-70s %6s %s\n" "URL" "CODE" "LATENCY(s)"
for u in "${targets[@]}"; do
  method_args=(-L)
  # HEAD 在部分代理不支持，针对大文件改用 Range 只取首字节
  if [[ "$u" =~ /gh/.*\.zip$ ]] || [[ "$u" =~ /jenkins/.*\.hpi$ ]]; then
    method_args+=( -H 'Range: bytes=0-0' )
  fi
  res=$(curl -s -o /dev/null -w '%{http_code}\t%{time_total}' --connect-timeout 10 "${method_args[@]}" "$u" || true)
  code=${res%%\t*}
  latency=${res##*\t}
  printf "%-70s %6s %s\n" "$u" "$code" "$latency"
done

echo "\nHint: For installing uv via Xget, set base to:"
echo "  UV_INSTALLER_GITHUB_BASE_URL=\"$DOMAIN_PREFIX/gh\" sh install.sh"