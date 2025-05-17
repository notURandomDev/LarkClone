//
//  FileSystemMocks.swift
//  LarkCloneTests
//
//  Created by 张纪龙 on 2025/5/16.
//
/*
 模拟文件系统操作
 提供内存中的"文件"读写功能
 用于测试文件操作而不需要真实文件系统
 */

import XCTest
import UIKit
@testable import LarkClone

class FileSystemMock {
    
    // 模拟文件内容
    static var mockPlistContent: Data? = {
        let mockEmails: [[String: Any]] = [
            [
                "id": "file1",
                "sender": "File Sender 1",
                "subject": "File Subject 1",
                "preview": "File preview 1",
                "date": "2025-05-15 10:30:00",
                "isRead": false,
                "hasAttachment": true,
                "isOfficial": false,
                "emailCount": 3
            ],
            [
                "id": "file2",
                "sender": "File Sender 2",
                "subject": "File Subject 2",
                "preview": "File preview 2",
                "date": "2025-05-14 15:45:00",
                "isRead": true,
                "hasAttachment": false,
                "isOfficial": true
            ]
        ]
        
        return try? PropertyListSerialization.data(
            fromPropertyList: mockEmails,
            format: .xml,
            options: 0
        )
    }()
    
    // 内存中存储"文件"的字典
    private static var mockFiles: [String: Data] = [:]
    
    // 设置模拟文件系统
    static func setup() {
        // 创建临时目录路径
        let tempPath = NSTemporaryDirectory().appending("TestDocuments")
        let fileManager = FileManager.default
        
        // 如果目录不存在则创建
        try? fileManager.createDirectory(atPath: tempPath, withIntermediateDirectories: true, attributes: nil)
        
        // 设置模拟文件
        if let plistContent = mockPlistContent {
            let plistPath = tempPath.appending("/mock_emails.plist")
            mockFiles[plistPath] = plistContent
        }
        
        // 为文件访问设置方法替换
        swizzleFileManagerMethods()
    }
    
    // 测试后清理
    static func tearDown() {
        mockFiles.removeAll()
        unswizzleFileManagerMethods()
    }
    
    // FileManager的方法替换
    private static func swizzleFileManagerMethods() {
        // 这里应该使用Objective-C运行时函数来替换FileManager方法
        // 为简单起见，我们跳过实际的方法替换实现
    }
    
    private static func unswizzleFileManagerMethods() {
        // 撤销方法替换以恢复原始行为
    }
    
    // 模拟文件读取的辅助方法
    static func mockContentsOfFile(path: String) -> Data? {
        return mockFiles[path]
    }
    
    // 模拟文件存在检查的辅助方法
    static func mockFileExists(atPath path: String) -> Bool {
        return mockFiles[path] != nil
    }
    
    // 模拟写入文件的辅助方法
    static func mockWriteToFile(data: Data, path: String) -> Bool {
        mockFiles[path] = data
        return true
    }
}
