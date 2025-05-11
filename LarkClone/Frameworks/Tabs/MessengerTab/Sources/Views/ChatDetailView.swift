//
//  ChatDetailView.swift
//  LarkClone
//
//  Created by 张纪龙 on 2025/5/11.
//
import UIKit

protocol ChatDetailViewDelegate: AnyObject {
    func didSendMessage(_ text: String)
}

class ChatDetailView: UIView {
    
    // UI组件
    private(set) var tableView = UITableView()
    private var inputContainerView = UIView()
    private var messageTextView = UITextView()
    private var sendButton = UIButton()
    private var toolbarContainer = UIView()
    private var emojiButton = UIButton()
    private var attachButton = UIButton()
    private var voiceButton = UIButton()
    private var atButton = UIButton()
    
    // 键盘处理
    private var keyboardHeight: CGFloat = 0
    private var inputContainerBottomConstraint: NSLayoutConstraint!
    
    // 委托
    weak var delegate: ChatDetailViewDelegate?
    
    // 常量
    private struct Constants {
        static let inputContainerHeight: CGFloat = 60
        static let inputTextViewPadding: CGFloat = 8
        static let buttonSize: CGFloat = 32
        static let containerPadding: CGFloat = 8
        static let cornerRadius: CGFloat = 16
        static let toolbarButtonSpacing: CGFloat = 10
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupKeyboardObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeKeyboardObservers()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        backgroundColor = .white
        
        // 设置表格视图
        setupTableView()
        
        // 设置输入容器
        setupInputContainer()
        
        // 设置约束
        setupConstraints()
    }
    
    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.keyboardDismissMode = .interactive
        tableView.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        tableView.register(MessageCell.self, forCellReuseIdentifier: "MessageCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        addSubview(tableView)
        
        // 确保首次加载时有内容显示
        tableView.contentInsetAdjustmentBehavior = .automatic
    }
    
    private func setupInputContainer() {
        // 主容器设置
        inputContainerView.backgroundColor = .white
        inputContainerView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        inputContainerView.layer.borderWidth = 0.5
        addSubview(inputContainerView)
        
        // 输入框设置
        messageTextView.font = UIFont.systemFont(ofSize: 16)
        messageTextView.layer.cornerRadius = 18
        messageTextView.layer.masksToBounds = true
        messageTextView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        messageTextView.layer.borderWidth = 0.5
        messageTextView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        messageTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        inputContainerView.addSubview(messageTextView)
        
        // 工具栏容器
        toolbarContainer.backgroundColor = .clear
        inputContainerView.addSubview(toolbarContainer)
        
        // 表情按钮
        emojiButton.setImage(UIImage(systemName: "face.smiling"), for: .normal)
        emojiButton.tintColor = .systemGray
        toolbarContainer.addSubview(emojiButton)
        
        // 附件按钮
        attachButton.setImage(UIImage(systemName: "paperclip"), for: .normal)
        attachButton.tintColor = .systemGray
        toolbarContainer.addSubview(attachButton)
        
        // @按钮
        atButton.setImage(UIImage(systemName: "at"), for: .normal)
        atButton.tintColor = .systemGray
        toolbarContainer.addSubview(atButton)
        
        // 语音按钮
        voiceButton.setImage(UIImage(systemName: "mic"), for: .normal)
        voiceButton.tintColor = .systemGray
        toolbarContainer.addSubview(voiceButton)
        
        // 发送按钮
        sendButton.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        sendButton.tintColor = UIColor.systemBlue
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        inputContainerView.addSubview(sendButton)
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        toolbarContainer.translatesAutoresizingMaskIntoConstraints = false
        emojiButton.translatesAutoresizingMaskIntoConstraints = false
        attachButton.translatesAutoresizingMaskIntoConstraints = false
        atButton.translatesAutoresizingMaskIntoConstraints = false
        voiceButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 输入容器约束
        inputContainerBottomConstraint = inputContainerView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            // 表格视图约束
            tableView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor),
            
            // 输入容器约束
            inputContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            inputContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            inputContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.inputContainerHeight),
            inputContainerBottomConstraint,
            
            // 工具栏容器约束
            toolbarContainer.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: Constants.containerPadding),
            toolbarContainer.topAnchor.constraint(equalTo: inputContainerView.topAnchor),
            toolbarContainer.heightAnchor.constraint(equalToConstant: 40),
            
            // 表情按钮约束
            emojiButton.leadingAnchor.constraint(equalTo: toolbarContainer.leadingAnchor, constant: Constants.toolbarButtonSpacing),
            emojiButton.centerYAnchor.constraint(equalTo: toolbarContainer.centerYAnchor),
            emojiButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            emojiButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            
            // 附件按钮约束
            attachButton.leadingAnchor.constraint(equalTo: emojiButton.trailingAnchor, constant: Constants.toolbarButtonSpacing),
            attachButton.centerYAnchor.constraint(equalTo: toolbarContainer.centerYAnchor),
            attachButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            attachButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            
            // @按钮约束
            atButton.leadingAnchor.constraint(equalTo: attachButton.trailingAnchor, constant: Constants.toolbarButtonSpacing),
            atButton.centerYAnchor.constraint(equalTo: toolbarContainer.centerYAnchor),
            atButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            atButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            
            // 语音按钮约束
            voiceButton.leadingAnchor.constraint(equalTo: atButton.trailingAnchor, constant: Constants.toolbarButtonSpacing),
            voiceButton.centerYAnchor.constraint(equalTo: toolbarContainer.centerYAnchor),
            voiceButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            voiceButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            
            // 消息输入框约束
            messageTextView.topAnchor.constraint(equalTo: toolbarContainer.bottomAnchor, constant: 5),
            messageTextView.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: Constants.containerPadding),
            messageTextView.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: -Constants.containerPadding),
            
            // 发送按钮约束
            sendButton.centerYAnchor.constraint(equalTo: messageTextView.centerYAnchor),
            sendButton.leadingAnchor.constraint(equalTo: messageTextView.trailingAnchor, constant: Constants.containerPadding),
            sendButton.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -Constants.containerPadding),
            sendButton.widthAnchor.constraint(equalToConstant: 32),
            sendButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    // MARK: - Keyboard Handling
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            
            UIView.animate(withDuration: 0.3) {
                self.inputContainerBottomConstraint.constant = -keyboardHeight
                self.layoutIfNeeded()
            }
            
            // 滚动到底部
            scrollToBottom()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.inputContainerBottomConstraint.constant = 0
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Actions
    
    @objc private func sendButtonTapped() {
        guard let text = messageTextView.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        delegate?.didSendMessage(text)
        messageTextView.text = ""
        
        // 自动调整文本视图高度
        messageTextView.sizeToFit()
    }
    
    // MARK: - Public Methods
    
    func scrollToBottom() {
        DispatchQueue.main.async {
            guard self.tableView.numberOfSections > 0 else { return }
            let section = self.tableView.numberOfSections - 1
            guard self.tableView.numberOfRows(inSection: section) > 0 else { return }
            let row = self.tableView.numberOfRows(inSection: section) - 1
            let indexPath = IndexPath(row: row, section: section)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}
