//
//  GenerateMails.swift
//  LarkClone
//
//  Created by 张纪龙 on 2025/5/10.

import Foundation

class EmailDataGenerator {
    private let regularSenders = [
        "张纪龙", "黄子烨", "苏鹏", "蒋元",
        "严文华", "王恂", "肖凯琴", "张文智",
        "曹文龙", "厉剑豪", "孙煜海", "梁惟熙",
        "林俊杰", "梁静茹", "赵丽颖", "彭于晏",
        "刘亦菲", "周杰伦", "吴彦祖", "杨幂"
    ]
    
    private let specialSenders = [
        "ByteTech官方公共邮箱", "系统服务", "安全中心",
        "DeveloperCenter Shanghai", "The Postman Team", "kodeco.com",
        "Apple Developer", "Google Cloud", "Microsoft Azure",
        "技术支持", "人事部门", "财务部门"
    ]
    
    private let subjectPrefixes = [
        "会议通知", "项目进度", "新产品", "系统升级", "安全警告",
        "团队建设", "培训邀请", "性能优化", "代码审查", "版本发布",
        "需求讨论", "Bug修复", "数据分析", "用户反馈", "架构设计",
        "接口文档", "测试报告", "上线通知", "故障处理", "技术分享",
        "[External]", "v7.44", "v7.43"
    ]
    
    private let subjectSuffixes = [
        "- 紧急", "- 本周", "- 下周", "- 月报", "- 季度总结",
        "- 重要提醒", "- 请查收", "- 需确认", "- 已完成", "- 进行中",
        "- v7.44", "- v7.43", "- 第一版", "- 最终版", "- 修订版",
        "- 东京", "- 上海", "- 北京", "- 深圳", "- 线上",
        "- 内部", "- 公开", "- 机密", "- 草稿", "- 定稿",
        " | Lark IM & AI Architecture & UI",
        " Postman API Night 東京のご案内",
        " Reset password instructions",
        " Apple 开发者官方微信公众号现已上线",
        " 您有一张增值税专用发票"
    ]
    
    private let previewTexts = [
        "会议将在下午3点在会议室A举行，请准时参加...",
        "本月项目进展顺利，预计按时完成交付...",
        "新产品即将在下周正式发布，敬请期待...",
        "系统将在本周末进行维护，预计影响时间为2小时...",
        "发现您的账户有异常登录，请及时修改密码...",
        "团队建设活动安排在下周五，地点在公司附近...",
        "月度绩效评估已完成，请查看详细报告...",
        "技能培训课程现已开放报名，名额有限...",
        "最新版本已经发布，包含以下重要更新...",
        "用户反馈收集完毕，需要优先处理的问题包括...",
        "代码审查发现如下问题，请及时修复...",
        "性能测试报告显示，系统响应时间有所改善...",
        "架构重构计划已经启动，预计完成时间为...",
        "接口文档更新完毕，新增API详情请查看...",
        "上线变更通知：以下功能将在今晚部署...",
        "故障已经修复，服务已恢复正常...",
        "技术分享会定于下周四下午举行...",
        "需求文档已经更新，请相关同事查阅...",
        "测试用例覆盖率已达到90%以上...",
        "安全漏洞已经修复，建议立即更新...",
        "Dear ByteDancers, ByteTech 本周为你精选了...",
        "一、版本时间信息 节点 时间 排人会议 2025/04...",
        "[Lark IM & Product Architecture & AI Arch v7...",
        "",
        "[图片] Hello supeng.charlie@bytedance.com! ...",
        "[图片] 尊敬的客户，您好：北京钟爱纯粹自然...",
        "尊敬的开发者，我们是 Apple 全球开发者关系团队..."
    ]
    
    func generateEmails(count: Int = 10000) -> [[String: Any]] {
        var emails: [[String: Any]] = []
        let currentTime = Date()
        
        // 添加固定的测试数据
        let fixedEmails = createFixedEmails()
        emails.append(contentsOf: fixedEmails)
        
        // 生成特殊发件人的邮件
        for specialSender in specialSenders {
            let email = createEmail(
                id: UUID().uuidString,
                sender: specialSender,
                isOfficial: true,
                timestamp: generateRandomDate(relativeTo: currentTime)
            )
            emails.append(email)
        }
        
        // 生成普通邮件
        for _ in emails.count..<count {
            let sender = regularSenders.randomElement()!
            let timestamp = generateRandomDate(relativeTo: currentTime)
            let email = createEmail(
                id: UUID().uuidString,
                sender: sender,
                isOfficial: false,
                timestamp: timestamp
            )
            emails.append(email)
        }
        
        // 按时间倒序排序
        let sortedEmails = emails.sorted {
            let date1 = ($0["date"] as? String) ?? ""
            let date2 = ($1["date"] as? String) ?? ""
            return date1 > date2
        }
        
        return sortedEmails
    }
    
    private func createFixedEmails() -> [[String: Any]] {
        return [
            [
                "id": "1",
                "sender": "ByteTech 官方公共邮箱",
                "subject": "ByteTech | MCP x 业务: 达人选品 AI Agent 简易版发布",
                "preview": "Dear ByteDancers, ByteTech 本周为你精选了...",
                "date": "2025-05-09 10:50:00",
                "isRead": false,
                "hasAttachment": false,
                "isOfficial": true
            ],
            [
                "id": "2",
                "sender": "张纪龙",
                "subject": "v7.44 版本启动邮件 - Lark IM & AI Architecture & UI",
                "preview": "一、版本时间信息 节点 时间 排人会议 2025/04...",
                "date": "2025-04-25 14:30:00",
                "isRead": true,
                "hasAttachment": false,
                "isOfficial": false
            ],
            [
                "id": "3",
                "sender": "乔子铭",
                "subject": "v7.43 版本启动邮件 - Lark IM & AI Architecture & UI",
                "preview": "[Lark IM & Product Architecture & AI Arch v7...",
                "date": "2025-04-25 12:15:00",
                "isRead": true,
                "hasAttachment": false,
                "isOfficial": false,
                "emailCount": 2
            ],
            [
                "id": "4",
                "sender": "The Postman Team",
                "subject": "[External] Postman API Night 東京のご案内",
                "preview": "",
                "date": "2025-04-25 09:40:00",
                "isRead": true,
                "hasAttachment": false,
                "isOfficial": false
            ],
            [
                "id": "5",
                "sender": "kodeco.com",
                "subject": "[External] Reset password instructions",
                "preview": "[图片] Hello supeng.charlie@bytedance.com! ...",
                "date": "2025-04-24 16:50:00",
                "isRead": true,
                "hasAttachment": true,
                "isOfficial": false,
                "emailCount": 2
            ],
            [
                "id": "6",
                "sender": "系统服务",
                "subject": "[External] 您有一张来自【北京钟爱纯粹自然餐饮有限公司】的增值税专用发票",
                "preview": "[图片] 尊敬的客户，您好：北京钟爱纯粹自然...",
                "date": "2025-04-24 13:20:00",
                "isRead": true,
                "hasAttachment": true,
                "isOfficial": false
            ],
            [
                "id": "7",
                "sender": "DeveloperCenter Shanghai",
                "subject": "[External] Apple 开发者官方微信公众号现已上线",
                "preview": "尊敬的开发者，我们是 Apple 全球开发者关系团队...",
                "date": "2025-04-24 10:15:00",
                "isRead": true,
                "hasAttachment": false,
                "isOfficial": false
            ]
        ]
    }
    
    private func createEmail(id: String, sender: String, isOfficial: Bool, timestamp: Date) -> [String: Any] {
        let subjectPrefix = subjectPrefixes.randomElement()!
        let subjectSuffix = subjectSuffixes.randomElement()!
        let subject = "\(subjectPrefix)\(subjectSuffix)"
        
        let preview = previewTexts.randomElement()!
        let hasAttachment = Bool.random()
        let isRead = Double.random(in: 0...1) < 0.7
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: timestamp)
        
        var email: [String: Any] = [
            "id": id,
            "sender": sender,
            "subject": subject,
            "preview": preview,
            "date": dateString,
            "isRead": isRead,
            "hasAttachment": hasAttachment,
            "isOfficial": isOfficial
        ]
        
        // 随机添加 emailCount
        if Double.random(in: 0...1) < 0.2 {
            email["emailCount"] = Int.random(in: 2...10)
        }
        
        return email
    }
    
    private func generateRandomDate(relativeTo currentDate: Date) -> Date {
        let calendar = Calendar.current
        let randomDays = Int.random(in: -90...0)
        let randomHours = Int.random(in: 0...23)
        let randomMinutes = Int.random(in: 0...59)
        let randomSeconds = Int.random(in: 0...59)
        
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
        dateComponents.day! += randomDays
        dateComponents.hour = randomHours
        dateComponents.minute = randomMinutes
        dateComponents.second = randomSeconds
        
        return calendar.date(from: dateComponents) ?? currentDate
    }
}

// 需要解除依赖
GenerateEmails.main()

struct GenerateEmails {
    static func main() {
        print("开始生成邮件数据...")
        
        let generator = EmailDataGenerator()
        let emails = generator.generateEmails(count: 10000)
        
        // 正确的相对路径：从Scripts文件夹到MockData文件夹
        let outputPath = "../../Resources/MockData/mock_emails.plist"
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
            
            // 将数据转换为 plist 格式
            let plistData = try PropertyListSerialization.data(
                fromPropertyList: emails,
                format: .xml,
                options: 0
            )
            
            // 写入文件
            try plistData.write(to: URL(fileURLWithPath: outputPath))
            print("文件写入成功：\(outputPath)")
            
            // 简单验证文件是否成功创建
            if FileManager.default.fileExists(atPath: outputPath) {
                // 成功创建文件
                let attributes = try FileManager.default.attributesOfItem(atPath: outputPath)
                if let fileSize = attributes[.size] as? Int64, fileSize > 0 {
                    // 文件大小正常
                    print("文件创建成功，大小：\(fileSize) 字节")
                }
            } else {
                // 文件未创建成功
                print("错误：文件未创建成功")
                exit(1)
            }
        } catch {
            // 出现错误
            print("错误：\(error)")
            print("详细信息：\(error.localizedDescription)")
            exit(1)
        }
        
        print("邮件数据生成完成")
    }
}
