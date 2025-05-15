#!/bin/bash

# 调用环境检查脚本
UTILS_DIR=$(dirname "$0")/utils
source "$UTILS_DIR/check_xcode_env.sh"
CHECK_RESULT=$?
echo "CHECK_RESULT为：${CHECK_RESULT}"

if [ $CHECK_RESULT -ne 0 ]; then
    exit 1  # 环境检查失败时退出
fi

# 正常构建流程
PROJECT_FILE="LarkClone.xcodeproj"
echo "🏗️ 开始构建项目: ${PROJECT_FILE}"

BUILD_SCHEME="LarkClone"
echo "🔧 构建方案: ${BUILD_SCHEME}"

BUILD_CONFIG="Debug"
echo "⚙️ 构建配置: ${BUILD_CONFIG}"

BUILD_DEST="platform=iOS Simulator,name=iPhone 16 Pro,OS=18.4,arch=arm64"
echo "📱 目标设备: iPhone 16 Pro (iOS 18.4 Simulator)"

# 执行 Xcode 构建命令
echo "🏗️  Building project..."
xcodebuild \
  -project "$PROJECT_FILE" \
  -scheme "$BUILD_SCHEME" \
  -configuration "$BUILD_CONFIG" \
  -destination "$BUILD_DEST" \
  build

if [ $? -eq 0 ]; then
    echo "✅ Build succeeded"
else
    echo "❌ Build failed"
    exit 1
fi
