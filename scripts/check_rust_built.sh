#!/bin/bash

set -e

# 检查生成的静态库
RUST_LIB_PATH="./RustSDK/target/aarch64-apple-ios-sim/release/librust_sdk.a"

if [ ! -f "$RUST_LIB_PATH" ]; then
  echo "❌ [Rust Build Check] 未检测到 Rust 构建产物：$RUST_LIB_PATH"
  echo "💡 请先在终端中执行："
  echo ""
  echo "    cd RustSDK && cargo build --target aarch64-apple-ios-sim --release"
  echo ""
  echo "⚠️ 构建终止，必须先完成 Rust 编译步骤。"
  exit 1
fi

echo "✅ [Rust Build Check] Rust 构建产物已存在，继续构建流程。"
