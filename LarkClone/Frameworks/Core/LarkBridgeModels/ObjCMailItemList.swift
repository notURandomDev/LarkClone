//
//  ObjCMailItem.swift
//  LarkClone
//
//  Created by Kyle Huang on 2025/5/13.
//

import Foundation
import LarkSDKPB

@objcMembers
public class ObjCMailItem: NSObject {
    public let id: String
    public let sender: String
    public let subject: String
    public let preview: String
    public let dateString: String
    public let isRead: Bool
    public let hasAttachment: Bool
    public let isOfficial: Bool
    public let emailCount: NSNumber?

    public init(from proto: Lark_MailItem) {
        self.id = proto.id
        self.sender = proto.sender
        self.subject = proto.subject
        self.preview = proto.preview
        self.dateString = proto.dateString
        self.isRead = proto.isRead
        self.hasAttachment = proto.hasAttachment_p
        self.isOfficial = proto.isOfficial
        self.emailCount = proto.hasEmailCount ? NSNumber(value: proto.emailCount) : nil
    }
}

@objcMembers
public class ObjCMailItemList: NSObject {
    public let items: [ObjCMailItem]

    public init(from protoList: Lark_MailItemList) {
        self.items = protoList.items.map { ObjCMailItem(from: $0) }
    }
}
