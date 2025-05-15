#!/bin/bash

echo "===== 生成邮件数据 ====="

# 设置路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SWIFT_FILE="$PROJECT_ROOT/LarkClone/Frameworks/Tabs/MailTab/Sources/Scripts/GenerateMails.swift"
OUTPUT_DIR="$PROJECT_ROOT/LarkClone/Frameworks/Tabs/MailTab/Resources/MockData"
OUTPUT_FILE="$OUTPUT_DIR/mock_emails.plist"

# 检查Swift文件
if [ ! -f "$SWIFT_FILE" ]; then
    echo "错误: Swift文件不存在: $SWIFT_FILE"
    exit 0
fi

# 确保输出目录存在
mkdir -p "$OUTPUT_DIR"

# 编译执行方式
echo "编译并执行Swift文件..."
TEMP_DIR=$(mktemp -d)
COMPILED_BINARY="$TEMP_DIR/GenerateMails"

# 编译
(cd "$(dirname "$SWIFT_FILE")" && \
 xcrun -sdk macosx swiftc -o "$COMPILED_BINARY" "$(basename "$SWIFT_FILE")")

# 执行
if [ $? -eq 0 ] && [ -x "$COMPILED_BINARY" ]; then
    (cd "$(dirname "$SWIFT_FILE")" && "$COMPILED_BINARY")
    RESULT=$?
    
    if [ $RESULT -eq 0 ]; then
        echo "✓ 成功生成邮件数据"
        [ -f "$OUTPUT_FILE" ] && echo "  文件: $OUTPUT_FILE"
        rm -rf "$TEMP_DIR"
        
        # 将生成的plist文件添加到Copy Bundle Resources
        echo "将 $OUTPUT_FILE 添加到Copy Bundle Resources..."
        cp "${OUTPUT_FILE}" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/mock_emails.plist"
        
        exit 0
    else
        echo "✗ 执行失败，错误码: $RESULT"
    fi
else
    echo "✗ 编译失败"
fi

# 清理
rm -rf "$TEMP_DIR"
echo "✗ 生成失败"
exit 1
