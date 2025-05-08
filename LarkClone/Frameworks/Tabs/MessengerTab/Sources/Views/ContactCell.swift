//
//  ContactCell.swift
//  Feishu-clone
//
//  Created by Kyle Huang on 2025/4/26.
//

import UIKit

class ContactCell: UITableViewCell {
    var avatarIV = UIImageView()
    var nameLabel = UILabel()
    var tagLabel = UILabel()
    var datetimeLabel = UILabel()
    var msgLabel = UILabel()
    var infoSV = UIStackView()
    var leftView = UIView()
    var firstLineView = UIView()
    
    struct Styles {
        static let avatarSize: CGFloat = 40
        static let pxPrimary: CGFloat = 16
        static let pxSecondary: CGFloat = 12
        static let pyPrimary: CGFloat = 13
        static let textColorSecondary = UIColor.systemGray
        static let fontSizePrimary: CGFloat = 16
        static let fontSizeSecondary: CGFloat = 13
        static let fontWeightPrimary = UIFont.Weight.medium
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
       
        configureAvatarIV()
        configureNameLabel()
        configureTagLabel()
        configureLeftView()
        configureDatetimeLabel()
        configureMsgLabel()
        configureFirstLineView()
        configureInfoSV()
        
        addSubview(avatarIV)
        addSubview(infoSV)
        
        setAvatarIVConstaints()
        setNameLabelConstraints()
        setTagLabelConstraints()
        setLeftViewConstraints()
        setDatetimeLabelConstraints()
        setFirstLineViewConstraints()
        setMsgLabelConstaints()
        setInfoSVConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 添加prepareForReuse方法重置所有状态，解决标签错乱问题
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 重置所有视图状态
        avatarIV.image = nil
        nameLabel.text = nil
        msgLabel.text = nil
        datetimeLabel.text = nil
        
        // 重置标签状态
        tagLabel.isHidden = true
        tagLabel.backgroundColor = nil
        tagLabel.text = nil
    }
    
    func set(contact: Contact) {
        avatarIV.image = contact.avatar
        nameLabel.text = contact.name
        msgLabel.text = contact.latestMsg
        datetimeLabel.text = contact.datetime
        
        // 使用switch语句处理不同的联系人类型
        switch contact.type {
        case .bot:
            tagLabel.text = NSLocalizedString(" 机器人 ", comment: "Bot contact tag")
            tagLabel.textColor = LarkColor.Tag.Bot.textColor
            tagLabel.backgroundColor = LarkColor.Tag.Bot.backgroundColor
            tagLabel.isHidden = false
            
        case .external:
            tagLabel.text = NSLocalizedString(" 外部 ", comment: "External contact tag")
            tagLabel.textColor = LarkColor.Tag.External.textColor
            tagLabel.backgroundColor = LarkColor.Tag.External.backgroundColor
            tagLabel.isHidden = false
            
        case .user:
            // 对于普通用户类型，隐藏标签
            tagLabel.isHidden = true
            
        }
    }
    
    func configureNameLabel() {
        nameLabel.font = .systemFont(ofSize: Styles.fontSizePrimary, weight: Styles.fontWeightPrimary)
        nameLabel.lineBreakMode = .byTruncatingTail
    }
    
    func configureTagLabel() {
        tagLabel.isHidden = true
        tagLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        tagLabel.clipsToBounds = true
        tagLabel.layer.cornerRadius = 4
    }
    
    func configureLeftView() {
        leftView.addSubview(nameLabel)
        leftView.addSubview(tagLabel)
    }
    
    func configureDatetimeLabel() {
        datetimeLabel.textColor = LarkColor.Text.secondary
        datetimeLabel.font = .systemFont(ofSize: Styles.fontSizeSecondary, weight: .semibold)
    }
    
    func configureAvatarIV() {
        avatarIV.layer.cornerRadius = Styles.avatarSize / 2
        avatarIV.clipsToBounds = true
    }
    
    func configureMsgLabel() {
        msgLabel.textColor = LarkColor.Text.secondary
        msgLabel.font = .systemFont(ofSize: Styles.fontSizeSecondary, weight: Styles.fontWeightPrimary)
    }
    
    func configureFirstLineView() {
        firstLineView.addSubview(leftView)
        firstLineView.addSubview(datetimeLabel)
    }
    
    func configureInfoSV() {
        infoSV.axis = .vertical
        infoSV.spacing = 8
        infoSV.alignment = .leading
        infoSV.addArrangedSubview(firstLineView)
        infoSV.addArrangedSubview(msgLabel)
    }
    
    func setAvatarIVConstaints() {
        avatarIV.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatarIV.centerYAnchor.constraint(equalTo: centerYAnchor),
            avatarIV.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Styles.pxPrimary),
            avatarIV.heightAnchor.constraint(equalToConstant: Styles.avatarSize),
            avatarIV.widthAnchor.constraint(equalToConstant: Styles.avatarSize)
        ])
    }
    
    func setNameLabelConstraints() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leftView.leadingAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: leftView.centerYAnchor),
            nameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 220)
        ])
    }
    
    func setTagLabelConstraints() {
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tagLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 4),
            tagLabel.topAnchor.constraint(equalTo: firstLineView.topAnchor),
            tagLabel.bottomAnchor.constraint(equalTo: firstLineView.bottomAnchor)
        ])
    }
    
    func setLeftViewConstraints() {
        leftView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftView.leadingAnchor.constraint(equalTo: firstLineView.leadingAnchor),
            leftView.trailingAnchor.constraint(equalTo: datetimeLabel.leadingAnchor),
            leftView.centerYAnchor.constraint(equalTo: firstLineView.centerYAnchor)
        ])
    }
    
    func setDatetimeLabelConstraints() {
        datetimeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datetimeLabel.topAnchor.constraint(equalTo: firstLineView.topAnchor),
            datetimeLabel.trailingAnchor.constraint(equalTo: firstLineView.trailingAnchor),
            datetimeLabel.bottomAnchor.constraint(equalTo: firstLineView.bottomAnchor)
        ])
    }
    
    func setFirstLineViewConstraints() {
        firstLineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            firstLineView.leadingAnchor.constraint(equalTo: infoSV.leadingAnchor),
            firstLineView.trailingAnchor.constraint(equalTo: infoSV.trailingAnchor),
            // firstLineView.topAnchor.constraint(equalTo: infoSV.topAnchor)
        ])
    }
    
    func setMsgLabelConstaints() {
        msgLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // msgLabel.leadingAnchor.constraint(equalTo: infoSV.leadingAnchor)
        ])
    }
    
    func setInfoSVConstraints() {
        infoSV.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoSV.topAnchor.constraint(equalTo: topAnchor, constant: Styles.pyPrimary),
            infoSV.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Styles.pyPrimary),
            infoSV.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Styles.pxPrimary),
            infoSV.leadingAnchor.constraint(equalTo: avatarIV.trailingAnchor, constant: Styles.pxSecondary)
        ])
    }
}
