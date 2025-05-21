//
//  ChatDetailViewControllerTests.swift
//  LarkCloneTests
//
//  Created by 张纪龙 on 2025/5/16.
//

import XCTest
@testable import LarkChatBubble
@testable import LarkClone


extension ChatDetailViewController {
    // Expose private methods for testing
    func testHelper_handleMessageLongPress(_ gesture: UILongPressGestureRecognizer) {
        handleMessageLongPress(gesture)
    }
    
    // Expose methods/properties for testing
    func testHelper_getContact() -> Contact {
        return self.contact
    }

    func testHelper_getMessages() -> [Message] {
        return self.messages
    }

    func testHelper_setMessages(_ messages: [Message]) {
        self.messages = messages
    }

    func testHelper_isDataLoaded() -> Bool {
        return self.isDataLoaded
    }

    func testHelper_setDataLoaded(_ loaded: Bool) {
        self.isDataLoaded = loaded
    }

    func testHelper_getTableView() -> UITableView {
        return self.tableView
    }

    func testHelper_getInputField() -> UITextField {
        return self.inputField
    }

//    // Expose private methods for testing
//    func testHelper_handleMessageLongPress(_ gesture: UILongPressGestureRecognizer) {
//        handleMessageLongPress(gesture)
//    }

    func testHelper_reEditMessageFromTip(_ sender: UIButton) {
        reEditMessageFromTip(sender)
    }
    
//    func testHelper_activateFirstRecallTipTimer() {
//        activateFirstRecallTipTimer()
//    }

    func testHelper_getReplyReferenceView() -> UIView? {
        return replyReferenceView
    }

    func testHelper_getReplyReferenceLabel() -> UILabel? {
        return replyReferenceLabel
    }

    func testHelper_getReplyTargetMessage() -> Message? {
        return replyTargetMessage
    }

    func testHelper_getReplyCountDict() -> [String: Int] {
        return replyCountDict
    }

    // 模拟发送消息的便捷方法
    func testHelper_sendMessage() {
        sendMessage()
    }

    // 模拟隐藏引用视图
    func testHelper_hideReplyReference() {
        hideReplyReference()
    }

    // Expose internal methods for testing if needed (already changed in source)
    // internal func recallMessage(at index: Int) { ... }
    // internal func activateFirstRecallTipTimer() { ... }
}

extension MessageCell {
     // Expose internal properties for testing
    var testHelper_bubbleView: ChatBubbleView { bubbleView }
    var testHelper_readStatusView: UIImageView { readStatusView }
    var testHelper_senderNameLabel: UILabel { senderNameLabel }
    var testHelper_timeLabel: UILabel { timeLabel }
    var testHelper_avatarImageView: UIImageView { avatarImageView }

    // Expose internal properties for testing
    var testHelper_replyCountView: UIView? {
        return replyCountView
    }
}

//extension ChatDetailViewController {
//    // Expose private methods for testing
//    func testHelper_handleMessageLongPress(_ gesture: UILongPressGestureRecognizer) {
//        handleMessageLongPress(gesture)
//    }
//
//    func testHelper_reEditMessageFromTip(_ sender: UIButton) {
//        reEditMessageFromTip(sender)
//    }
//}

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
    
    // 测试消息撤回功能
    func testMessageRecall() {
        // 创建当前用户
        let currentUser = Contact(
            avatar: UIImage(systemName: "person.circle.fill")!,
            name: "我",
            latestMsg: "",
            datetime: "",
            type: .user
        )
        
        // 创建一条5分钟内的消息
        let recentMessage = Message(
            content: "测试撤回消息",
            sender: currentUser,
            timestamp: Date(),
            type: .sent,
            isRead: true
        )
        
        // 设置测试消息
        viewController.testHelper_setMessages([recentMessage])
        viewController.testHelper_setDataLoaded(true)
        
        // 获取tableView
        let tableView = viewController.testHelper_getTableView()
        tableView.reloadData()
        
        // 模拟长按消息
        let indexPath = IndexPath(row: 0, section: 0)
//        let cell = viewController.tableView(tableView, cellForRowAt: indexPath)
        let longPressGesture = UILongPressGestureRecognizer()
        longPressGesture.state = .began
        viewController.testHelper_handleMessageLongPress(longPressGesture)
        
        // 直接调用 recallMessage 来模拟撤回操作
        viewController.recallMessage(at: indexPath.row)
        
        // 验证消息是否被撤回（消息类型变为recallTip）
        let messages = viewController.testHelper_getMessages()
        XCTAssertEqual(messages.count, 1, "Should still have one message")
        XCTAssertEqual(messages[0].type, .recallTip, "Message should be converted to recall tip")
        XCTAssertEqual(messages[0].content, NSLocalizedString("recall_tip_text", tableName: "MessengerTab", bundle: Bundle(for: MessageCell.self), value: "你撤回了一条消息", comment: ""), "Recall tip content should be correct")
        XCTAssertNotNil(messages[0].recallContent, "Recall content should be preserved")
        XCTAssertEqual(messages[0].recallContent, "测试撤回消息", "Recall content should match original message")
        
        // 验证初始状态下，recallEditExpireAt 已经被设置（由 startRecallExpireTimer 和 activateFirstRecallTipTimer）
        XCTAssertNotNil(messages[0].recallEditExpireAt, "Initially, recall tip should have an expire time set")
        
        // --- 1分钟内不点击"重新编辑"，按钮消失 ---
        
        // 模拟1分钟过去，将 recallEditExpireAt 设置到过去
        let pastDate = Date().addingTimeInterval(-61) // 确保过期
        messages[0].recallEditExpireAt = pastDate
        
        // 强制 TableView 刷新该行
        tableView.reloadRows(at: [indexPath], with: .none)
        
        // 重新获取 cell，并验证"重新编辑"按钮不存在
        let expiredRecallTipCell = viewController.tableView(tableView, cellForRowAt: indexPath)
        let expiredEditButton = (expiredRecallTipCell.contentView.subviews.first?.subviews.first { subview in
            if let button = subview as? UIButton, let title = button.titleLabel?.text {
                return title == NSLocalizedString("reedit_button_title", tableName: "MessengerTab", bundle: Bundle(for: MessageCell.self), value: "重新编辑", comment: "")
            }
            return false
        }) as? UIButton
        
        XCTAssertNil(expiredEditButton, "Edit button should disappear after 1 minute")
        
        // --- 点击"重新编辑"，自动续时1分钟 ---
        
        // 重新设置一个未过期的 recall tip 消息，并获取其初始过期时间
        let freshRecallTip = Message(
            content: NSLocalizedString("recall_tip_text", tableName: "MessengerTab", bundle: Bundle(for: MessageCell.self), value: "你撤回了一条消息", comment: ""),
            sender: currentUser,
            timestamp: Date(),
            type: .recallTip,
            isRead: true,
            recallContent: "测试撤回消息",
            recallEditExpireAt: Date().addingTimeInterval(30) // 设置一个30秒后过期的初始时间
        )
        viewController.testHelper_setMessages([freshRecallTip])
        tableView.reloadData()
        
        // 再次获取 cell 和按钮
        let freshRecallTipCell = viewController.tableView(tableView, cellForRowAt: indexPath)
        let freshEditButton = (freshRecallTipCell.contentView.subviews.first?.subviews.first { subview in
            if let button = subview as? UIButton, let title = button.titleLabel?.text {
                return title == NSLocalizedString("reedit_button_title", tableName: "MessengerTab", bundle: Bundle(for: MessageCell.self), value: "重新编辑", comment: "")
            }
            return false
        }) as? UIButton
        
        guard let reEditButtonAgain = freshEditButton else {
            XCTFail("Edit button should exist before expiring for re-edit test")
            return
        }
        
        // 记录点击前的时间戳和按钮的初始过期时间
        let timeBeforeClick = Date()
//        let initialExpireTime = freshRecallTip.recallEditExpireAt!
        
        // 模拟点击按钮 (直接调用 target/action)
        if let action = reEditButtonAgain.actions(forTarget: viewController, forControlEvent: .touchUpInside)?.first {
             viewController.perform(Selector(action), with: reEditButtonAgain)
        } else {
             XCTFail("Could not find action for re-edit button during续时 test")
             return // 添加 return 避免后续代码执行
        }
        
        // 获取点击后更新的消息和新的过期时间
        let updatedMessages = viewController.testHelper_getMessages()
        let updatedRecallTip = updatedMessages[0]
        let newExpireTime = updatedRecallTip.recallEditExpireAt!
        
        // 验证新的过期时间比点击前的时间晚大约1分钟（留一些余量处理测试执行时间）
        let expectedMinExpireTime = timeBeforeClick.addingTimeInterval(59) // 留1秒的余量
        XCTAssertGreaterThanOrEqual(newExpireTime, expectedMinExpireTime, "Clicking re-edit should extend the expire time")
        
        // 验证输入框内容 (此部分保留，因为点击"重新编辑"后仍然应该回显)
        let inputField = viewController.testHelper_getInputField()
        XCTAssertEqual(inputField.text, "测试撤回消息", "Input field should show recalled message content")
    }
    
    // 测试消息回复功能
    func testMessageReply() {
        // 创建当前用户和另一个用户
        let currentUser = Contact(
            avatar: UIImage(systemName: "person.circle.fill")!,
            name: "我",
            latestMsg: "",
            datetime: "",
            type: .user
        )
        let otherUser = mockContact // 使用 setup 中创建的 mockContact
        
        // 创建几条测试消息
        let message1 = Message(content: "这是一条普通消息", sender: otherUser!, type: .received)
        let message2 = Message(content: "这是我的消息", sender: currentUser, type: .sent)
        let message3 = Message(content: "这是另一条消息", sender: otherUser!, type: .received)
        
        // 设置测试消息
        viewController.testHelper_setMessages([message1, message2, message3])
        viewController.testHelper_setDataLoaded(true)
        
        // 获取tableView
        let tableView = viewController.testHelper_getTableView()
        tableView.reloadData()
        
        // --- 长按消息显示回复按钮，点击回复显示引用条 ---
        
        // 模拟长按 message1
        let indexPathToReply = IndexPath(row: 0, section: 0) // 长按第一条消息
        let longPressGestureReply = UILongPressGestureRecognizer()
        longPressGestureReply.state = .began
        viewController.testHelper_handleMessageLongPress(longPressGestureReply)
        
        // 执行 "回复" Action
        viewController.testHelper_replyMessage(at: indexPathToReply.row)
        
        // 验证引用条是否显示
        let replyReferenceView = viewController.testHelper_getReplyReferenceView()
        let replyReferenceLabel = viewController.testHelper_getReplyReferenceLabel()
        let replyTargetMessage = viewController.testHelper_getReplyTargetMessage()
        
        XCTAssertFalse(replyReferenceView?.isHidden ?? true, "Reply reference view should be visible")
        XCTAssertEqual(replyReferenceLabel?.text, "回复 \(message1.sender.name)：\(message1.content)", "Reply reference label should show correct content")
        XCTAssertEqual(replyTargetMessage?.id, message1.id, "Reply target message should be set")
        
        // --- 点击发送时，该消息被引用的次数加1 ---
        
        // 设置输入文本 (回复内容)
        let inputField = viewController.testHelper_getInputField()
        inputField.text = "这是我的回复内容"
        
        // 记录发送前被引用消息的引用次数 (初始应该为0)
        let initialReplyCount = viewController.testHelper_getReplyCountDict()[message1.id] ?? 0
        XCTAssertEqual(initialReplyCount, 0, "Initial reply count should be 0")
        
        // 模拟点击发送按钮
        viewController.testHelper_sendMessage()
        
        // 验证引用条是否隐藏
        XCTAssertTrue(replyReferenceView?.isHidden ?? false, "Reply reference view should be hidden after sending")
        XCTAssertNil(viewController.testHelper_getReplyTargetMessage(), "Reply target message should be nil after sending")
        
        // 验证被引用消息的引用次数加1
        let updatedReplyCount = viewController.testHelper_getReplyCountDict()[message1.id] ?? 0
        XCTAssertEqual(updatedReplyCount, initialReplyCount + 1, "Reply count should increase by 1 after sending a reply")
        
        // 强制刷新 TableView 以显示引用次数 (如果 TableView 没有自动更新)
        tableView.reloadData()
        
        // 验证被引用消息 cell 显示了引用次数
        let repliedCell = viewController.tableView(tableView, cellForRowAt: indexPathToReply) as? MessageCell
        XCTAssertNotNil(repliedCell?.testHelper_replyCountView, "Replied message cell should show reply count view")
        
        // --- 撤回回复消息时，被引用消息的引用次数-1，减为0不显示"X条回复" ---
        
        // 找到刚刚发送的回复消息 (应该是最后一条消息)
        let messages = viewController.testHelper_getMessages()
        guard let replyMessage = messages.last, replyMessage.replyTo?.id == message1.id else {
             XCTFail("Could not find the sent reply message")
             return
        }
        let replyMessageIndexPath = IndexPath(row: messages.count - 1, section: 0)
        
        // 模拟撤回这条回复消息
        // 注意：这里直接调用 recallMessage，跳过长按和 Action Sheet 流程
        viewController.recallMessage(at: replyMessageIndexPath.row)
        
        // 验证被引用消息的引用次数减1 (回到初始的0)
        let finalReplyCount = viewController.testHelper_getReplyCountDict()[message1.id] ?? 0
        XCTAssertEqual(finalReplyCount, 0, "Reply count should decrease by 1 after recalling a reply")
        
        // 强制刷新 TableView
        tableView.reloadData()
        
        // 验证被引用消息 cell 不再显示引用次数
        let finalRepliedCell = viewController.tableView(tableView, cellForRowAt: indexPathToReply) as? MessageCell
        XCTAssertNil(finalRepliedCell?.testHelper_replyCountView, "Replied message cell should hide reply count view when count is 0")
    }
}
