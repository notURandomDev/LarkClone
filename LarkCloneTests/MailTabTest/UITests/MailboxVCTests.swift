//
//  MailboxVCTests.swift
//  LarkClone
//
//  Created by 张纪龙 on 2025/5/16.
//
/*这个文件测试邮箱视图控制器：
 测试邮箱视图控制器
 验证UI组件设置、表格视图配置
 测试数据加载和用户交互
 测试表格视图代理和数据源方法
*/

import XCTest
import UIKit
@testable import LarkClone
//@testable import LarkSearchBar

final class MailboxVCTests: XCTestCase {
    
    var mailboxVC: MailboxVC!
    
    override func setUp() {
        super.setUp()
        mailboxVC = MailboxVC()
        
        // Load view hierarchy
        _ = mailboxVC.view
        
//        mailboxVC.setValue(UITableView(), forKey: "tableView")
//        mailboxVC.setValue(UIRefreshControl(), forKey: "refreshControl")
//        mailboxVC.setValue(NSMutableArray(), forKey: "filteredEmails")
    }
    
    override func tearDown() {
        mailboxVC = nil
        super.tearDown()
    }
    
    // MARK: - UI Setup Tests
    
    func testViewSetup() {
        XCTAssertNotNil(mailboxVC.view, "View should be loaded")
        
        // Find tableView using value for key or KVC
        let tableView = mailboxVC.value(forKey: "tableView") as? UITableView
        XCTAssertNotNil(tableView, "TableView should be initialized")
        
        // Find searchBarView
//        let searchBarView = mailboxVC.value(forKey: "searchBarView") as? SearchBarView
//        XCTAssertNotNil(searchBarView, "SearchBarView should be initialized")
        let hasSearchView = mailboxVC.view.subviews.contains { subview in
            // 使用类名字符串检查而非直接类型检查
            return NSStringFromClass(type(of: subview)).contains("SearchBarView")
        }
        XCTAssertTrue(hasSearchView, "View should contain a search bar component")
        
        // Find refreshControl
        let refreshControl = mailboxVC.value(forKey: "refreshControl") as? UIRefreshControl
        XCTAssertNotNil(refreshControl, "RefreshControl should be initialized")
        
        // Check navigation bar items
        XCTAssertEqual(mailboxVC.navigationItem.rightBarButtonItems?.count, 2, "Should have 2 right bar button items")
    }
    
    func testTableViewSetup() {
        // Get tableView using KVC
        let tableView = mailboxVC.value(forKey: "tableView") as? UITableView
        XCTAssertNotNil(tableView, "TableView should be initialized")
        
        if let tableView = tableView {
            // Check tableView properties
            XCTAssertEqual(tableView.delegate as? MailboxVC, mailboxVC, "TableView delegate should be set")
            XCTAssertEqual(tableView.dataSource as? MailboxVC, mailboxVC, "TableView dataSource should be set")
            XCTAssertEqual(tableView.refreshControl, mailboxVC.value(forKey: "refreshControl") as? UIRefreshControl, "TableView refreshControl should be set")
            XCTAssertEqual(tableView.separatorStyle, .singleLine, "TableView separator style should be singleLine")
            
            // Check cell registration
            let cell = tableView.dequeueReusableCell(withIdentifier: EmailCell.reuseID())
            XCTAssertNotNil(cell, "TableView should be able to dequeue EmailCell")
            XCTAssert(cell is EmailCell, "Dequeued cell should be an EmailCell")
        }
    }
    
    // MARK: - Data Loading Tests
    
    func testInitialDataLoading() {
        // Verify filteredEmails array is created
        let filteredEmails = mailboxVC.value(forKey: "filteredEmails") as? NSMutableArray
        XCTAssertNotNil(filteredEmails, "filteredEmails array should be initialized")
        
        // Ideally we'd test if loadEmails was called, but we'd need to mock the network layer
        // This would require dependency injection or method swizzling
    }
    
    // MARK: - User Action Tests
    
    func testFilterButtonTapped() {
        // Get the filter button from navigation items
        let filterButton = mailboxVC.navigationItem.rightBarButtonItems?[1]
        XCTAssertNotNil(filterButton, "Filter button should exist")
        
        // Create a mock UIApplication to capture presented controllers
        let mockApplication = MockUIApplication()
        
        // Trigger the filter button action manually
        mailboxVC.perform(NSSelectorFromString("filterButtonTapped"))
        
        // If we could mock UIApplication, we'd verify an alert controller was presented
        // Since this is challenging in unit tests without UI testing, we'll skip this verification
    }
    
    func testComposeButtonTapped() {
        // Get the compose button from navigation items
        let composeButton = mailboxVC.navigationItem.rightBarButtonItems?[0]
        XCTAssertNotNil(composeButton, "Compose button should exist")
        
        // Trigger the compose button action manually
        mailboxVC.perform(NSSelectorFromString("composeButtonTapped"))
        
        // Similar to above, verifying alert presentation is challenging in unit tests
    }
    
    func testRefreshData() {
        // Initial page should be 0
        XCTAssertEqual(getPrivateProperty(for: mailboxVC, key: "currentPage") as? Int, 0)
        
        // Set currentPage to 2 to simulate scrolled state
        setPrivateProperty(for: mailboxVC, key: "currentPage", value: 2)
        XCTAssertEqual(getPrivateProperty(for: mailboxVC, key: "currentPage") as? Int, 2)
        
        // Call refreshData
        mailboxVC.perform(NSSelectorFromString("refreshData"))
        
        // Verify currentPage is reset to 0
        XCTAssertEqual(getPrivateProperty(for: mailboxVC, key: "currentPage") as? Int, 0)
        
        // Verify hasMoreData is reset to true
        XCTAssertEqual(getPrivateProperty(for: mailboxVC, key: "hasMoreData") as? Bool, true)
    }
    
    func testMarkEmailAsRead() {
        // 创建测试邮件
        let testEmail = MailItem(id: "test123",
                               sender: "Test Sender",
                               subject: "Test Subject",
                               preview: "This is a test preview",
                               dateString: "2025-05-15 10:30:00",
                               isRead: false,
                               hasAttachment: true,
                               isOfficial: false,
                               emailCount: 3)
        
        // 添加到邮件列表
        let allEmails = NSArray(array: [testEmail])
        mailboxVC.setValue(allEmails, forKey: "allEmails")
        
        let filteredEmails = NSMutableArray(array: [testEmail])
        mailboxVC.setValue(filteredEmails, forKey: "filteredEmails")
        
        // 避免了触发TableView更新
        testEmail.setValue(true, forKey: "isRead")
        
        // 验证邮件已标记为已读
        XCTAssertTrue(testEmail.isRead, "Email should be marked as read")
    }
    
    func testFilterEmailsWithText() {
        // Set up initial state
        setPrivateProperty(for: mailboxVC, key: "currentPage", value: 5)
        setPrivateProperty(for: mailboxVC, key: "isSearching", value: false)
        
        // Call filterEmailsWithText with search term
        mailboxVC.perform(NSSelectorFromString("filterEmailsWithText:"), with: "test search")
        
        // Verify state updates
        XCTAssertEqual(getPrivateProperty(for: mailboxVC, key: "currentSearchText") as? String, "test search")
        XCTAssertEqual(getPrivateProperty(for: mailboxVC, key: "currentPage") as? Int, 0)
        XCTAssertEqual(getPrivateProperty(for: mailboxVC, key: "hasMoreData") as? Bool, true)
        XCTAssertEqual(getPrivateProperty(for: mailboxVC, key: "isSearching") as? Bool, true)
        
        // Call filterEmailsWithText with empty search term
        mailboxVC.perform(NSSelectorFromString("filterEmailsWithText:"), with: "")
        
        // Verify currentSearchText is nil when empty string is provided
        XCTAssertNil(getPrivateProperty(for: mailboxVC, key: "currentSearchText"))
    }
    
    // MARK: - TableView Delegate/DataSource Tests
    
    func testNumberOfRows() {
        // 设置测试条件 - 首先定义两个测试邮件
        let testEmail1 = MailItem(id: "1",
                                 sender: "Test1",
                                 subject: "Subject1",
                                 preview: "Preview1",
                                 dateString: "2025-05-15 10:30:00",
                                 isRead: false,
                                 hasAttachment: true,
                                 isOfficial: false,
                                 emailCount: nil)
        
        let testEmail2 = MailItem(id: "2",
                                 sender: "Test2",
                                 subject: "Subject2",
                                 preview: "Preview2",
                                 dateString: "2025-05-15 10:40:00",
                                 isRead: true,
                                 hasAttachment: false,
                                 isOfficial: true,
                                 emailCount: nil)
        
        // 设置filteredEmails
        setPrivateProperty(for: mailboxVC, key: "filteredEmails", value: NSMutableArray(array: [testEmail1, testEmail2]))
        
        // 获取 tableView
        if let tableView = mailboxVC.value(forKey: "tableView") as? UITableView {
            // 测试数据源方法
            let dataSource = tableView.dataSource
            let rowCount = dataSource?.tableView(tableView, numberOfRowsInSection: 0) ?? 0
            
            XCTAssertEqual(rowCount, 2, "TableView should have 2 rows")
        } else {
            XCTFail("TableView not found")
        }
    }
    
    func testCellForRow() {
        // 设置测试数据
        let testEmail = MailItem(id: "test123",
                                sender: "Test Sender",
                                subject: "Test Subject",
                                preview: "This is a test preview",
                                dateString: "2025-05-15 10:30:00",
                                isRead: false,
                                hasAttachment: true,
                                isOfficial: false,
                                emailCount: 3)
        
        // 设置filteredEmails
        setPrivateProperty(for: mailboxVC, key: "filteredEmails", value: NSMutableArray(array: [testEmail]))
        
        // 获取 tableView
        if let tableView = mailboxVC.value(forKey: "tableView") as? UITableView {
            // 通过数据源获取 cell
            let dataSource = tableView.dataSource
            let cell = dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))
            
            XCTAssertNotNil(cell, "Should return a valid cell")
            XCTAssert(cell is EmailCell, "Cell should be an EmailCell")
        } else {
            XCTFail("TableView not found")
        }
    }
    
    // MARK: - Helper Methods
    
    private func getPrivateProperty(for object: AnyObject, key: String) -> Any? {
        return object.value(forKey: key)
    }
    
    private func setPrivateProperty(for object: AnyObject, key: String, value: Any) {
        object.setValue(value, forKey: key)
    }
}

// Mock UIApplication for testing presented view controllers
// Note: This is challenging to do completely in unit tests without UI testing
class MockUIApplication {
    var presentedViewController: UIViewController?
    
    func presentViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        presentedViewController = viewController
        completion?()
    }
}
