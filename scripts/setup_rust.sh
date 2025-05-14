#!/bin/bash

set -e  # 一旦出错立即退出
export PATH="$HOME/.cargo/bin:$PATH"

echo "🔧 [Rust Setup] 检查 rustup 和 cargo 工具链..."

# 1. 检查 rustup 是否安装
if ! command -v rustup >/dev/null 2>&1; then
  echo "⚠️ Rustup 未安装，开始自动安装（请确保联网且允许执行脚本）..."

  # ✅ 安装 rustup（-y 表示自动确认）
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

  # ✅ 安装后必须重置 PATH，因为当前 shell 没重载 profile
  export PATH="$HOME/.cargo/bin:$PATH"

  # ✅ 检查是否真的安装成功
  if ! command -v rustup >/dev/null 2>&1; then
    echo "❌ Rustup 安装失败或未生效，请关闭 Xcode 重新打开后重试。"
    exit 1
  fi

  # ✅ 设置默认工具链（解决 "could not choose a version" 错误）
  rustup default stable
fi

# 2. 检查 cargo 是否正常（rustup 安装完成后会有）
if ! command -v cargo >/dev/null 2>&1; then
  echo "❌ cargo 未找到，即使已安装 rustup。可能 PATH 未生效，尝试重新打开 Xcode。"
  exit 1
fi

# 3. 安装 iOS 构建目标
TARGET="aarch64-apple-ios-sim"
if ! rustup target list | grep "$TARGET (installed)" >/dev/null; then
  echo "📦 正在安装 Rust 构建目标 $TARGET..."
  rustup target add "$TARGET"
fi

echo "✅ Rust 工具链已准备完毕。"
