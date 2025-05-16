#!/bin/bash
set -e

# ============ 检查 bazel ============
if command -v bazel >/dev/null; then
  echo "✅ bazel 找到了，版本：$(bazel version)"
  exit 1
fi

# ============ 安装 bazel ============

export BAZEL_VERSION=8.2.1
curl -fLO "https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-darwin-arm64.sh"

chmod +x "bazel-$BAZEL_VERSION-installer-darwin-arm64.sh"
./bazel-$BAZEL_VERSION-installer-darwin-arm64.sh --user

echo "export PATH=\"$HOME/.bazel/bin:$PATH\"" >> ~/.zshrc
source ~/.zshrc  # 重新加载 zsh 配置

# # ============ 检查 bazel ============
if ! command -v bazel >/dev/null; then
  echo "❌ bazel 未找到，请检查安装是否成功"
  exit 1
fi
echo "✅ bazel 安装完成，版本：$(bazel version)"