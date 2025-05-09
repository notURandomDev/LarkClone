//
//  MailboxVC.swift
//  LarkClone
//
//  Created by 张纪龙 on 2025/5/9.
//

import UIKit

class MailboxVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        // 使用本地化的标题，指定使用MailTab表
        title = NSLocalizedString("mailbox_title", tableName: "MailTab", comment: "Mailbox title")
        
        setupUI()
    }
    
    // 添加这个方法确保标题在视图每次出现时都正确设置
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 重新设置标题确保本地化生效
        title = NSLocalizedString("mailbox_title", tableName: "MailTab", comment: "Mailbox title")
        
        // 更新TabBar标题
        updateTabBarTitle()
    }
    
    // 添加此方法手动更新TabBar标题
    private func updateTabBarTitle() {
        // 尝试获取并更新当前标签页的标题
        if let tabBarItem = tabBarController?.tabBar.items?[1] { // 假设邮箱是第二个标签
            tabBarItem.title = NSLocalizedString("mailbox_tabbar_title", tableName: "MailTab", comment: "Mailbox")
        }
    }
    
    private func setupUI() {
        // 示例：添加一个本地化的标签，指定使用MailTab表
        let label = UILabel()
        label.text = NSLocalizedString("mailbox_placeholder", tableName: "MailTab", comment: "Mailbox function is under development...")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
