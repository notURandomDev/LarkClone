#!/bin/bash
set -ex  # 打印每条命令 + 构建出错立即终止

cd "${SRCROOT}/RustSDK"

# 确保工具链可用
export PATH="$HOME/.cargo/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

# 切换到 Rust nightly 工具链
rustup override set nightly

# 获取 iOS 模拟器 SDK 和 clang 路径
SDKROOT=$(xcrun --sdk iphonesimulator --show-sdk-path)
CLANG=$(xcrun --sdk iphonesimulator -f clang)

# 打印确认
echo "Using SDKROOT: $SDKROOT"
echo "Using CLANG: $CLANG"
rustc --version
cargo --version

# 生成 .cargo/config.toml
mkdir -p .cargo
cat > .cargo/config.toml <<EOF
[target.aarch64-apple-ios-sim]
linker = "$CLANG"
rustflags = [
  "-C", "link-arg=-isysroot",
  "-C", "link-arg=$SDKROOT",
  "-C", "link-arg=-target",
  "-C", "link-arg=arm64-apple-ios-sim"
]
EOF

echo "=== .cargo/config.toml ==="
cat .cargo/config.toml

# 构建（用 build-std 强制编译 std 依赖和 build scripts）
cargo +nightly build -Z build-std=std,panic_abort --target aarch64-apple-ios-sim -v --release

# 产物合并（即便是单架构，仍用 lipo 生成 universal）
cargo +nightly lipo --release --targets aarch64-apple-ios-sim

# 拷贝产物
mkdir -p "${SRCROOT}/libs"
cp "target/universal/release/librust_sdk.a" "${SRCROOT}/libs/"

# 生成头文件
cbindgen --config cbindgen.toml --output include/rust_sdk.h

echo "✅ Rust 构建完成并输出至 libs/"
