import Foundation

struct MailItem: Codable {
    let id: String
    let sender: String
    let senderAvatar: String?
    let subject: String
    let preview: String
    private let dateString: String
    var isRead: Bool
    let hasAttachment: Bool
    let isOfficial: Bool
    let emailCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, sender, senderAvatar, subject, preview
        case dateString = "date"
        case isRead, hasAttachment, isOfficial, emailCount
    }
    
    var date: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: dateString) ?? Date()
    }
    
    // 用于从plist加载邮件数据
    static func loadFromPlist() -> [MailItem] {
        // 首先尝试从应用程序包中读取
        if let path = Bundle.main.path(forResource: "mock_emails", ofType: "plist", inDirectory: "MockData"),
           let plistData = FileManager.default.contents(atPath: path),
           let plistItems = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [[String: Any]] {
            return convertDictionariesToMailItems(plistItems)
        }
        
        // 如果应用程序包中没有，使用模拟数据
        return mockEmails()
    }
    
    private static func convertDictionariesToMailItems(_ dictionaries: [[String: Any]]) -> [MailItem] {
        return dictionaries.compactMap { dict in
            guard let id = dict["id"] as? String,
                  let sender = dict["sender"] as? String,
                  let subject = dict["subject"] as? String,
                  let preview = dict["preview"] as? String,
                  let dateString = dict["date"] as? String,
                  let isRead = dict["isRead"] as? Bool,
                  let hasAttachment = dict["hasAttachment"] as? Bool,
                  let isOfficial = dict["isOfficial"] as? Bool else {
                return nil
            }
            
            let senderAvatar = dict["senderAvatar"] as? String
            let emailCount = dict["emailCount"] as? Int
            
            return MailItem(
                id: id,
                sender: sender,
                senderAvatar: senderAvatar,
                subject: subject,
                preview: preview,
                dateString: dateString,
                isRead: isRead,
                hasAttachment: hasAttachment,
                isOfficial: isOfficial,
                emailCount: emailCount
            )
        }
    }
    
    // 示例数据生成方法
    static func mockEmails() -> [MailItem] {
        return [
            MailItem(id: "1", sender: "ByteTech 官方公共邮箱", senderAvatar: nil,
                   subject: "ByteTech | MCP x 业务: 达人选品 AI Agent 简易版发布",
                   preview: "Dear ByteDancers, ByteTech 本周为你精选了...",
                   dateString: "2025-05-09 10:50:00", isRead: false,
                   hasAttachment: false, isOfficial: true, emailCount: nil),
            
            MailItem(id: "2", sender: "乔子铭", senderAvatar: nil,
                   subject: "v7.44 版本启动邮件 - Lark IM & AI Architecture & UI",
                   preview: "一、版本时间信息 节点 时间 排人会议 2025/04...",
                   dateString: "2025-04-25 14:30:00", isRead: true,
                   hasAttachment: false, isOfficial: false, emailCount: nil),
            
            MailItem(id: "3", sender: "乔子铭", senderAvatar: nil,
                   subject: "v7.43 版本启动邮件 - Lark IM & AI Architecture & UI",
                   preview: "[Lark IM & Product Architecture & AI Arch v7...",
                   dateString: "2025-04-25 12:15:00", isRead: true,
                   hasAttachment: false, isOfficial: false, emailCount: 2),
            
            MailItem(id: "4", sender: "The Postman Team", senderAvatar: nil,
                   subject: "[External] Postman API Night 東京のご案内",
                   preview: "",
                   dateString: "2025-04-25 09:40:00", isRead: true,
                   hasAttachment: false, isOfficial: false, emailCount: nil),
            
            MailItem(id: "5", sender: "kodeco.com", senderAvatar: nil,
                   subject: "[External] Reset password instructions",
                   preview: "[图片] Hello supeng.charlie@bytedance.com! ...",
                   dateString: "2025-04-24 16:50:00", isRead: true,
                   hasAttachment: true, isOfficial: false, emailCount: 2),
            
            MailItem(id: "6", sender: "系统服务", senderAvatar: nil,
                   subject: "[External] 您有一张来自【北京钟爱纯粹自然餐饮有限公司】的增值税专用发票",
                   preview: "[图片] 尊敬的客户，您好：北京钟爱纯粹自然...",
                   dateString: "2025-04-24 13:20:00", isRead: true,
                   hasAttachment: true, isOfficial: false, emailCount: nil),
            
            MailItem(id: "7", sender: "DeveloperCenter Shanghai", senderAvatar: nil,
                   subject: "[External] Apple 开发者官方微信公众号现已上线",
                   preview: "尊敬的开发者，我们是 Apple 全球开发者关系团队...",
                   dateString: "2025-04-24 10:15:00", isRead: true,
                   hasAttachment: false, isOfficial: false, emailCount: nil)
        ]
    }
}
