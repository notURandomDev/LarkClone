//
//  UINavigationController+StatusBar.swift
//  LarkClone
//
//  Created by 张纪龙 on 2025/5/15.
//
import UIKit

extension UINavigationController {
    // 确保导航控制器使用顶部视图控制器的状态栏样式
    open override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    
    // 确保导航控制器使用顶部视图控制器的状态栏隐藏设置
    open override var childForStatusBarHidden: UIViewController? {
        return topViewController
    }
    
    // 自定义push方法，在原始方法之前更新状态栏
    func customPushViewController(_ viewController: UIViewController, animated: Bool) {
        // 提前应用状态栏样式
        setNeedsStatusBarAppearanceUpdate()
        // 调用原始方法
        pushViewController(viewController, animated: animated)
    }
    
    // 自定义pop方法，在原始方法之前更新状态栏
    func customPopViewController(animated: Bool) -> UIViewController? {
        // 提前应用状态栏样式
        setNeedsStatusBarAppearanceUpdate()
        // 调用原始方法
        return popViewController(animated: animated)
    }
}
