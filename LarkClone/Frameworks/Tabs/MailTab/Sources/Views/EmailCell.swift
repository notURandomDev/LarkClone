import UIKit

class EmailCell: UITableViewCell {
    // MARK: - Properties
    static let reuseID = "EmailCell"
    
    // UI Elements
    private let unreadIndicator = UIView()
    private let senderLabel = UILabel()
    private let dateLabel = UILabel()
    private let subjectLabel = UILabel()
    private let previewLabel = UILabel()
    private let attachmentIcon = UIImageView()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // 设置基本属性
        selectionStyle = .none
        backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground
        
        // 未读指示器
        unreadIndicator.backgroundColor = .systemBlue
        unreadIndicator.layer.cornerRadius = 4
        unreadIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        // 发件人标签
        senderLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        senderLabel.textColor = .label
        senderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 日期标签
        dateLabel.font = UIFont.systemFont(ofSize: 13)
        dateLabel.textColor = .secondaryLabel
        dateLabel.textAlignment = .right
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 主题标签
        subjectLabel.font = UIFont.systemFont(ofSize: 15)
        subjectLabel.textColor = .label
        subjectLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 预览标签
        previewLabel.font = UIFont.systemFont(ofSize: 14)
        previewLabel.textColor = .secondaryLabel
        previewLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 附件图标
        attachmentIcon.image = UIImage(systemName: "paperclip")
        attachmentIcon.tintColor = .secondaryLabel
        attachmentIcon.translatesAutoresizingMaskIntoConstraints = false
        attachmentIcon.isHidden = true
        
        // 添加子视图
        contentView.addSubview(unreadIndicator)
        contentView.addSubview(senderLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(subjectLabel)
        contentView.addSubview(previewLabel)
        contentView.addSubview(attachmentIcon)
        
        // 设置约束
        NSLayoutConstraint.activate([
            // 未读指示器
            unreadIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            unreadIndicator.centerYAnchor.constraint(equalTo: senderLabel.centerYAnchor),
            unreadIndicator.widthAnchor.constraint(equalToConstant: 8),
            unreadIndicator.heightAnchor.constraint(equalToConstant: 8),
            
            // 发件人
            senderLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            senderLabel.leadingAnchor.constraint(equalTo: unreadIndicator.trailingAnchor, constant: 10),
            senderLabel.trailingAnchor.constraint(lessThanOrEqualTo: dateLabel.leadingAnchor, constant: -8),
            
            // 日期
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dateLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 70),
            
            // 主题
            subjectLabel.topAnchor.constraint(equalTo: senderLabel.bottomAnchor, constant: 4),
            subjectLabel.leadingAnchor.constraint(equalTo: senderLabel.leadingAnchor),
            subjectLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // 预览
            previewLabel.topAnchor.constraint(equalTo: subjectLabel.bottomAnchor, constant: 4),
            previewLabel.leadingAnchor.constraint(equalTo: senderLabel.leadingAnchor),
            previewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            previewLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            // 附件图标
            attachmentIcon.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            attachmentIcon.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -8),
            attachmentIcon.widthAnchor.constraint(equalToConstant: 16),
            attachmentIcon.heightAnchor.constraint(equalToConstant: 16),
        ])
    }
    
    // MARK: - Configuration
    func configure(with email: MailItem) {
        senderLabel.text = email.sender
        subjectLabel.text = email.subject
        previewLabel.text = email.preview
        
        // 设置日期格式
        let formatter = RelativeDateFormatter()
        dateLabel.text = formatter.string(from: email.date)
        
        // 设置未读状态
        unreadIndicator.isHidden = email.isRead
        
        // 更新背景色设置 - 适配暗黑模式
        if email.isRead {
            backgroundColor = .systemBackground
            contentView.backgroundColor = .systemBackground
        } else {
            // 使用动态颜色，支持暗黑模式
            backgroundColor = UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ?
                    UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1.0) :
                    UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)
            }
            contentView.backgroundColor = backgroundColor
        }
        
        // 设置字体粗细基于已读/未读状态
        if !email.isRead {
            senderLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            subjectLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            previewLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        } else {
            senderLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            subjectLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            previewLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        }
        
        // 显示附件图标
        attachmentIcon.isHidden = !email.hasAttachment
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // 选中状态不改变背景色
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        // 高亮状态不改变背景色
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        unreadIndicator.isHidden = true
        attachmentIcon.isHidden = true
        
        // 重置字体
        senderLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        subjectLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        previewLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        // 重置背景色为默认系统背景色
        backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground
    }
}

// 辅助类：相对日期格式化
class RelativeDateFormatter {
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    func string(from date: Date) -> String {
        let now = Date()
        
        if calendar.isDateInToday(date) {
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return NSLocalizedString("yesterday", tableName: "MailTab", comment: "Yesterday")
        } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            dateFormatter.dateFormat = "E" // 周几
            return dateFormatter.string(from: date)
        } else if calendar.isDate(date, equalTo: now, toGranularity: .year) {
            dateFormatter.dateFormat = "M月d日"
            return dateFormatter.string(from: date)
        } else {
            dateFormatter.dateFormat = "yyyy/MM/dd"
            return dateFormatter.string(from: date)
        }
    }
}
