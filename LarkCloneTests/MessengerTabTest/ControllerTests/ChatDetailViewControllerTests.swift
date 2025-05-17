//
//  ChatDetailViewControllerTests.swift
//  LarkCloneTests
//
//  Created by 张纪龙 on 2025/5/16.
//

import XCTest
@testable import LarkClone

class ChatDetailViewControllerTests: XCTestCase {
    var viewController: ChatDetailViewController!
    var mockContact: Contact!
    
    override func setUp() {
        super.setUp()
        
        // 创建测试联系人
        mockContact = Contact(
            avatar: UIImage(systemName: "person.circle")!,
            name: "测试用户",
            latestMsg: "测试消息",
            datetime: "12:34",
            type: .user
        )
        
        // 创建视图控制器
        viewController = ChatDetailViewController(contact: mockContact)
        
        // 加载视图
        let _ = viewController.view
    }
    
    override func tearDown() {
        viewController = nil
        mockContact = nil
        super.tearDown()
    }
    
    // 测试初始化
    func testInitialization() {
        let contactFromVC = viewController.testHelper_getContact()
        XCTAssertEqual(contactFromVC.name, "测试用户", "Contact should be properly initialized")
    }
    
    // 测试消息加载
    func testMessagesLoaded() {
        // 使用测试辅助方法设置测试消息
        viewController.testHelper_loadTestMessages()
        
        // 验证数据是否已加载
        XCTAssertTrue(viewController.testHelper_isDataLoaded(), "Data should be loaded")
        XCTAssertGreaterThan(viewController.testHelper_getMessages().count, 0, "Messages should be loaded")
    }
    
    // 测试表视图数据源
    func testTableViewDataSource() {
        // 使用辅助方法设置测试消息
        viewController.testHelper_loadTestMessages()
        
        // 获取tableView和消息
        let tableView = viewController.testHelper_getTableView()
        let messages = viewController.testHelper_getMessages()
        
        // 验证行数匹配
        let rowCount = viewController.tableView(tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(rowCount, messages.count, "Table view should have same number of rows as messages")
        
        // 验证单元格类型
        if messages.count > 0 {
            let indexPath = IndexPath(row: 0, section: 0)
            let cell = viewController.tableView(tableView, cellForRowAt: indexPath)
            XCTAssertTrue(cell is MessageCell, "Cell should be a MessageCell")
        }
    }
    
    // 测试发送消息
    func testSendMessage() {
        // 使用辅助方法设置初始消息
        viewController.testHelper_loadTestMessages()
        
        // 记录初始消息数
        let initialCount = viewController.testHelper_getMessages().count
        
        // 设置输入文本
        let inputField = viewController.testHelper_getInputField()
        inputField.text = "测试新消息"
        
        // 发送消息
        let sendSelector = NSSelectorFromString("sendMessage")
        viewController.perform(sendSelector)
        
        // 验证消息是否已添加
        let newCount = viewController.testHelper_getMessages().count
        XCTAssertEqual(newCount, initialCount + 1, "Message count should increase by 1")
        
        // 验证最新消息内容
        let messages = viewController.testHelper_getMessages()
        if let lastMessage = messages.last {
            XCTAssertEqual(lastMessage.content, "测试新消息", "Last message content should match")
            XCTAssertEqual(lastMessage.type, .sent, "Last message type should be sent")
        } else {
            XCTFail("Last message should exist")
        }
    }
}
