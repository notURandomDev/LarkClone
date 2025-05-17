//
//  MessageCellTests.swift
//  LarkCloneTests
//
//  Created by 张纪龙 on 2025/5/16.
//

import XCTest
@testable import LarkClone
import UIKit

class MessageCellTests: XCTestCase {
    
    var messageCell: MessageCell!
    var testContact: Contact!
    var currentUser: Contact!
    
    override func setUp() {
        super.setUp()
        messageCell = MessageCell(style: .default, reuseIdentifier: "MessageCell")
        
        // 确保单元格有合理的布局尺寸进行测试
        messageCell.frame = CGRect(x: 0, y: 0, width: 320, height: 100)
        
        testContact = Contact(
            avatar: UIImage(systemName: "person.circle") ?? UIImage(),
            name: "测试好友",
            latestMsg: "",
            datetime: "",
            type: .user
        )
        
        currentUser = Contact(
            avatar: UIImage(systemName: "person.circle.fill") ?? UIImage(),
            name: "我",
            latestMsg: "",
            datetime: "",
            type: .user
        )
    }
    
    override func tearDown() {
        messageCell = nil
        testContact = nil
        currentUser = nil
        super.tearDown()
    }
    
    // 测试发送消息配置
    func testConfigureWithSentMessage() {
        // 创建发送消息
        let sentMessage = Message(
            content: "这是一条测试发送的消息",
            sender: currentUser,
            type: .sent,
            isRead: true
        )
        
        // 配置单元格并强制布局
        messageCell.configure(with: sentMessage)
        messageCell.layoutIfNeeded()
        
        // 使用辅助工具获取组件
        let tester = MessageCellTester(cell: messageCell)
        
        // 测试发送者名称标签是否隐藏
        let isSenderNameHidden = tester.isSenderNameHidden()
        XCTAssertNotNil(isSenderNameHidden, "未找到发送者名称标签")
        XCTAssertTrue(isSenderNameHidden ?? false, "发送者名称标签未隐藏")
        
        // 测试已读状态视图是否可见
        let isReadStatusHidden = tester.isReadStatusHidden()
        XCTAssertNotNil(isReadStatusHidden, "未找到已读状态视图")
        XCTAssertFalse(isReadStatusHidden ?? true, "已读状态视图未显示")
        
        // 测试消息文本是否正确
        XCTAssertEqual(tester.getMessageText(), "这是一条测试发送的消息", "消息文本不匹配")
    }
    
    // 测试接收消息配置
    func testConfigureWithReceivedMessage() {
        // 创建接收消息
        let receivedMessage = Message(
            content: "这是一条测试接收的消息",
            sender: testContact,
            type: .received,
            isRead: false
        )
        
        // 配置单元格并强制布局
        messageCell.configure(with: receivedMessage)
        messageCell.layoutIfNeeded()
        
        // 使用辅助工具获取组件
        let tester = MessageCellTester(cell: messageCell)
        
        // 测试发送者名称标签是否可见
        let isSenderNameHidden = tester.isSenderNameHidden()
        XCTAssertNotNil(isSenderNameHidden, "未找到发送者名称标签")
        XCTAssertFalse(isSenderNameHidden ?? true, "发送者名称标签应该可见")
        
        // 测试已读状态视图是否隐藏
        let isReadStatusHidden = tester.isReadStatusHidden()
        XCTAssertNotNil(isReadStatusHidden, "未找到已读状态视图")
        XCTAssertTrue(isReadStatusHidden ?? false, "已读状态视图应该隐藏")
        
        // 测试消息文本是否正确
        XCTAssertEqual(tester.getMessageText(), "这是一条测试接收的消息", "消息文本不匹配")
    }
}
