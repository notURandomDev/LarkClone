//
//  MainTabBarController.swift
//  LarkClone
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置标签栏外观
        UITabBar.appearance().tintColor = .systemBlue
        
        // 创建视图控制器
        setupViewControllers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 在视图将要显示时更新标签栏标题
        updateTabBarItemTitles()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 在视图完全显示后再次更新标签栏标题，确保应用正确
        DispatchQueue.main.async {
            self.updateTabBarItemTitles()
        }
    }
    
    // 更新TabBar标题的方法
    func updateTabBarItemTitles() {
        if let items = tabBar.items, items.count >= 2 {
            // 尝试刷新缓存，确保获取最新的本地化字符串
            let messengerKey = "messenger_tabbar_title"
            let mailboxKey = "mailbox_tabbar_title"
            
            // 明确指定Bundle为主Bundle
            let bundle = Bundle.main
            
            // 更新消息标签
            if let messengerTitle = NSLocalizedString(messengerKey, tableName: "MessengerTab", bundle: bundle, value: "Messenger", comment: "Messenger tab title") as String? {
                items[0].title = messengerTitle
            }
            
            // 更新邮箱标签
            if let mailboxTitle = NSLocalizedString(mailboxKey, tableName: "MailTab", bundle: bundle, value: "Mailbox", comment: "Mailbox tab title") as String? {
                items[1].title = mailboxTitle
            }
            
            // 确保UI更新
            tabBar.setNeedsLayout()
            tabBar.layoutIfNeeded()
        }
    }
    
    private func setupViewControllers() {
        // 使用主Bundle
        let bundle = Bundle.main
        
        // 信息标签 - 使用现有的ContactListVC
        let messagesVC = ContactListVC()
        messagesVC.title = NSLocalizedString("messenger_title", tableName: "MessengerTab", bundle: bundle, comment: "Messenger")
        let messagesNavController = UINavigationController(rootViewController: messagesVC)
        messagesNavController.navigationBar.prefersLargeTitles = true
        
        // 邮箱标签 - 创建一个新的邮箱控制器
        let mailboxVC = MailboxVC()
        let mailboxNavController = UINavigationController(rootViewController: mailboxVC)
        mailboxNavController.navigationBar.prefersLargeTitles = true
        
        // 设置标签栏图标和标题（使用本地化字符串）
        messagesNavController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("messenger_tabbar_title", tableName: "MessengerTab", bundle: bundle, comment: "Messenger"),
            image: UIImage(systemName: "message"),
            selectedImage: UIImage(systemName: "message.fill")
        )
        
        mailboxNavController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("mailbox_tabbar_title", tableName: "MailTab", bundle: bundle, comment: "Mailbox"),
            image: UIImage(systemName: "envelope"),
            selectedImage: UIImage(systemName: "envelope.fill")
        )
        
        // 将导航控制器添加到标签栏控制器
        setViewControllers([messagesNavController, mailboxNavController], animated: false)
    }
}
