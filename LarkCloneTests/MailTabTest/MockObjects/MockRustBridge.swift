//
//  MockRustBridge.swift
//  LarkCloneTests
//  模拟RustBridge的功能
//  Created by 张纪龙 on 2025/5/16.
//
/*
 模拟RustBridge功能的实现
 提供测试用的邮件数据
 替代真实的Rust接口，便于测试
 */

import Foundation
import XCTest
import UIKit

class MockRustBridge: NSObject {
    
    static var mockEmails: [[String: Any]] = [
        [
            "id": "mock1",
            "sender": "Mock Sender 1",
            "subject": "Mock Subject 1",
            "preview": "Mock preview 1",
            "date": "2025-05-15 10:30:00",
            "isRead": false,
            "hasAttachment": true,
            "isOfficial": false,
            "emailCount": 3
        ],
        [
            "id": "mock2",
            "sender": "Mock Sender 2",
            "subject": "Mock Subject 2",
            "preview": "Mock preview 2",
            "date": "2025-05-14 15:45:00",
            "isRead": true,
            "hasAttachment": false,
            "isOfficial": true
        ],
        [
            "id": "mock3",
            "sender": "Mock Sender 3",
            "subject": "Mock Subject 3",
            "preview": "Mock preview 3",
            "date": "2025-05-13 09:15:00",
            "isRead": false,
            "hasAttachment": true,
            "isOfficial": false
        ]
    ]
    
    // 模拟实现RustBridge的fetchMailItems方法
    @objc class func fetchMailItems(withPage page: Int32,
                                   pageSize: Int32,
                                   filePath: String,
                                   completion: @escaping ([ObjCMailItem]?, Error?) -> Void) {
        
        // 模拟网络延迟
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            // 转换模拟数据为ObjCMailItem对象
            let startIndex = Int(page) * Int(pageSize)
            let endIndex = min(startIndex + Int(pageSize), mockEmails.count)
            
            // 检查是否超出数据范围
            if startIndex >= mockEmails.count {
                completion([], nil)
                return
            }
            
            // 获取请求的页面数据
            let pageEmails = Array(mockEmails[startIndex..<endIndex])
            
            // 转换为ObjCMailItem对象
            var objcItems: [ObjCMailItem] = []
            for emailDict in pageEmails {
                let item = ObjCMailItem()
                item.id = emailDict["id"] as? String ?? ""
                item.sender = emailDict["sender"] as? String ?? ""
                item.subject = emailDict["subject"] as? String ?? ""
                item.preview = emailDict["preview"] as? String ?? ""
                item.dateString = emailDict["date"] as? String ?? ""
                item.isRead = emailDict["isRead"] as? Bool ?? false
                item.hasAttachment = emailDict["hasAttachment"] as? Bool ?? false
                item.isOfficial = emailDict["isOfficial"] as? Bool ?? false
                item.emailCount = emailDict["emailCount"] as? NSNumber
                
                objcItems.append(item)
            }
            
            completion(objcItems, nil)
        }
    }
}
