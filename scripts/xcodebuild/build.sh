#!/bin/bash
# Xcode 项目构建脚本
## 构建参数配置
### 项目文件路径
PROJECT_FILE="LarkClone.xcodeproj"

### 构建方案（从项目文件中读取默认方案）
BUILD_SCHEME="LarkClone"

### 构建配置模式（调试/发布）
BUILD_CONFIG="Debug"

### 构建目标平台配置
BUILD_DEST="platform=iOS Simulator,name=iPhone 16 Pro,OS=18.4,arch=arm64"

## 执行 Xcode 构建命令
echo "🏗️ 开始构建项目: ${PROJECT_FILE}"
echo "🔧 构建方案: ${BUILD_SCHEME}"
echo "⚙️ 构建配置: ${BUILD_CONFIG}"
echo "📱 目标设备: iPhone 16 Pro (iOS 18.4 Simulator)"

xcodebuild \
  -project "${PROJECT_FILE}" \
  -scheme "${BUILD_SCHEME}" \
  -configuration ${BUILD_CONFIG} \
  -destination "${BUILD_DEST}" \
  build

echo "✅ 构建命令已执行完成"
```
