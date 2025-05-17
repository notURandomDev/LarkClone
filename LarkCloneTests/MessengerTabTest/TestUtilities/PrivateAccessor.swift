//
//  PrivateAccessor.swift
//  LarkCloneTests
//
//  Created by 张纪龙 on 2025/5/16.
//

import Foundation
import ObjectiveC

class PrivateAccessor {
    static func getPrivateProperty(object: AnyObject, propertyName: String) -> Any? {
        // 尝试直接访问带下划线的实例变量
        let ivarName = "_" + propertyName
        
        if let ivar = class_getInstanceVariable(type(of: object), ivarName) {
            return object_getIvar(object, ivar)
        }
        
        // 尝试不带下划线的变量名
        if let ivar = class_getInstanceVariable(type(of: object), propertyName) {
            return object_getIvar(object, ivar)
        }
        
        // 避免使用KVC，因为它可能引起死锁或其他问题
        return nil
    }
    
    static func setPrivateProperty(object: AnyObject, propertyName: String, value: Any?) {
        // 尝试直接访问带下划线的实例变量
        let ivarName = "_" + propertyName
        
        if let ivar = class_getInstanceVariable(type(of: object), ivarName) {
            object_setIvar(object, ivar, value)
            return
        }
        
        // 尝试不带下划线的变量名
        if let ivar = class_getInstanceVariable(type(of: object), propertyName) {
            object_setIvar(object, ivar, value)
        }
        
        // 避免使用KVC
    }
}
