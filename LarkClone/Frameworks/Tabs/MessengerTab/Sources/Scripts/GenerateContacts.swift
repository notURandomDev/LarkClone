//
//  GenerateContacts.swift
//  Feishu-clone
//
//  Created by 张纪龙 on 2025/4/27.
//

import Foundation

// 这个脚本用于生成联系人数据并保存到plist文件中
// 单独运行这个文件来生成mock_contacts.plist

enum ScriptContactType: String {
    case user = "user"
    case bot = "bot"
    case external = "external"
}

struct ScriptContactData: Codable {
    let name: String
    let avatarName: String
    let latestMsg: String
    let datetime: String
    let type: String
}

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

// 生成随机姓名
func generateRandomName() -> String {
    // 常用姓氏
    let familyNames = ["王", "李", "张", "刘", "陈", "杨", "赵", "黄", "周", "吴",
                       "徐", "孙", "马", "朱", "胡", "林", "郭", "何", "高", "罗",
                       "郑", "梁", "谢", "宋", "唐", "许", "邓", "冯", "韩", "曹"]
    
    // 常用名字
    let givenNames = ["伟", "芳", "娜", "秀英", "敏", "静", "丽", "强", "磊", "军",
                     "洋", "勇", "艳", "杰", "娟", "涛", "明", "超", "秀兰", "霞",
                     "平", "刚", "桂英", "英", "华", "俊", "文", "云", "建华", "建国",
                     "欣怡", "雪", "旭", "宇", "荣", "健", "志", "嘉", "佳","泽楷"]
    
    let familyName = familyNames.randomElement()!
    let givenName = givenNames.randomElement()!
    
    return familyName + givenName
}

// 生成随机消息
func generateRandomMessage() -> String {
    // 消息模板
    let messageTemplates = [
        "关于%@的事情，你怎么看？",
        "下午%02d:%02d的会议别忘了",
        "能帮我确认一下%@的进度吗？",
        "%@文件我已经发到你邮箱了",
        "周末有空一起%@吗？",
        "这个%@方案我觉得很不错",
        "需要我协助处理%@的问题吗？",
        "早上好！%@的报告准备得怎么样了？",
        "请查收%@的最新版本",
        "刚才开会讨论的%@事项，你有什么想法？"
    ]
    
    // 填充词
    let fillers = ["项目", "产品", "设计", "开发", "聚餐", "看电影", "讨论",
                  "测试", "报告", "方案", "数据", "文档", "计划", "培训", "会议"]
    
    // 基本消息
    let basicMessages = [
        "你好，最近怎么样？",
        "已收到，谢谢",
        "好的，没问题",
        "这个方案我很满意",
        "辛苦了！",
        "有时间聊一下吗？",
        "一切顺利",
        "谢谢你的帮助"
    ]
    
    // 70%概率使用模板消息，30%概率使用基本消息
    if Int.random(in: 1...10) <= 7 {
        let template = messageTemplates.randomElement()!
        let filler = fillers.randomElement()!
        
        if template.contains("%02d:%02d") {
            // 处理时间格式的模板
            let hour = Int.random(in: 13...17) // 下午1点到5点
            let minute = Int.random(in: 0...59)
            return String(format: template, hour, minute)
        } else {
            // 处理普通替换的模板
            return String(format: template, filler)
        }
    } else {
        return basicMessages.randomElement()!
    }
}

// 生成随机联系人数据
func generateRandomContacts(count: Int) -> [ScriptContactData] {
    // 头像名称
    let userAvatars = ["cao-wenlong", "li-jianhao", "zhang-jilong"]
    let externalAvatars = ["jiang-yuan", "liang-weixi", "su-peng", "wang-xun", "xiao-kaiqin", "yan-wenhua"]
    
    // 特殊联系人 - 每个特殊联系人只出现一次，且有固定的消息
    let specialContacts: [(name: String, avatarName: String, type: ScriptContactType, message: String)] = [
        ("账号安全中心", "account-assist", .bot, "您的账号已完成安全检查"),
        ("联系人助手", "contact-assist", .bot, "您有新的联系人申请"),
        ("飞书训练营", "group1", .user, "欢迎加入飞书训练营！"),
        ("南杭队", "group2", .user, "团队会议将在明天下午3点开始"),
        ("视频会议助手", "meeting-assist", .bot, "智能纪要：第一期线上课程分享《走进客户端》"),
        ("云文档助手", "doc-assist", .bot, "您有新共享文档需要查看")
    ]
    
    // 生成随机联系人
    var contacts: [ScriptContactData] = []
    
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
        
        let contact = ScriptContactData(
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
        let type: ScriptContactType
        let avatarName: String
        let name: String = generateRandomName()
        
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
        let contact = ScriptContactData(
            name: name,
            avatarName: avatarName,
            latestMsg: generateRandomMessage(),
            datetime: datetime,
            type: type.rawValue
        )
        
        contacts.append(contact)
    }
    
    return contacts
}

// 将联系人数据保存到plist文件
func saveContactsToPlist(contacts: [ScriptContactData], filename: String) {
    // 正确的相对路径：从Scripts文件夹到MockData文件夹
    let outputPath = "../../Resources/MockData/\(filename)"
    print("输出路径：\(outputPath)")
    
    // 获取当前工作目录
    let currentPath = FileManager.default.currentDirectoryPath
    print("当前工作目录：\(currentPath)")
    
    do {
        // 确保目录存在
        let directoryPath = URL(fileURLWithPath: outputPath).deletingLastPathComponent()
        print("目标目录：\(directoryPath.path)")
        
        try FileManager.default.createDirectory(
            at: directoryPath,
            withIntermediateDirectories: true,
            attributes: nil
        )
        print("目录创建成功")
        
        // 将数据编码为 plist 格式
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let plistData = try encoder.encode(contacts)
        
        // 写入文件
        try plistData.write(to: URL(fileURLWithPath: outputPath))
        print("文件写入成功：\(outputPath)")
        
        // 简单验证文件是否成功创建
        if FileManager.default.fileExists(atPath: outputPath) {
            let attributes = try FileManager.default.attributesOfItem(atPath: outputPath)
            if let fileSize = attributes[.size] as? Int64, fileSize > 0 {
                print("文件创建成功，大小：\(fileSize) 字节")
            }
        } else {
            print("错误：文件未创建成功")
            exit(1)
        }
    } catch {
        print("错误：\(error)")
        print("详细信息：\(error.localizedDescription)")
        exit(1)
    }
}

// 主函数
func main() {
    print("开始生成联系人数据...")
    
    // 生成10000个随机联系人
    let randomContacts = generateRandomContacts(count: 10000)
    
    // 保存到plist文件
    saveContactsToPlist(contacts: randomContacts, filename: "mock_contacts.plist")
    
    print("联系人数据生成完成")
}

// 运行主函数
main()
