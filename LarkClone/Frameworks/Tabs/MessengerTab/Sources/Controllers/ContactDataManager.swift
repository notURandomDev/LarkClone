//
//  ContactDataManager.swift
//  Feishu-clone
//
//  Created by 张纪龙 on 2025/4/27.
//
import UIKit
import LarkSDK

class ContactDataManager {
    // 每页显示的联系人数量
    private let contactsPerPage = 20
    private var allContacts: [Contact] = []
    
    init() {
        // 尝试从plist文件加载联系人数据
        loadContactsFromPlist()
        // 尝试从rust侧加载联系人数据
        loadContactsFromRust()
    }
    
    // 从 Rust 获取联系人数据
    private func loadContactsFromRust() {
            // 获取 plist 文件路径
            guard let path = Bundle.main.path(forResource: "mock_contacts", ofType: "plist") else {
                print("无法找到 mock_contacts.plist 文件，加载默认联系人")
                allContacts = getDefaultContacts()
                sortContactsByTime()
                return
            }
            
            // 使用 RustBridge.fetchContactsAsync 获取联系人
            RustBridge.fetchContacts(page: 0, pageSize: 10000, filePath: path) { result in
                switch result {
                case .success(let larkContacts):
                    print("✅ 从 Rust 获取到 \(larkContacts.count) 个联系人")
                    // 将 Lark_Contact 转换为 Contact
                    self.allContacts = larkContacts.map { Contact.from(larkContact: $0) }
                    // 加载后对联系人按时间排序
                    self.sortContactsByTime()
                case .failure(let error):
                    print("❌ 从 Rust 获取联系人失败：\(error)")
                    // 失败时加载默认联系人
                    self.allContacts = self.getDefaultContacts()
                    self.sortContactsByTime()
                }
            }
        }
    
    // 从plist文件加载联系人数据
    private func loadContactsFromPlist() {
        // 尝试获取文件路径 - 先尝试从Bundle中读取
        if let path = Bundle.main.path(forResource: "mock_contacts", ofType: "plist") {
            loadFromPath(path)
        } else {
            // 如果Bundle中没有，直接fatal error
            fatalError("无法找到mock_contacts.plist文件")
        }
        
        // 加载后对联系人按时间排序
        sortContactsByTime()
    }
    
    private func loadFromPath(_ path: String) {
        do {
            // 从文件中读取数据
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            
            // 解码ContactData
            let decoder = PropertyListDecoder()
            let contactDataArray = try decoder.decode([ContactData].self, from: data)
            
            // 将ContactData转换为Contact模型
            self.allContacts = contactDataArray.map { Contact.from(contactData: $0) }
            
            print("成功从plist中加载了\(self.allContacts.count)个联系人")
        } catch {
            print("从plist加载联系人失败: \(error)")
        }
    }
    
    // 根据时间对联系人排序
    private func sortContactsByTime() {
        allContacts.sort { (contact1, contact2) -> Bool in
            return compareTime(time1: contact1.datetime, time2: contact2.datetime)
        }
    }
    
    // 比较两个时间字符串的先后顺序
    private func compareTime(time1: String, time2: String) -> Bool {
        // 将时间字符串转换为统一格式进行比较
        // 返回true表示time1更近（应该排在前面）
        
        // 定义时间优先级
        let getTimePriority = { (time: String) -> Int in
            if time.contains(":") && !time.contains("月") {
                return 4
            } else if time == "昨天" {
                return 3
            } else if time.contains("月") && time.contains("日") {
                return 2
            } else {
                return 1
            }
        }
        
        // 首先按优先级比较
        let priority1 = getTimePriority(time1)
        let priority2 = getTimePriority(time2)
        
        if priority1 != priority2 {
            return priority1 > priority2
        }
        
        // 如果优先级相同，进一步比较
        if priority1 == 4 {
            // 比较具体时间 (HH:MM)
            let components1 = time1.split(separator: ":")
            let components2 = time2.split(separator: ":")
            
            if components1.count == 2 && components2.count == 2,
               let hour1 = Int(components1[0]), let minute1 = Int(components1[1]),
               let hour2 = Int(components2[0]), let minute2 = Int(components2[1]) {
                
                if hour1 != hour2 {
                    return hour1 > hour2
                } else {
                    return minute1 > minute2
                }
            }
        } else if priority1 == 2 {
            //具体比较
            let components1 = time1.replacingOccurrences(of: "月", with: "-").replacingOccurrences(of: "日", with: "").split(separator: "-")
            let components2 = time2.replacingOccurrences(of: "月", with: "-").replacingOccurrences(of: "日", with: "").split(separator: "-")
            
            if components1.count == 2 && components2.count == 2,
               let month1 = Int(components1[0]), let day1 = Int(components1[1]),
               let month2 = Int(components2[0]), let day2 = Int(components2[1]) {
                
                if month1 != month2 {
                    return month1 > month2
                } else {
                    return day1 > day2
                }
            }
        }
        
        return false
    }
    
    // 获取指定页码的联系人
    func getContacts(page: Int) -> [Contact] {
        let startIndex = (page - 1) * contactsPerPage
        let endIndex = min(startIndex + contactsPerPage, allContacts.count)
        
        guard startIndex < allContacts.count else {
            return []
        }
        
        return Array(allContacts[startIndex..<endIndex])
    }
    
    // 获取总页数
    func getTotalPages() -> Int {
        return (allContacts.count + contactsPerPage - 1) / contactsPerPage
    }
    
    // plist加载失败时,默认信息
    func getDefaultContacts() -> [Contact] {
        return [
            Contact(
                avatar: UIImage(named: "meeting-assist"),
                name: "视频会议助手",
                latestMsg: "智能纪要：第一期线上课程分享《走进客户端》",
                datetime: "23:50",
                type: .bot
            ),
            Contact(
                avatar: UIImage(named: "yan-wenhua"),
                name: "严文华",
                latestMsg: "我接受了你的联系人申请，开始聊天吧！",
                datetime: "23:40",
                type: .external
            ),
            Contact(
                avatar: UIImage(named: "contact-assist"),
                name: "联系人助手",
                latestMsg: "联系人申请",
                datetime: "23:45",
                type: .bot
            ),
            Contact(
                avatar: UIImage(named: "xiao-kaiqin"),
                name: "肖凯琴",
                latestMsg: "我接受了你的联系人申请，开始聊天吧！",
                datetime: "23:35",
                type: .external
            ),
            Contact(
                avatar: UIImage(named: "su-peng"),
                name: "苏鹏",
                latestMsg: "我接受了你的联系人申请，开始聊天吧！",
                datetime: "23:25",
                type: .external
            )
        ]
    }
}
