//
//  MockContact.swift
//  LarkCloneTests
//
//  Created by 张纪龙 on 2025/5/16.
//

import Foundation
import UIKit
@testable import LarkClone

class MockContact {
    
    // 创建模拟的普通用户联系人
    static func createUserContact(name: String = "测试用户") -> Contact {
        return Contact(
            avatar: UIImage(systemName: "person.circle"),
            name: name,
            latestMsg: "最新消息",
            datetime: "12:34",
            type: .user
        )
    }
    
    // 创建模拟的机器人联系人
    static func createBotContact(name: String = "测试机器人") -> Contact {
        return Contact(
            avatar: UIImage(systemName: "app.badge"),
            name: name,
            latestMsg: "机器人消息",
            datetime: "12:45",
            type: .bot
        )
    }
    
    // 创建模拟的外部联系人
    static func createExternalContact(name: String = "外部用户") -> Contact {
        return Contact(
            avatar: UIImage(systemName: "person.crop.circle.badge.questionmark"),
            name: name,
            latestMsg: "外部消息",
            datetime: "13:00",
            type: .external
        )
    }
    
    // 创建当前用户联系人
    static func createCurrentUser() -> Contact {
        return Contact(
            avatar: UIImage(named: "zhang-jilong") ?? UIImage(systemName: "person.circle.fill") ?? UIImage(),
            name: "我",
            latestMsg: "",
            datetime: "",
            type: .user
        )
    }
}
