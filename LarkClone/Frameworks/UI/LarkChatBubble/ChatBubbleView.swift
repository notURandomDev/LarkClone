//
//  ChatBubbleView.swift
//  LarkClone
//
//  Created by 张纪龙 on 2025/5/11.
//

import UIKit
import LarkColor

enum BubbleType {
    case sent
    case received
}

class ChatBubbleView: UIView {
    
    // MARK: - UI组件
    let messageLabel = UILabel()
    private var registrationToken: NSObjectProtocol?
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        registerForTraitChanges()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let token = registrationToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    // MARK: - UI设置
    private func setupUI() {
        // 配置消息标签
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textColor = LarkColorConfig.Text.primary
        addSubview(messageLabel)
        
        // 设置自动布局
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
        
        // 设置气泡样式
        layer.cornerRadius = 16
        clipsToBounds = true
    }
    
    // MARK: - 配置
    func configure(text: String, type: BubbleType) {
        messageLabel.text = text
        
        switch type {
        case .sent:
            // 使用 LarkColorConfig 中定义的发送消息气泡颜色
            backgroundColor = LarkColorConfig.ChatBubble.Sent.backgroundColor
            messageLabel.textColor = LarkColorConfig.ChatBubble.Sent.textColor
            
        case .received:
            // 使用 LarkColorConfig 中定义的接收消息气泡颜色
            backgroundColor = LarkColorConfig.ChatBubble.Received.backgroundColor
            messageLabel.textColor = LarkColorConfig.ChatBubble.Received.textColor
        }
    }
    
    // MARK: - 暗色模式支持（只使用iOS 17+新API）
    private func registerForTraitChanges() {
        if #available(iOS 17.0, *) {
            registrationToken = registerForTraitChanges([UITraitUserInterfaceStyle.self]) { [weak self] (view: UIView, previousTraitCollection: UITraitCollection) in
                if previousTraitCollection.userInterfaceStyle != self?.traitCollection.userInterfaceStyle {
                    if let text = self?.messageLabel.text {
                        let isSent = self?.backgroundColor == LarkColorConfig.ChatBubble.Sent.backgroundColor
                        self?.configure(text: text, type: isSent ? .sent : .received)
                    }
                }
            }
        }
    }
    
    // 统一处理特性变化的方法
    private func handleTraitChange(_ previousTraitCollection: UITraitCollection?) {
        // 当外观模式改变时，重新应用配置
        if let text = messageLabel.text, previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            let isSent = backgroundColor == LarkColorConfig.ChatBubble.Sent.backgroundColor
            configure(text: text, type: isSent ? .sent : .received)
        }
    }
}

// 辅助扩展：检测颜色是否为浅色
extension UIColor {
    var isLight: Bool {
        var white: CGFloat = 0
        getWhite(&white, alpha: nil)
        return white > 0.5
    }
}
