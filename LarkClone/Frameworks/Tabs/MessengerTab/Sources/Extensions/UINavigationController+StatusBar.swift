//
//  UINavigationController+StatusBar.swift
//  LarkClone
//
//  Created by 张纪龙 on 2025/5/15.
//  确保导航栏样式正确

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
        // 保存当前导航栏largeTitles状态
        let wasLargeTitleEnabled = navigationBar.prefersLargeTitles
        
        // 提前应用状态栏样式
        setNeedsStatusBarAppearanceUpdate()
        
        // 调用原始方法
        pushViewController(viewController, animated: animated)
        
        // 为这个视图控制器保存原始large title设置，以便返回时恢复
        viewController.navigationItem.setValue(wasLargeTitleEnabled, forKey: "_storedLargeTitleState")
    }
    
    // 自定义pop方法，在原始方法之前更新状态栏并恢复导航栏大标题设置
    func customPopViewController(animated: Bool) -> UIViewController? {
        // 提前应用状态栏样式
        setNeedsStatusBarAppearanceUpdate()
        
        // 调用原始方法
        let poppedVC = popViewController(animated: animated)
        
        // 如果没有更多视图控制器，无需恢复
        guard let previousVC = topViewController else {
            return poppedVC
        }
        
        // 查看是否需要恢复大标题设置
        if let shouldEnableLargeTitle = previousVC.navigationItem.value(forKey: "_storedLargeTitleState") as? Bool {
            // 恢复大标题设置
            navigationBar.prefersLargeTitles = shouldEnableLargeTitle
            
            // 根据savedLargeTitleState设置当前顶部VC的largeTitleDisplayMode
            previousVC.navigationItem.largeTitleDisplayMode = shouldEnableLargeTitle ? .automatic : .never
        }
        
        return poppedVC
    }
    
    // 保存和恢复导航栏状态的方法
    func preserveNavigationBarState() {
        // 在这里保存应用全局的导航栏设置
        // 当应用需要在特定地方使用不同的导航栏样式，然后恢复全局设置时使用
        
        // 为根视图控制器设置大标题模式
        if let rootVC = viewControllers.first {
            rootVC.navigationItem.largeTitleDisplayMode = .automatic
            navigationBar.prefersLargeTitles = true
        }
    }
}

// MARK: - 扩展UIViewController存储导航栏状态
extension UIViewController {
    // 设置导航栏大标题状态（用于详情页面）
    func setDetailNavigationStyle() {
        // 仅设置当前视图控制器的大标题显示模式，不影响全局设置
        navigationItem.largeTitleDisplayMode = .never
    }
    
    // 准备返回时恢复导航栏状态
    func restoreNavigationStyleBeforeDisappear() {
        if isMovingFromParent, let navController = navigationController {
            // 如果是通过返回按钮离开，恢复前一个页面的导航栏样式
            if let previousVC = navController.viewControllers.last {
                previousVC.navigationItem.largeTitleDisplayMode = .automatic
                navController.navigationBar.prefersLargeTitles = true
            }
        }
    }
}
