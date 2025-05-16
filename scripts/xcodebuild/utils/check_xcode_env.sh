#!/bin/bash
# 返回值通过 return 而不是 exit 传递

check_xcode_env() {
    # 检查 xcodebuild 是否存在
    if ! command -v xcodebuild &>/dev/null; then
        echo "❌ Error: xcodebuild not found"
        return 1
    fi

    # 检查当前是否是 Command Line Tools
    ACTIVE_DIR=$(xcode-select -p)
    if [[ ! "$ACTIVE_DIR" == *"Xcode.app"* ]]; then
        echo "⚠️ Switching to Xcode..."
        if ! sudo xcode-select -s /Applications/Xcode.app/Contents/Developer 2>/dev/null; then
            echo "❌ Failed to switch Xcode path"
            return 2
        fi
        echo "✅ Switched to: $(xcode-select -p)"
    fi

    # 检查许可协议
    if ! xcodebuild -license check &>/dev/null; then
        echo "⚠️ Accepting Xcode license..."
        if ! sudo xcodebuild -license accept; then
            echo "❌ Failed to accept license"
            return 3
        fi
    fi

    echo "✅ Xcode environment check passed"
    return 0
}

# 执行检查（不再使用 exit）
check_xcode_env
