//
//  MockObjcMailItem.swift
//  LarkCloneTests
//
//  Created by 张纪龙 on 2025/5/16.
//
/*
 简化版邮件对象，用于测试
 作为与Rust桥接的中间对象
 简化的数据结构，适用于测试环境
 */

import Foundation
import XCTest
import UIKit
@testable import LarkClone

@objc class ObjCMailItem: NSObject {
    @objc var id: String = ""
    @objc var sender: String = ""
    @objc var subject: String = ""
    @objc var preview: String = ""
    @objc var dateString: String = ""
    @objc var isRead: Bool = false
    @objc var hasAttachment: Bool = false
    @objc var isOfficial: Bool = false
    @objc var emailCount: NSNumber? = nil
}
