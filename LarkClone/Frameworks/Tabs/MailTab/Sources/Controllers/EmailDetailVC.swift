//
//  EmailDetailVC.swift
//  LarkClone
//
//  Created by 张纪龙 on 2025/5/9.
//
import UIKit

class EmailDetailVC: UIViewController {
    // MARK: - Properties
    private let email: MailItem
    private var onMarkAsRead: ((String) -> Void)?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let headerView = UIView()
    private let subjectLabel = UILabel()
    private let senderInfoView = UIView()
    private let senderLabel = UILabel()
    private let dateLabel = UILabel()
    private let bodyLabel = UILabel()
    
    // MARK: - Initialization
    init(email: MailItem, onMarkAsRead: @escaping (String) -> Void) {
            self.email = email
            self.onMarkAsRead = onMarkAsRead
            super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            configureWithEmail()
            
            // 标记邮件为已读
            if !email.isRead {
                markAsRead()
            }
    }
    
    // MARK: - Private Methods
    private func markAsRead() {
        // 调用回调函数标记已读
        onMarkAsRead?(email.id)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 设置滚动视图
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 设置标题和头部
        headerView.backgroundColor = .systemBackground
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        subjectLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        subjectLabel.numberOfLines = 0
        subjectLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 发件人信息
        senderInfoView.translatesAutoresizingMaskIntoConstraints = false
        
        senderLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        senderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = .secondaryLabel
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 邮件正文
        bodyLabel.font = UIFont.systemFont(ofSize: 16)
        bodyLabel.numberOfLines = 0
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 添加子视图
        contentView.addSubview(headerView)
        headerView.addSubview(subjectLabel)
        headerView.addSubview(senderInfoView)
        senderInfoView.addSubview(senderLabel)
        senderInfoView.addSubview(dateLabel)
        contentView.addSubview(bodyLabel)
        
        // 设置约束
        NSLayoutConstraint.activate([
            // 滚动视图
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // 内容视图
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // 头部视图
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // 主题
            subjectLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            subjectLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            subjectLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            // 发件人信息视图
            senderInfoView.topAnchor.constraint(equalTo: subjectLabel.bottomAnchor, constant: 16),
            senderInfoView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            senderInfoView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            senderInfoView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
            
            // 发件人
            senderLabel.topAnchor.constraint(equalTo: senderInfoView.topAnchor),
            senderLabel.leadingAnchor.constraint(equalTo: senderInfoView.leadingAnchor),
            senderLabel.trailingAnchor.constraint(equalTo: senderInfoView.trailingAnchor),
            
            // 日期
            dateLabel.topAnchor.constraint(equalTo: senderLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: senderInfoView.leadingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: senderInfoView.bottomAnchor),
            
            // 正文
            bodyLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            bodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bodyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
        
        // 添加返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        
        // 添加邮件操作按钮
        let replyButton = UIBarButtonItem(
            image: UIImage(systemName: "arrowshape.turn.up.left"),
            style: .plain,
            target: self,
            action: #selector(replyButtonTapped)
        )
        let trashButton = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(trashButtonTapped)
        )
        navigationItem.rightBarButtonItems = [trashButton, replyButton]
    }
    
    private func configureWithEmail() {
        subjectLabel.text = email.subject
        senderLabel.text = email.sender
        
        // 格式化日期
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateLabel.text = dateFormatter.string(from: email.date)
        
        // 为demo生成一些虚拟邮件正文
        bodyLabel.text = """
        不知道写什么^-^
        """
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func replyButtonTapped() {
        let alert = UIAlertController(title: "回复", message: "回复功能正在开发中", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func trashButtonTapped() {
        let alert = UIAlertController(title: "删除", message: "删除功能正在开发中", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}
