//
//  ContactCell.swift
//  Feishu-clone
//
//  Created by Kyle Huang on 2025/4/26.
//

import UIKit
import LarkAvatar
import LarkColor

class ContactCell: UITableViewCell {
    private var avatarView = AvatarView()
    var nameLabel = UILabel()
    var tagLabel = UILabel()
    var datetimeLabel = UILabel()
    var msgLabel = UILabel()
    var infoSV = UIStackView()
    var leftView = UIView()
    var firstLineView = UIView()

    
    struct Styles {
        static let pxPrimary: CGFloat = 16
        static let pxSecondary: CGFloat = 12
        static let pyPrimary: CGFloat = 13
        static let textColorSecondary = LarkColorStyle.Text.secondary
        static let fontSizePrimary: CGFloat = 16
        static let fontSizeSecondary: CGFloat = 13
        static let fontWeightPrimary = UIFont.Weight.medium
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
       
        configureNameLabel()
        configureTagLabel()
        configureLeftView()
        configureDatetimeLabel()
        configureMsgLabel()
        configureFirstLineView()
        configureInfoSV()
        
        addSubview(avatarView)
        addSubview(infoSV)
        
        setAvatarViewConstraints()
        setTagLabelConstraints()
        setNameLabelConstraints()
        setLeftViewConstraints()
        setDatetimeLabelConstraints()
        setFirstLineViewConstraints()
        setMsgLabelConstaints()
        setInfoSVConstraints()
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // 添加prepareForReuse解决标签错乱问题
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 重置所有视图状态
        avatarView.image = nil
        nameLabel.text = nil
        msgLabel.text = nil
        datetimeLabel.text = nil
        
        // 重置标签状态
        tagLabel.isHidden = true
        tagLabel.backgroundColor = nil
        tagLabel.text = nil
    }

    func set(contact: Contact) {
        avatarView.image = contact.avatar
        nameLabel.text = contact.name
        msgLabel.text = contact.latestMsg
        datetimeLabel.text = contact.datetime
        
        // 使用switch语句处理不同的联系人类型
        switch contact.type {
            case .bot:
                // 使用MessengerTab表中的本地化字符串
                tagLabel.text = NSLocalizedString("tag_bot", tableName: "MessengerTab", comment: "Bot contact tag")
                tagLabel.textColor = LarkColorStyle.Tag.Bot.textColor
                tagLabel.backgroundColor = LarkColorStyle.Tag.Bot.backgroundColor
                tagLabel.isHidden = false
                
            case .external:
                // 使用MessengerTab表中的本地化字符串
                tagLabel.text = NSLocalizedString("tag_external", tableName: "MessengerTab", comment: "External contact tag")
                tagLabel.textColor = LarkColorStyle.Tag.External.textColor
                tagLabel.backgroundColor = LarkColorStyle.Tag.External.backgroundColor
                tagLabel.isHidden = false
                
            case .user:
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
        datetimeLabel.textColor = LarkColorStyle.Text.secondary
        datetimeLabel.font = .systemFont(ofSize: Styles.fontSizeSecondary, weight: .semibold)
    }

    func configureMsgLabel() {
        msgLabel.textColor = LarkColorStyle.Text.secondary
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

    func setAvatarViewConstraints() {
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatarView.centerYAnchor.constraint(equalTo: centerYAnchor),
            avatarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Styles.pxPrimary),
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
        ])
    }

    func setMsgLabelConstaints() {
        msgLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
        ])
    }

    func setInfoSVConstraints() {
        infoSV.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoSV.topAnchor.constraint(equalTo: topAnchor, constant: Styles.pyPrimary),
            infoSV.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Styles.pyPrimary),
            infoSV.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Styles.pxPrimary),
            infoSV.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: Styles.pxSecondary)
        ])
    }
}
