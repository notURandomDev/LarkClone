#!/bin/bash

chmod +x setup.sh

# 打印脚本开始
echo "🔧 [Rust Setup] 检查 rustup 和 cargo 工具链..."

# 1. 检查 rustup 是否安装
if ! command -v rustup >/dev/null 2>&1; then
  echo "⚠️ Rustup 未安装，开始自动安装（请确保联网且允许执行脚本）..."
  
  # 静默安装 rustup（无交互）
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

  # 添加环境变量（有时 Xcode 无法继承 shell 环境）
  export PATH="$HOME/.cargo/bin:$PATH"
fi

# 2. 检查 cargo 是否正常（rustup 安装完成后会有）
if ! command -v cargo >/dev/null 2>&1; then
  echo "❌ cargo 未找到，即使已安装 rustup。请重启 Xcode 再试。"
  exit 1
fi

# 3. 检查目标平台是否存在
TARGET="aarch64-apple-ios-sim"
if ! rustup target list | grep "$TARGET (installed)" >/dev/null; then
  echo "📦 正在安装 Rust 构建目标 $TARGET..."
  rustup target add "$TARGET"
fi

echo "✅ Rust 工具链已准备完毕。"
