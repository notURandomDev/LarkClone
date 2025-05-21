//
//  Message.swift
//  LarkClone
//
//  Created by 张纪龙 on 2025/5/11.
//

import UIKit

enum MessageType {
    case sent
    case received
    case recallTip
}

class Message {
    let id: String
    let content: String
    let sender: Contact
    let timestamp: Date
    let type: MessageType
    var isRead: Bool
    var recallContent: String?
    var recallEditExpireAt: Date?
    var replyTo: Message?
    var recallReplyTo: Message?
    var isRecalled: Bool
    
    init(id: String = UUID().uuidString,
         content: String,
         sender: Contact,
         timestamp: Date = Date(),
         type: MessageType,
         isRead: Bool = false,
         recallContent: String? = nil,
         recallEditExpireAt: Date? = nil,
         replyTo: Message? = nil,
         recallReplyTo: Message? = nil,
         isRecalled: Bool = false) {
        self.id = id
        self.content = content
        self.sender = sender
        self.timestamp = timestamp
        self.type = type
        self.isRead = isRead
        self.recallContent = recallContent
        self.recallEditExpireAt = recallEditExpireAt
        self.replyTo = replyTo
        self.recallReplyTo = recallReplyTo
        self.isRecalled = isRecalled
    }
    
    // 格式化时间为聊天界面显示格式
    func formattedTime() -> String {
        let formatter = DateFormatter()
        // Check current locale to decide format
        let currentLocale = Locale.current
        if currentLocale.language.languageCode == "zh" { // Assuming Chinese for zh
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: timestamp)
            
            let period: String
            if hour >= 0 && hour < 12 {
                period = NSLocalizedString("time_am", tableName: "MessengerTab", bundle: Bundle(for: Message.self), value: "上午", comment: "")
                formatter.dateFormat = "h:mm"
            } else {
                period = NSLocalizedString("time_pm", tableName: "MessengerTab", bundle: Bundle(for: Message.self), value: "下午", comment: "")
                formatter.dateFormat = "h:mm"
            }
            return period + " " + formatter.string(from: timestamp)
        } else {
            // Default to English format (or other non-Chinese)
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: timestamp)
        }
    }
    
    // 创建测试消息数据
    static func getMockMessages(contact: Contact) -> [Message] {
        let currentUser = Contact(avatar: UIImage(systemName: "person.circle.fill") ?? UIImage(),
                                 name: "我",
                                 latestMsg: "",
                                 datetime: "",
                                 type: .user)
        
        // 创建简单的对话消息
        return [
            Message(content: "你好，最近工作怎么样？", sender: contact, type: .received, isRead: true),
            Message(content: "挺好的，谢谢关心！", sender: currentUser, type: .sent, isRead: true),
            Message(content: "明天有时间一起吃个饭吗？", sender: contact, type: .received, isRead: true),
            Message(content: "好啊，那就中午12点见！", sender: currentUser, type: .sent, isRead: true),
            Message(content: "👍", sender: contact, type: .received, isRead: false)
        ]
    }
}

