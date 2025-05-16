#!/bin/bash
# 设备管理脚本：启动模拟器 + 安装应用 + 运行应用

# 获取当前可用的模拟器设备列表
devices=$(xcrun simctl list devices)

# 筛选特定设备：iOS 18.4 的 iPhone 16 Pro
DEVICE_UDID=$(echo "$devices" | grep "iOS 18.4" -A 10 | grep "iPhone 16 Pro" | grep -v "Temp" | head -n 1 | awk '{print $4}' | tr -d '()')

# 检查设备是否存在
if [ -z "$DEVICE_UDID" ]; then
  echo "❌ 错误：未找到符合要求的 iOS 18.4 iPhone 16 Pro 模拟器设备"
  exit 1
fi

echo "✅ 成功定位设备：iOS 18.4 iPhone 16 Pro (UDID: $DEVICE_UDID)"

# 设备启动流程
echo "🔛 正在启动模拟器..."
xcrun simctl boot "$DEVICE_UDID"

echo "🖥️ 启动模拟器图形界面..."
open -a Simulator

# 应用安装配置
APP_NAME="LarkClone.app"
echo "🔍 正在搜索最新的 $APP_NAME 构建文件..."

# 查找最新的.app构建文件
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "$APP_NAME" -type d -print0 | xargs -0 stat -f "%m %N" | sort -rn | head -n 1 | cut -d' ' -f2-)
echo "📂 应用构建路径：${APP_PATH}"

# 提取应用包标识符
BUNDLE_ID=$(plutil -extract CFBundleIdentifier raw "${APP_PATH}/Info.plist")
echo "🆔 应用包标识符：${BUNDLE_ID}"

# 应用安装流程
echo "⬇️ 正在安装应用到模拟器..."
xcrun simctl install booted "$APP_PATH"

# 应用启动流程
echo "🚀 正在启动应用程序..."
xcrun simctl launch booted "$BUNDLE_ID"
