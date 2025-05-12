//
//  AppDelegate.swift
//  Feishu-clone
//
//  Created by Kyle Huang on 2025/4/26.
//

import UIKit
// 测试
import LarkSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("Testing RustBridge.printHello...")
        RustBridge.printHello()
        print("Testing RustBridge.fetchContacts...")
        
        if let path = Bundle.main.path(
            forResource: "mock_contacts", // 文件名无扩展名
            ofType: "plist",              // 扩展名
        ) {
            RustBridge.fetchContacts(page: 0, pageSize: 20, filePath: path) { result in
                switch result {
                case .success(let contacts):
                    print("✅ 获取到 \(contacts.count) 个联系人")
                    for contact in contacts {
                        print("""
                        👤 联系人:
                          - 姓名: \(contact.name)
                          - 消息: \(contact.latestMsg)
                          - 时间: \(contact.datetime)
                          - 类型: \(contact.type)
                        """)
                    }
                case .failure(let error):
                    print("❌ 获取联系人失败：\(error)")
                }
            }
        }

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

