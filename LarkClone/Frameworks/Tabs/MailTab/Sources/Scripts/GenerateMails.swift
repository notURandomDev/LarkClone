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
        "赵丽颖", "周杰伦", "吴彦祖", "彭于晏",
        "刘亦菲", "林俊杰", "杨幂", "李易峰"
    ]
    
    // 普通主题与对应的预览内容对映射
    private let regularSubjectPreviewPairs: [(subject: String, preview: String)] = [
        ("会议通知", "会议将在下午3点在会议室A举行，请准时参加并做好相关准备工作，会议预计持续2小时..."),
        ("项目进度", "本月项目进展顺利，预计按时完成交付，详情请查看附件中的进度报告和相关文档说明..."),
        ("新产品发布", "新产品即将在下周正式发布，敬请期待，发布会将在线上进行，欢迎所有团队成员参与..."),
        ("团队建设", "团队建设活动安排在下周五，地点在公司附近的文化中心，请提前安排好工作确保能够参加..."),
        ("技术分享", "技术分享会定于下周四下午举行，主题为前端性能优化，欢迎相关同事参加并进行技术交流..."),
        ("版本启动", "一、版本时间信息 节点 时间 排人会议 2025/04/20 排期会议 2025/04/25 开发截止 2025/05/15..."),
        ("用户反馈", "用户反馈收集完毕，需要优先处理的问题包括页面加载缓慢、按钮点击无响应和数据不同步..."),
        ("代码审查", "代码审查发现如下问题，请及时修复：1. 内存泄漏 2. 异步回调处理不当 3. 缺少异常处理..."),
        ("性能优化", "性能测试报告显示，系统响应时间有所改善，但仍有优化空间，特别是在高并发场景下..."),
        ("架构设计", "架构重构计划已经启动，预计完成时间为下个季度末，第一阶段将专注于后端服务解耦..."),
        ("接口文档", "接口文档更新完毕，新增API详情请查看附件，有任何疑问请在群里提出或直接联系我..."),
        ("上线通知", "上线变更通知：以下功能将在今晚部署，请相关测试同事做好验证准备，如有问题随时回滚..."),
        ("测试报告", "测试用例覆盖率已达到90%以上，但仍有部分边缘场景需要补充，请各模块负责人跟进..."),
        ("需求讨论", "关于新功能的需求讨论安排在明天下午，请产品、设计和开发人员准备相关材料参会..."),
        ("Bug修复", "本周修复了多个关键Bug，详情请查看附件中的清单，如发现任何问题请及时反馈..."),
        ("数据分析", "根据上月数据分析，用户活跃度提升了15%，详细报告已附上，请查阅并提出改进建议..."),
        ("开发计划", "下个季度的开发计划已经制定，主要聚焦于核心功能优化和体验提升，详情见附件..."),
        ("功能迭代", "产品功能迭代计划已确定，本月将重点增强用户体验和性能优化，详情请查看附件...")
    ]
    
    private let specialSenders = [
        "ByteTech公共邮箱", "系统服务", "安全中心",
        "DeveloperCenter", "Postman团队", "Kodeco平台",
        "Apple开发者", "Google Cloud", "Microsoft团队",
        "技术支持", "人事部门", "财务部门"
    ]
    
    // 特殊发件人与对应内容的映射
    private let specialSenderContentMap: [String: [(subject: String, preview: String)]] = [
        "安全中心": [
            ("安全警告", "发现您的账户有异常登录，请及时修改密码并开启二次验证，如有疑问请联系安全团队..."),
            ("安全更新", "安全漏洞已经修复，建议立即更新到最新版本，详细的漏洞信息和修复方案请参考附件..."),
            ("账号验证", "请注意，您的账号需要进行安全验证，请在24小时内完成，否则部分功能可能受到限制...")
        ],
        "财务部门": [
            ("报销通知", "您的报销申请已审核通过，款项将在3个工作日内打入您的银行账户，如有疑问请联系财务..."),
            ("工资条", "您的本月工资条已生成，请查看附件了解详细信息，如有异议请在本周内联系财务部门..."),
            ("财务报表", "第二季度财务报表已生成，请各部门负责人查收并做好相关分析工作，下周一会进行讨论...")
        ],
        "人事部门": [
            ("入职通知", "欢迎新同事加入团队，请大家做好相关准备工作，入职指南已发送至邮箱，请及时查收..."),
            ("绩效评估", "本季度绩效评估即将开始，请各位同事做好准备，相关评估表格已发送至各部门负责人..."),
            ("福利政策", "公司福利政策有所调整，新的政策将从下月起实施，详情请查看附件了解具体变更内容...")
        ],
        "系统服务": [
            ("系统升级", "系统将在本周末进行维护，预计影响时间为2小时，届时部分服务可能暂时不可用，请提前做好准备..."),
            ("账号提醒", "您的密码将在7天后过期，请及时修改密码，新密码应包含数字、字母和特殊字符，长度不少于8位..."),
            ("专用发票", "尊敬的客户，您好：北京钟爱纯粹自然餐饮有限公司已为您开具了一张增值税专用发票...")
        ],
        "技术支持": [
            ("故障处理", "故障已经修复，服务已恢复正常，详细原因分析和解决方案请参考附件中的故障报告..."),
            ("服务状态", "我们监测到部分服务响应缓慢，技术团队正在紧急处理，预计在1小时内恢复正常，请耐心等待..."),
            ("技术咨询", "收到您的技术咨询，针对您提出的问题，我们的技术专家已给出详细解答，请查看附件...")
        ],
        "ByteTech公共邮箱": [
            ("达人选品", "Dear ByteDancers, ByteTech 本周为你精选了以下内容：1. 达人选品 AI Agent 简易版发布..."),
            ("技术分享", "ByteTech技术沙龙将在本周五举行，主题为AI大模型应用实践，欢迎各位同事踊跃参加..."),
            ("产品发布", "ByteTech旗下产品线新版本即将发布，多项核心功能得到优化，具体发布时间请关注后续通知...")
        ],
        "DeveloperCenter": [
            ("API更新", "我们的API接口有重要更新，请查看文档了解变更详情，如有兼容性问题请及时联系技术支持..."),
            ("开发指南", "最新版本的开发指南已发布，包含多项最佳实践和示例代码，请访问开发者中心获取..."),
            ("平台通知", "尊敬的开发者，我们是 Apple 全球开发者关系团队，诚邀您关注我们的官方微信公众号...")
        ],
        "Postman团队": [
            ("培训邀请", "诚邀您参加下周的产品培训，我们将详细介绍新功能的使用方法和最佳实践，请准时出席..."),
            ("新功能发布", "Postman平台新功能已上线，支持更强大的API测试和文档生成能力，欢迎体验并反馈..."),
            ("活动通知", "亲爱的用户，我们诚挚邀请您参加即将在东京举办的 Postman API Night 活动...")
        ],
        "Kodeco平台": [
            ("课程更新", "您关注的课程有更新，最新章节已上线，请登录查看学习，如有问题可随时联系客服..."),
            ("账号安全", "Hello supeng.charlie@bytedance.com! 您最近请求重置密码，请点击下面的链接完成操作..."),
            ("订阅通知", "您的Kodeco订阅即将到期，为了不影响您的学习，请及时续费，现有多种优惠方案可供选择...")
        ],
        "Apple开发者": [
            ("平台更新", "尊敬的开发者，我们是 Apple 全球开发者关系团队，诚邀您关注我们的官方微信公众号..."),
            ("WWDC邀请", "WWDC即将到来，我们诚挚邀请您参加线上或线下活动，体验最新的技术和产品更新..."),
            ("审核通知", "您提交的应用已通过审核，现在可以在App Store上架，请登录开发者账号查看详情...")
        ],
        "Google Cloud": [
            ("服务更新", "Google Cloud平台新增多项功能，提升了安全性和性能，详情请查看更新日志..."),
            ("账单通知", "您的上月云服务账单已生成，请登录控制台查看详情并完成付款，当前有多重优惠可用..."),
            ("配额调整", "根据您的使用情况，我们建议调整服务配额，可能帮助您优化成本和性能，详情请查看附件...")
        ],
        "Microsoft团队": [
            ("许可证更新", "您的Microsoft产品许可证即将到期，请及时续订以确保服务不受影响，现有多种套餐可供选择..."),
            ("安全公告", "Microsoft发布了重要安全更新，修复了多个高危漏洞，建议您尽快更新系统和应用程序..."),
            ("产品邀请", "诚邀您参与Microsoft新产品的早期测试，您将能够抢先体验最新功能并提供宝贵意见...")
        ]
    ]
    
    func generateEmails(count: Int = 10000) -> [[String: Any]] {
        var emails: [[String: Any]] = []
        let currentTime = Date()
        
        // 生成所有邮件数据
        for i in 0..<count {
            // 根据概率决定使用特殊发件人还是普通发件人
            let useSpecialSender = Double.random(in: 0...1) < 0.4
            
            let sender: String
            let isOfficial: Bool
            
            if useSpecialSender {
                // 使用特殊发件人
                sender = specialSenders.randomElement()!
                isOfficial = true
            } else {
                // 使用普通发件人
                sender = regularSenders.randomElement()!
                isOfficial = false
            }
            
            let timestamp = generateRealisticDate(relativeTo: currentTime)
            let email = createEmail(
                id: "\(i + 1)", // 使用索引+1作为ID确保唯一性
                sender: sender,
                isOfficial: isOfficial,
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
    
    private func createEmail(id: String, sender: String, isOfficial: Bool, timestamp: Date) -> [String: Any] {
        // 选择主题和预览内容
        let subject: String
        let preview: String
        
        // 判断是否为特殊发件人
        if let specialContents = specialSenderContentMap[sender] {
            // 为特殊发件人选择匹配的主题和预览
            let randomPair = specialContents.randomElement()!
            subject = randomPair.subject
            preview = randomPair.preview
        } else {
            // 为普通发件人选择主题和预览
            let randomPair = regularSubjectPreviewPairs.randomElement()!
            subject = randomPair.subject
            preview = randomPair.preview
        }
        
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
        
        // 随机添加 emailCount (表示会话中的邮件数量)
        if Double.random(in: 0...1) < 0.2 {
            email["emailCount"] = Int.random(in: 2...10)
        }
        
        return email
    }
    
    // 生成更真实的日期（考虑工作时间、过去时间等因素）
    private func generateRealisticDate(relativeTo currentDate: Date) -> Date {
        let calendar = Calendar.current
        
        // 生成0到-90天之间的随机天数（包括今天）
        let randomDays = Int.random(in: -90...0)
        
        // 获取目标日期（不包含时分秒）
        let targetDay = calendar.date(byAdding: .day, value: randomDays, to: currentDate)!
        
        let weekday = calendar.component(.weekday, from: targetDay)
        let isWeekend = (weekday == 1 || weekday == 7) // 1是周日，7是周六
        
        // 获取当前时间的小时和分钟
        let currentHour = calendar.component(.hour, from: currentDate)
        let currentMinute = calendar.component(.minute, from: currentDate)
        
        // 生成随机时间
        var randomHour: Int
        var randomMinute: Int
        var randomSecond: Int
        
        // 根据周末或工作日生成初始小时
        if isWeekend {
            randomHour = Int.random(in: 10...17) // 周末时间
        } else {
            // 工作日有80%的概率在工作时间（8:00-19:00）
            if Double.random(in: 0...1) < 0.8 {
                randomHour = Int.random(in: 8...19) // 工作时间
            } else {
                // 20%的概率在非工作时间
                randomHour = Int.random(in: 0...23)
            }
        }
        
        // 随机分钟和秒数
        randomMinute = Int.random(in: 0...59)
        randomSecond = Int.random(in: 0...59)
        
        // 如果是今天，确保时间早于当前时间
        if randomDays == 0 {
            // 检查生成的时间是否晚于当前时间
            if randomHour > currentHour || (randomHour == currentHour && randomMinute >= currentMinute) {
                // 如果随机生成的时间晚于或等于当前时间，则将时间设为1-3小时前
                let hoursAgo = Int.random(in: 1...3)
                randomHour = max(8, currentHour - hoursAgo)
                randomMinute = Int.random(in: 0...59)
            }
        }
        
        // 组合日期和时间
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: targetDay)
        dateComponents.hour = randomHour
        dateComponents.minute = randomMinute
        dateComponents.second = randomSecond
        
        return calendar.date(from: dateComponents) ?? currentDate
    }
}

// 主函数
func main() {
    print("开始生成邮件数据...")
    
    do {
        let generator = EmailDataGenerator()
        let emails = generator.generateEmails(count: 10000)
        
        // 正确的相对路径：从Scripts文件夹到MockData文件夹
        let outputPath = "../../Resources/MockData/mock_emails.plist"
        print("输出路径：\(outputPath)")
        
        // 获取当前工作目录
        let currentPath = FileManager.default.currentDirectoryPath
        print("当前工作目录：\(currentPath)")
        
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
            } else {
                print("警告：文件大小为零")
            }
        } else {
            // 文件未创建成功
            print("错误：文件未创建成功")
            exit(1)
        }
        
        print("邮件数据生成完成")
        
    } catch {
        // 出现错误，直接输出错误信息并退出
        print("错误：\(error)")
        print("详细信息：\(error.localizedDescription)")
        exit(1)
    }
}

// 调用主函数
main()
