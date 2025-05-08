//
//  GenerateContactData.swift
//  Feishu-clone
//
//  Created by 张纪龙 on 2025/4/27.
//

import Foundation

// 这个脚本用于生成联系人数据并保存到plist文件中
// 可以单独运行这个文件来生成mock_contacts.plist

//enum ContactType: String {
//    case user = "user"
//    case bot = "bot"
//    case external = "external"
//}

// 基于当前时间生成的随机时间字符串
func generateRandomTime() -> String {
    let now = Date()
    let calendar = Calendar.current
    
    // 随机选择时间类型 - 不再生成"未来"的时间
    let timeType = Int.random(in: 0...5)
    
    switch timeType {
    case 0:
        // 刚刚/几分钟前 (0-30分钟)
        let minutesAgo = Int.random(in: 0...30)
        if minutesAgo < 3 {
            return "刚刚"
        } else {
            return "\(minutesAgo)分钟前"
        }
        
    case 1:
        // 今天的早些时间 (确保不会生成"未来"的时间)
        // 获取当前小时和分钟
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        
        // 随机生成早于当前时间的今天时间
        let maxMinutesPassed = currentHour * 60 + currentMinute // 今天到目前为止经过的总分钟数
        let randomMinutesPassed = Int.random(in: 1...max(1, maxMinutesPassed - 1))
        let randomHour = randomMinutesPassed / 60
        let randomMinute = randomMinutesPassed % 60
        
        // 格式化为24小时制的时间字符串 (HH:MM)
        return String(format: "%02d:%02d", randomHour, randomMinute)
        
    case 2:
        // 昨天
        return "昨天"
        
    case 3:
        // 最近一周内
        let daysAgo = Int.random(in: 2...6)
        let randomDay = calendar.date(byAdding: .day, value: -daysAgo, to: now)!
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日"
        return formatter.string(from: randomDay)
        
    case 4:
        // 本月内的较早日期
        let daysAgo = Int.random(in: 7...20)
        let randomDay = calendar.date(byAdding: .day, value: -daysAgo, to: now)!
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日"
        return formatter.string(from: randomDay)
        
    case 5:
        // 更早的日期
        let daysAgo = Int.random(in: 21...60)
        let randomDay = calendar.date(byAdding: .day, value: -daysAgo, to: now)!
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日"
        return formatter.string(from: randomDay)
        
    default:
        return "刚刚"
    }
}

// 生成随机联系人数据
func generateRandomContacts(count: Int) -> [ContactData] {
    // 随机姓名 - 用于普通用户
    let names = ["张三", "李四", "王五", "赵六", "钱七", "孙八", "周九", "吴十",
                "郑十一", "冯十二", "陈十三", "楚十四", "魏十五", "蒋十六", "沈十七", "韩十八",
                "沈十七", "魏十八"]
    
    // 随机消息
    let messages = ["你好，最近怎么样？", "明天开会别忘了带文件", "已收到，谢谢", "请问这个问题解决了吗？",
                   "稍等，我马上回复你", "好的，没问题", "周五晚上有空吗？", "这个方案我很满意",
                   "麻烦再确认一下日期", "文档我已经发到你邮箱了", "需要我帮忙吗？", "辛苦了！"]
    
    // 特殊联系人 - 每个特殊联系人只出现一次，且有固定的消息
    let specialContacts: [(name: String, avatarName: String, type: ContactType, message: String)] = [
        ("账号安全中心", "account-assist", .bot, "您的账号已完成安全检查"),
        ("联系人助手", "contact-assist", .bot, "您有新的联系人申请"),
        ("飞书训练营", "group1", .user, "欢迎加入飞书训练营！"),
        ("南杭队", "group2", .user, "团队会议将在明天下午3点开始"),
        ("视频会议助手", "meeting-assist", .bot, "智能纪要：第一期线上课程分享《走进客户端》"),
        ("云文档助手", "doc-assist", .bot, "您有新共享文档需要查看")
    ]
    
    // 头像名称
    let userAvatars = ["cao-wenlong", "li-jianhao", "zhang-jilong"]
    let externalAvatars = ["jiang-yuan", "liang-weixi", "su-peng", "wang-xun", "xiao-kaiqin", "yan-wenhua"]
    
    // 生成随机联系人
    var contacts: [ContactData] = []
    
    // 1. 首先添加特殊联系人 - 只添加一次，时间设置为较近的时间确保它们显示在前面
    for special in specialContacts {
        // 为特殊联系人生成较近的时间，确保它们出现在列表前面
        var datetime: String
        let minutesAgo = Int.random(in: 1...15)
        if minutesAgo < 3 {
            datetime = "刚刚"
        } else {
            // 获取当前时间
            let now = Date()
            let calendar = Calendar.current
            let currentHour = calendar.component(.hour, from: now)
            let currentMinute = calendar.component(.minute, from: now)
            
            // 确保时间在当前时间或稍早
            let adjustedMinute = max(0, currentMinute - minutesAgo)
            datetime = String(format: "%02d:%02d", currentHour, adjustedMinute)
        }
        
        let contact = ContactData(
            name: special.name,
            avatarName: special.avatarName,
            latestMsg: special.message,
            datetime: datetime,
            type: special.type.rawValue
        )
        
        contacts.append(contact)
    }
    
    // 2. 然后添加足够的随机联系人，确保类型与头像匹配
    for _ in specialContacts.count..<count {
        // 生成基于当前时间的随机时间字符串
        let datetime = generateRandomTime()
        
        // 随机联系人类型
        let typeRandom = Int.random(in: 1...10)
        let type: ContactType
        let avatarName: String
        let name: String = names.randomElement()!
        
        if typeRandom <= 6 {
            // 用户类型 - 使用用户头像
            type = .user
            avatarName = userAvatars.randomElement()!
        } else {
            // 外部类型 - 使用外部头像
            type = .external
            avatarName = externalAvatars.randomElement()!
        }
        
        // 创建联系人
        let contact = ContactData(
            name: name,
            avatarName: avatarName,
            latestMsg: messages.randomElement()!,
            datetime: datetime,
            type: type.rawValue
        )
        
        contacts.append(contact)
    }
    
    return contacts
}

// 将联系人数据保存到plist文件
func saveContactsToPlist(contacts: [ContactData], filename: String) {
    let encoder = PropertyListEncoder()
    encoder.outputFormat = .xml
    
    do {
        let data = try encoder.encode(contacts)
        
        // 直接保存到项目目录中，与Info.plist同级
        let projectPath = "/Users/zhangjilong/Documents/xcode_code/Feishu-clone1/Feishu-clone"
        let fileURL = URL(fileURLWithPath: projectPath).appendingPathComponent(filename)
        
        try data.write(to: fileURL)
        print("成功将联系人数据保存到: \(fileURL.path)")
        print("文件已保存到项目目录中，与Info.plist同级")
    } catch {
        print("保存联系人数据失败: \(error)")
    }
}

struct Script {
    static func main() {
        // 生成10000个随机联系人
        let randomContacts = generateRandomContacts(count: 10000)
        
        // 保存到plist文件
        saveContactsToPlist(contacts: randomContacts, filename: "mock_contacts.plist")
    }
}
