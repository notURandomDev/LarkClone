//
//  LarkAvatar.swift
//  LarkClone
//
//  Created by Kyle Huang on 2025/5/10.
//

// 公开属性以供外部设置
import UIKit

// 负责头像的 UI 逻辑，包括创建、配置和布局。
public class AvatarView: UIView { private let avatarImageView = UIImageView()
    
    public var image: UIImage? {
        get { avatarImageView.image }
        set { avatarImageView.image = newValue }
    }
    
    public init(size: CGFloat = 40) {
        super.init(frame: .zero)
        configureAvatar(size: size)
        setConstraints(size: size)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureAvatar(size: CGFloat) {
        avatarImageView.layer.cornerRadius = size / 2
        avatarImageView.clipsToBounds = true
        addSubview(avatarImageView)
    }
    
    private func setConstraints(size: CGFloat) {
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: topAnchor),
            avatarImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            avatarImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: size),
            avatarImageView.heightAnchor.constraint(equalToConstant: size)
        ])
    }
}
