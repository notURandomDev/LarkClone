import Foundation
import UIKit
import LarkAvatar

enum ContactType: String {
    case user
    case bot
    case external
}

struct Contact {
    let avatar: UIImage?
    let name: String
    let latestMsg: String
    let datetime: String
    let type: ContactType
    
    // 从plist解析的数据中创建Contact
    static func from(contactData: ContactData) -> Contact {
        let avatar: UIImage?
        
        // 获取图片
        if let image = UIImage(named: contactData.avatarName) {
            avatar = image
        } else {
            // 使用默认头像或创建一个占位头像
            avatar = AvatarUtility.createPlaceholderAvatar()
        }
        
        return Contact(
            avatar: avatar,
            name: contactData.name,
            latestMsg: contactData.latestMsg,
            datetime: contactData.datetime,
            type: ContactType(rawValue: contactData.type) ?? .user
        )
    }
}

// 用于从plist文件解析的数据结构
struct ContactData: Codable {
    let name: String
    let avatarName: String
    let latestMsg: String
    let datetime: String
    let type: String
}
