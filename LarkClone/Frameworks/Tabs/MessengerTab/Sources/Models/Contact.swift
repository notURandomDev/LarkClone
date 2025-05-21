import Foundation
import UIKit
import LarkAvatar
import LarkSDKPB

enum ContactType: String {
    case user
    case bot
    case external
}

class Contact {
    var avatar: UIImage?
    var name: String
    var latestMsg: String
    var datetime: String
    var type: ContactType
    // 新增状态属性
    var isPinned: Bool = false
    var isUnread: Bool = false
    var isMarked: Bool = false
    var isMuted: Bool = false
    
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
    
    // 从protobuf转成swift的数据中创建Contact
    static func from(larkContact: LarkSDKPB.Lark_Contact) -> Contact {
        let avatar: UIImage?
        
        // 获取图片
        if let image = UIImage(named: larkContact.avatarName) {
            avatar = image
        } else {
            // 使用默认头像或创建一个占位头像
            avatar = AvatarUtility.createPlaceholderAvatar()
        }
        
        return Contact(
            avatar: avatar,
            name: larkContact.name,
            latestMsg: larkContact.latestMsg,
            datetime: larkContact.datetime,
            type: ContactType(rawValue: larkContact.type) ?? .user
        )
    }
    
    // 修改初始化方法
    init(avatar: UIImage?, name: String, latestMsg: String, datetime: String, type: ContactType) {
        self.avatar = avatar
        self.name = name
        self.latestMsg = latestMsg
        self.datetime = datetime
        self.type = type
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
