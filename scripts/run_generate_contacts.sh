#!/bin/bash

echo "===== 生成联系人数据 ====="

# 设置路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SWIFT_FILE="$PROJECT_ROOT/LarkClone/Frameworks/Tabs/MessengerTab/Sources/Scripts/GenerateContacts.swift"
OUTPUT_DIR="$PROJECT_ROOT/LarkClone/Frameworks/Tabs/MessengerTab/Resources/MockData"
OUTPUT_FILE="$OUTPUT_DIR/mock_contacts.plist"

# 检查Swift文件
if [ ! -f "$SWIFT_FILE" ]; then
    echo "错误: Swift文件不存在: $SWIFT_FILE"
    exit 1
fi

# 确保输出目录存在
mkdir -p "$OUTPUT_DIR"

# 编译执行方式
echo "编译并执行Swift文件..."
TEMP_DIR=$(mktemp -d)
COMPILED_BINARY="$TEMP_DIR/GenerateContacts"

# 编译
(cd "$(dirname "$SWIFT_FILE")" && \
 xcrun -sdk macosx swiftc -o "$COMPILED_BINARY" "$(basename "$SWIFT_FILE")")

# 执行
if [ $? -eq 0 ] && [ -x "$COMPILED_BINARY" ]; then
    (cd "$(dirname "$SWIFT_FILE")" && "$COMPILED_BINARY")
    RESULT=$?
    
    if [ $RESULT -eq 0 ]; then
        echo "✓ 成功生成联系人数据"
        [ -f "$OUTPUT_FILE" ] && echo "  文件: $OUTPUT_FILE"
        rm -rf "$TEMP_DIR"
        exit 0
    fi
fi

# 清理并尝试直接执行
rm -rf "$TEMP_DIR"
echo "尝试直接执行..."

# 直接执行Swift文件
if grep -q "#!/usr/bin/env swift" "$SWIFT_FILE"; then
    chmod +x "$SWIFT_FILE"
    "$SWIFT_FILE"
else
    swift "$SWIFT_FILE"
fi

# 检查结果
if [ $? -eq 0 ]; then
    echo "✓ 成功生成联系人数据"
    [ -f "$OUTPUT_FILE" ] && echo "  文件: $OUTPUT_FILE"
else
    echo "✗ 生成失败"
    exit 1
fi
