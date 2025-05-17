//
//  MessageTests.swift
//  LarkCloneTests
//
//  Created by 张纪龙 on 2025/5/16.
//

import XCTest
@testable import LarkClone
import UIKit

class MessageTests: XCTestCase {
    var messageCell: MessageCell!
    var testContact: Contact!
    var currentUser: Contact!
    
    override func setUp() {
        super.setUp()
        messageCell = MessageCell(style: .default, reuseIdentifier: "MessageCell")
        
        // 确保单元格有合理的布局尺寸
        messageCell.frame = CGRect(x: 0, y: 0, width: 320, height: 100)
        messageCell.layoutIfNeeded()
        
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
    
    // 测试单元格初始化
    func testCellInitialization() {
        XCTAssertNotNil(messageCell, "MessageCell 初始化失败")
        XCTAssertEqual(messageCell.selectionStyle, .none, "单元格应禁用选中样式")
    }
    
    // 测试发送消息布局
    func testSentMessageLayout() {
        // 创建一个安全的Message对象
        let sentMessage = Message(
            content: "这是一条测试发送的消息",
            sender: currentUser,
            type: .sent,
            isRead: true
        )
        
        // 配置单元格
        messageCell.configure(with: sentMessage)
        messageCell.layoutIfNeeded()  // 确保约束已应用
        
        // 获取MessageCellTester来协助测试
        let tester = MessageCellTester(cell: messageCell)
        
        // 验证发送者名称隐藏
        let isSenderNameHidden = tester.isSenderNameHidden()
        XCTAssertNotNil(isSenderNameHidden, "应能找到发送者名称标签")
        XCTAssertTrue(isSenderNameHidden ?? false, "发送类型消息应隐藏发送者名称")
        
        // 验证已读状态
        let isReadStatusHidden = tester.isReadStatusHidden()
        XCTAssertNotNil(isReadStatusHidden, "应能找到已读状态视图")
        XCTAssertFalse(isReadStatusHidden ?? true, "发送类型消息应显示已读状态")
        
        // 验证消息文本
        XCTAssertEqual(tester.getMessageText(), "这是一条测试发送的消息", "消息文本应正确显示")
    }
    
    // 测试接收消息布局
    func testReceivedMessageLayout() {
        // 创建一个安全的Message对象
        let receivedMessage = Message(
            content: "这是一条测试接收的消息",
            sender: testContact,
            type: .received,
            isRead: false
        )
        
        // 配置单元格
        messageCell.configure(with: receivedMessage)
        messageCell.layoutIfNeeded()  // 确保约束已应用
        
        // 获取MessageCellTester来协助测试
        let tester = MessageCellTester(cell: messageCell)
        
        // 验证发送者名称可见
        let isSenderNameHidden = tester.isSenderNameHidden()
        XCTAssertNotNil(isSenderNameHidden, "应能找到发送者名称标签")
        XCTAssertFalse(isSenderNameHidden ?? true, "接收类型消息应显示发送者名称")
        
        // 验证已读状态隐藏
        let isReadStatusHidden = tester.isReadStatusHidden()
        XCTAssertNotNil(isReadStatusHidden, "应能找到已读状态视图")
        XCTAssertTrue(isReadStatusHidden ?? false, "接收类型消息应隐藏已读状态")
        
        // 验证消息文本
        XCTAssertEqual(tester.getMessageText(), "这是一条测试接收的消息", "消息文本应正确显示")
    }
    
    // 测试时间标签
    func testTimeLabelPresence() {
        messageCell.testHelper_configureSafely(
            content: "任意消息",
            type: .sent,
            isRead: true
        )
        messageCell.layoutIfNeeded()
        
        let tester = MessageCellTester(cell: messageCell)
        XCTAssertNotNil(tester.getTimeText(), "应找到时间标签")
    }
}
