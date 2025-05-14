#!/bin/bash

set -e

echo "🔧 [Rust Setup] 使用 USTC 镜像安装并配置 Rust 工具链..."

# ============ 使用中科大镜像 ============
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
export CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse

# ============ 确保 ~/.cargo/bin 在 PATH 中 ============
CARGO_BIN="$HOME/.cargo/bin"
if [[ ":$PATH:" != *":$CARGO_BIN:"* ]]; then
    echo "📌 添加 $CARGO_BIN 到 PATH..."
    echo "export PATH=\"$CARGO_BIN:\$PATH\"" >> ~/.zshrc
    source ~/.zshrc  # 重新加载 zsh 配置
fi

# ============ 安装 rustup ============
if ! command -v rustup >/dev/null 2>&1; then
  echo "⚠️ Rustup 未安装，开始自动安装..."
  curl -sSf https://mirrors.ustc.edu.cn/rust-static/rustup/rustup-init.sh | \
    sh -s -- -y --no-modify-path --default-toolchain stable
fi

# ============ 设置默认版本 ============
rustup default stable

# ============ 检查 cargo ============
if ! command -v cargo >/dev/null; then
  echo "❌ cargo 未找到，请检查安装是否成功"
  exit 1
fi

# ============ 安装目标平台 ============
TARGET="aarch64-apple-ios-sim"
if ! rustup target list | grep -q "$TARGET (installed)"; then
  echo "📦 添加目标 $TARGET..."
  rustup target add "$TARGET"
fi

# ============ 安装组件 ============
echo "🔍 安装 clippy 和 rustfmt 组件..."
rustup component add clippy rustfmt

echo "✅ Rust 工具链与目标平台配置完成"
