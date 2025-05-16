//
//  GenerateMailsTests.swift
//  LarkClone
//
//  Created by 张纪龙 on 2025/5/16.
//
/*这个文件测试邮件生成器功能：
 测试EmailDataGenerator功能
 验证生成邮件的数量、字段
 测试邮件日期排序
 测试生成的内容合理性
*/

import XCTest
import UIKit
@testable import LarkClone

final class GenerateMailsTests: XCTestCase {
    
    var generator: EmailDataGenerator!
    
    override func setUp() {
        super.setUp()
        generator = EmailDataGenerator()
    }
    
    override func tearDown() {
        generator = nil
        super.tearDown()
    }
    
    // MARK: - Basic Tests
    
    func testGenerateEmailsCount() {
        // Test with different counts
        let count1 = 5
        let emails1 = generator.generateEmails(count: count1)
        XCTAssertEqual(emails1.count, count1, "Should generate exactly \(count1) emails")
        
        let count2 = 20
        let emails2 = generator.generateEmails(count: count2)
        XCTAssertEqual(emails2.count, count2, "Should generate exactly \(count2) emails")
        
        // Test default count (10000)
        // Note: For performance reasons in tests, we might not want to generate all 10000
        // Let's override the default in our test to a smaller number
        let defaultEmails = generator.generateEmails(count: 100) // Using 100 instead of default 10000
        XCTAssertEqual(defaultEmails.count, 100, "Should generate the specified number of emails")
    }
    
    func testEmailsHaveRequiredFields() {
        let emails = generator.generateEmails(count: 10)
        
        for (index, email) in emails.enumerated() {
            XCTAssertNotNil(email["id"], "Email at index \(index) should have an ID")
            XCTAssertNotNil(email["sender"], "Email at index \(index) should have a sender")
            XCTAssertNotNil(email["subject"], "Email at index \(index) should have a subject")
            XCTAssertNotNil(email["preview"], "Email at index \(index) should have a preview")
            XCTAssertNotNil(email["date"], "Email at index \(index) should have a date")
            XCTAssertNotNil(email["isRead"], "Email at index \(index) should have isRead status")
            XCTAssertNotNil(email["hasAttachment"], "Email at index \(index) should have hasAttachment status")
            XCTAssertNotNil(email["isOfficial"], "Email at index \(index) should have isOfficial status")
            
            // Check types
            XCTAssert(email["id"] is String, "ID should be a String")
            XCTAssert(email["sender"] is String, "Sender should be a String")
            XCTAssert(email["subject"] is String, "Subject should be a String")
            XCTAssert(email["preview"] is String, "Preview should be a String")
            XCTAssert(email["date"] is String, "Date should be a String")
            XCTAssert(email["isRead"] is Bool, "isRead should be a Bool")
            XCTAssert(email["hasAttachment"] is Bool, "hasAttachment should be a Bool")
            XCTAssert(email["isOfficial"] is Bool, "isOfficial should be a Bool")
            
            // Check emailCount if it exists
            if let emailCount = email["emailCount"] {
                XCTAssert(emailCount is Int, "emailCount should be an Int")
                XCTAssertGreaterThanOrEqual(emailCount as! Int, 2, "emailCount should be at least 2")
            }
        }
    }
    
    func testEmailDatesSorted() {
        let emails = generator.generateEmails(count: 50)
        
        // 创建日期格式化器
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for i in 0..<emails.count-1 {
            let dateStr1 = emails[i]["date"] as! String
            let dateStr2 = emails[i+1]["date"] as! String
            
            // 直接比较字符串 - 因为 "yyyy-MM-dd HH:mm:ss" 格式的字符串可以直接按字典序比较
            XCTAssertGreaterThanOrEqual(dateStr1, dateStr2, "Emails should be sorted with newest first")
            
            // 可选：仍然转换为日期并打印，帮助调试
            let date1 = dateFormatter.date(from: dateStr1)!
            let date2 = dateFormatter.date(from: dateStr2)!
            print("比较: \(dateStr1) (\(date1.timeIntervalSince1970)) 与 \(dateStr2) (\(date2.timeIntervalSince1970))")
        }
    }
    
    func testEmailContentRealistic() {
        let emails = generator.generateEmails(count: 100)
        
        // Test that there's a mix of read/unread emails
        let readEmails = emails.filter { ($0["isRead"] as! Bool) == true }
        let unreadEmails = emails.filter { ($0["isRead"] as! Bool) == false }
        
        XCTAssertGreaterThan(readEmails.count, 0, "There should be some read emails")
        XCTAssertGreaterThan(unreadEmails.count, 0, "There should be some unread emails")
        
        // Test that there's a mix of emails with and without attachments
        let withAttachments = emails.filter { ($0["hasAttachment"] as! Bool) == true }
        let withoutAttachments = emails.filter { ($0["hasAttachment"] as! Bool) == false }
        
        XCTAssertGreaterThan(withAttachments.count, 0, "There should be some emails with attachments")
        XCTAssertGreaterThan(withoutAttachments.count, 0, "There should be some emails without attachments")
        
        // Test that there's a mix of official and non-official emails
        let officialEmails = emails.filter { ($0["isOfficial"] as! Bool) == true }
        let nonOfficialEmails = emails.filter { ($0["isOfficial"] as! Bool) == false }
        
        XCTAssertGreaterThan(officialEmails.count, 0, "There should be some official emails")
        XCTAssertGreaterThan(nonOfficialEmails.count, 0, "There should be some non-official emails")
        
        // Check that some emails have emailCount
        let withEmailCount = emails.filter { $0["emailCount"] != nil }
        XCTAssertGreaterThan(withEmailCount.count, 0, "There should be some emails with emailCount")
    }
    
    func testGenerateRealisticDate() {
        // We're testing a private method, so we'll check its effects indirectly
        let emails = generator.generateEmails(count: 100)
        let currentDate = Date()
        let calendar = Calendar.current
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for email in emails {
            let dateStr = email["date"] as! String
            let emailDate = dateFormatter.date(from: dateStr)!
            
            // Check that the date is not in the future
            XCTAssertLessThanOrEqual(emailDate, currentDate, "Email date should not be in the future")
            
            // Check that the date is not more than 90 days in the past
            let components = calendar.dateComponents([.day], from: emailDate, to: currentDate)
            let daysDifference = components.day!
            XCTAssertLessThanOrEqual(daysDifference, 90, "Email date should not be more than 90 days in the past")
            
            // Check that weekend hours are between 10-17
            let weekday = calendar.component(.weekday, from: emailDate)
            let hour = calendar.component(.hour, from: emailDate)
            
            if weekday == 1 || weekday == 7 { // Weekend (Sunday is 1, Saturday is 7)
                XCTAssertGreaterThanOrEqual(hour, 10, "Weekend email hours should be after 10 AM")
                XCTAssertLessThanOrEqual(hour, 17, "Weekend email hours should be before 5 PM")
            }
        }
    }
}
