//
//  AppDelegate.swift
//  LarkClone
//
//  Created by Kyle Huang on 2025/4/26.
//

import UIKit
import LarkSDK
import LarkColor // 添加导入以使用颜色常量

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 保证 RustBridge Swift 符号在最终 App 中保留
        RustBridgeSymbolRetainer.retainSymbol()
        
        // 全局导航栏外观设置 - 防止状态栏闪烁
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = LarkColorStyle.Chat.backgroundColor
        navigationBarAppearance.shadowColor = nil // 移除底部阴影线
        
        // 设置大标题外观
        navigationBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: LarkColorStyle.Text.primary
        ]
        navigationBarAppearance.titleTextAttributes = [
            .foregroundColor: LarkColorStyle.Text.primary
        ]
        
        // 使所有导航栏使用相同的外观
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        
        // 禁用导航栏半透明效果
        UINavigationBar.appearance().isTranslucent = false
        
        // 保留全局大标题设置
        UINavigationBar.appearance().prefersLargeTitles = true
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
