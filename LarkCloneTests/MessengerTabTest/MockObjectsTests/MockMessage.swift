//
//  MockMessage.swift
//  LarkCloneTests
//
//  Created by 张纪龙 on 2025/5/16.
//

import Foundation
import UIKit
@testable import LarkClone

class MockMessage {
    
    // 创建模拟的发送消息
    static func createSentMessage(content: String = "测试发送消息", isRead: Bool = true) -> Message {
        let sender = Contact(
            avatar: UIImage(systemName: "person.circle"),
            name: "我",
            latestMsg: "",
            datetime: "",
            type: .user
        )
        
        return Message(
            content: content,
            sender: sender,
            timestamp: Date(),
            type: .sent,
            isRead: isRead
        )
    }
    
    // 创建模拟的接收消息
    static func createReceivedMessage(content: String = "测试接收消息", sender: Contact? = nil) -> Message {
        let messageSender = sender ?? Contact(
            avatar: UIImage(systemName: "person.circle"),
            name: "测试用户",
            latestMsg: "",
            datetime: "",
            type: .user
        )
        
        return Message(
            content: content,
            sender: messageSender,
            timestamp: Date(),
            type: .received,
            isRead: false
        )
    }
    
    // 创建一组模拟的消息列表
    static func createMockMessageList(count: Int = 5) -> [Message] {
        var messages: [Message] = []
        
        for i in 0..<count {
            if i % 2 == 0 {
                messages.append(createReceivedMessage(content: "接收消息 \(i+1)"))
            } else {
                messages.append(createSentMessage(content: "发送消息 \(i+1)"))
            }
        }
        
        return messages
    }
}
