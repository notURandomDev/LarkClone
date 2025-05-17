//
//  ChatDetailViewControllerTester.swift
//  LarkCloneTests
//
//  Created by 张纪龙 on 2025/5/16.
//

import UIKit
@testable import LarkClone

class ChatDetailViewControllerTester {
    let viewController: ChatDetailViewController
    
    init(viewController: ChatDetailViewController) {
        self.viewController = viewController
    }
    
    // 只保留必要的工具方法
    func getMessageCount() -> Int {
        if let messages = getPrivateProperty(propertyName: "messages") as? [Message] {
            return messages.count
        }
        return 0
    }
    
    func checkDataLoaded() -> Bool {
        return getPrivateProperty(propertyName: "isDataLoaded") as? Bool ?? false
    }
    
    private func getPrivateProperty(propertyName: String) -> Any? {
        // 尝试获取带下划线的实例变量
        let ivarName = "_" + propertyName
        
        if let ivar = class_getInstanceVariable(type(of: viewController), ivarName) {
            return object_getIvar(viewController, ivar)
        }
        
        return nil
    }
}
