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
        // 获取更大的样本量以提高统计可靠性
        let emails = generator.generateEmails(count: 200)
        let currentDate = Date()
        let calendar = Calendar.current
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        // 用于记录统计信息
        var weekendEmails = 0
        var weekendEmailsWithinHours = 0
        var allHours = [Int]()
        
        for email in emails {
            let dateStr = email["date"] as! String
            guard let emailDate = dateFormatter.date(from: dateStr) else {
                XCTFail("无法解析日期: \(dateStr)")
                continue
            }
            
            // 检查日期是否在过去（不在未来）
            XCTAssertLessThanOrEqual(emailDate, currentDate, "Email date should not be in the future")
            
            // 检查日期不超过90天
            let components = calendar.dateComponents([.day], from: emailDate, to: currentDate)
            guard let daysDifference = components.day else {
                XCTFail("无法计算日期差异")
                continue
            }
            XCTAssertLessThanOrEqual(daysDifference, 90, "Email date should not be more than 90 days in the past")
            
            // 检查周末邮件时间分布
            let weekday = calendar.component(.weekday, from: emailDate)
            let hour = calendar.component(.hour, from: emailDate)
            
            // 收集所有小时以查看分布
            allHours.append(hour)
            
            // 如果是周末（周六或周日）
            if weekday == 1 || weekday == 7 {
                weekendEmails += 1
                
                // 记录在期望时间范围内的周末邮件数量
                if hour >= 8 && hour <= 17 {
                    weekendEmailsWithinHours += 1
                }
            }
        }
        
        if weekendEmails > 0 {
            let percentage = Double(weekendEmailsWithinHours) / Double(weekendEmails)
            print("在工作时间范围内的周末邮件比例: \(percentage * 100)%")
            
            // 统计所有小时的分布
            var hourDistribution = [Int: Int]()
            for hour in allHours {
                hourDistribution[hour] = (hourDistribution[hour] ?? 0) + 1
            }
            
            // 排序打印小时分布
            let sortedHours = hourDistribution.keys.sorted()
            print("小时分布:")
            for hour in sortedHours {
                print("  \(hour)点: \(hourDistribution[hour]!)封")
            }
            
            // 测试至少有60%的周末邮件在合理的工作时间范围内（8-17点）
            XCTAssertGreaterThanOrEqual(percentage, 0.6, "至少60%的周末邮件应该在8-17点范围内")
        } else {
            print("警告：样本中没有周末邮件")
        }
    }
}
