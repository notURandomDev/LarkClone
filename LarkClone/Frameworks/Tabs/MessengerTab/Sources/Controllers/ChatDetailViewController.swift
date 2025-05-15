//
//  ChatDetailViewController.swift
//  LarkClone
//
//  Created by 张纪龙 on 2025/5/11.
//

import UIKit
import LarkColor

// 聊天控制器
class ChatDetailViewController: UIViewController {
    
    // MARK: - UI组件
    private let tableView = UITableView()
    private let inputField = UITextField()
    private let sendButton = UIButton(type: .system)
    private let inputContainer = UIView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - 数据
    private let contact: Contact
    private var messages: [Message] = []
    private var inputContainerBottomConstraint: NSLayoutConstraint!
    private var isViewAppeared = false
    private var registrationToken: NSObjectProtocol?
    private var isDataLoaded = false
    
    // MARK: - 初始化
    init(contact: Contact) {
        self.contact = contact
        super.init(nibName: nil, bundle: nil)
        
        // 性能优化：在初始化时就开始异步预加载消息数据
        preloadMessages()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let token = registrationToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    // 预加载消息数据
    private func preloadMessages() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            // 预加载消息数据但不更新UI
            self.messages = Message.getMockMessages(contact: self.contact)
            self.isDataLoaded = true
        }
    }
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        registerForAppearanceChanges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 添加键盘监听
        addKeyboardObservers()
        
        // 确保标题居中
        navigationItem.largeTitleDisplayMode = .never
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.prefersLargeTitles = false
            
            // 确保标题视图正确居中
            let titleLabel = UILabel()
            titleLabel.text = contact.name
            titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
            titleLabel.textAlignment = .center
            titleLabel.textColor = LarkColorStyle.Text.primary
            navigationItem.titleView = titleLabel
        }
        
        // 如果数据已加载但UI尚未更新，立即更新UI
        if isDataLoaded && messages.count > 0 && tableView.numberOfRows(inSection: 0) == 0 {
            updateUIWithLoadedMessages()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        isViewAppeared = true
        
        // 如果预加载已完成，显示消息
        if isDataLoaded {
            updateUIWithLoadedMessages()
        } else {
            // 如果预加载未完成，显示加载指示器
            loadingIndicator.startAnimating()
            loadMessages()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 移除键盘监听
        removeKeyboardObservers()
        
        // 确保退出时正确恢复导航栏状态
        if isMovingFromParent {
            // 使用扩展中的方法恢复大标题
            navigationController?.navigationBar.prefersLargeTitles = true
            if let previousVC = navigationController?.viewControllers.last {
                previousVC.navigationItem.largeTitleDisplayMode = .automatic
            }
        }
    }
    
    // MARK: - UI设置
    private func setupUI() {
        // 使用动态背景色
        view.backgroundColor = LarkColorStyle.Chat.backgroundColor
        
        // 确保导航栏设置正确
        setupNavigationBar()
        
        // 1. 设置表格视图
        setupTableView()
        
        // 2. 设置输入容器
        setupInputContainer()
        
        // 3. 设置约束
        setupConstraints()
        
        // 4. 设置加载指示器
        setupLoadingIndicator()
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = LarkColorStyle.Text.secondary
        view.addSubview(loadingIndicator)
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50)
        ])
    }
    
    private func registerForAppearanceChanges() {
        if #available(iOS 17.0, *) {
            registrationToken = registerForTraitChanges([UITraitUserInterfaceStyle.self]) { [weak self] (viewController: UIViewController, previousTraitCollection: UITraitCollection) in
                if previousTraitCollection.userInterfaceStyle != self?.traitCollection.userInterfaceStyle {
                    self?.updateColorForCurrentTraitCollection()
                }
            }
        }
    }
    
    private func updateColorForCurrentTraitCollection() {
        // 更新视图的背景色
        view.backgroundColor = LarkColorStyle.Chat.backgroundColor
        tableView.backgroundColor = LarkColorStyle.Chat.backgroundColor
        inputContainer.backgroundColor = LarkColorStyle.Chat.inputContainerColor
        
        // 更新输入框颜色
        inputField.backgroundColor = LarkColorStyle.Chat.inputFieldColor
        
        // 更新导航栏颜色
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : .systemBlue
            navigationBar.barTintColor = LarkColorStyle.Chat.backgroundColor
            
            // 更新标题颜色
            if let titleLabel = navigationItem.titleView as? UILabel {
                titleLabel.textColor = LarkColorStyle.Text.primary
            }
        }
    }
    
    private func setupNavigationBar() {
        // 设置导航栏样式
        navigationController?.navigationBar.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : LarkColorStyle.TabBar.tintColor
        navigationController?.navigationBar.barTintColor = LarkColorStyle.Chat.backgroundColor
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        
        // 设置返回按钮
        let backButtonImage = UIImage(systemName: "chevron.left")
        navigationController?.navigationBar.backIndicatorImage = backButtonImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backButtonImage
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    private func setupTableView() {
        tableView.backgroundColor = LarkColorStyle.Chat.backgroundColor
        tableView.register(MessageCell.self, forCellReuseIdentifier: "MessageCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        
        // 设置正确的内容插入，确保内容不会被遮挡
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        // 设置表格视图的转换方向，使消息从下到上显示
        tableView.transform = CGAffineTransform.identity
        
        view.addSubview(tableView)
    }
    
    private func setupInputContainer() {
        inputContainer.backgroundColor = LarkColorStyle.Chat.inputContainerColor
        inputContainer.layer.borderColor = LarkColorStyle.UI.borderColor.cgColor
        inputContainer.layer.borderWidth = 0.5
        view.addSubview(inputContainer)
        
        // 设置输入框 - 修复浅色模式下的颜色
        inputField.borderStyle = .roundedRect
        inputField.placeholder = "输入消息..."
        inputField.backgroundColor = LarkColorStyle.Chat.inputFieldColor
        inputField.textColor = LarkColorStyle.Text.primary
        inputContainer.addSubview(inputField)
        
        // 设置发送按钮
        sendButton.setTitle("发送", for: .normal)
        sendButton.setTitleColor(LarkColorStyle.ChatBubble.Sent.backgroundColor, for: .normal)
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        inputContainer.addSubview(sendButton)
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        inputField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 添加约束
        inputContainerBottomConstraint = inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            // TableView约束
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor),
            
            // 输入容器约束
            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainer.heightAnchor.constraint(equalToConstant: 60),
            inputContainerBottomConstraint,
            
            // 输入框约束
            inputField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 16),
            inputField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            inputField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            
            // 发送按钮约束
            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -16),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - 键盘处理
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            
            UIView.animate(withDuration: 0.3) {
                self.inputContainerBottomConstraint.constant = -keyboardHeight
                self.view.layoutIfNeeded()
            }
            
            // 键盘显示时确保滚动到最新消息
            scrollToBottom(animated: true)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.inputContainerBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - 数据加载
    private func loadMessages() {
        // 如果数据已经加载，直接更新UI
        if isDataLoaded {
            updateUIWithLoadedMessages()
            return
        }
        
        // 否则异步加载
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // 从Message类获取测试数据
            self.messages = Message.getMockMessages(contact: self.contact)
            self.isDataLoaded = true
            
            // 在主线程更新UI
            DispatchQueue.main.async {
                self.updateUIWithLoadedMessages()
            }
        }
    }
    
    // 更新UI显示已加载的消息
    private func updateUIWithLoadedMessages() {
        loadingIndicator.stopAnimating()
        
        // 使用无动画更新视图
        UIView.performWithoutAnimation {
            tableView.reloadData()
        }
        
        // 滚动到底部
        if messages.count > 0 {
            scrollToBottom(animated: false)
        }
    }
    
    // MARK: - 操作方法
    @objc private func sendMessage() {
        guard let text = inputField.text, !text.isEmpty else { return }
        
        // 创建当前用户
        let currentUser = Contact(
            avatar: UIImage(named: "zhang-jilong") ?? UIImage(systemName: "person.circle.fill") ?? UIImage(),
            name: "我",
            latestMsg: "",
            datetime: "",
            type: .user
        )
        
        let newMessage = Message(
            content: text,
            sender: currentUser,
            type: .sent,
            isRead: false
        )
        
        messages.append(newMessage)
        
        // 使用insertRows而不是reloadData，性能更好
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        
        scrollToBottom(animated: true)
        inputField.text = ""
    }
    
    private func scrollToBottom(animated: Bool) {
        if messages.count > 0 {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            // 确保UI更新完成后再滚动
            DispatchQueue.main.async {
                if self.tableView.window != nil {
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ChatDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        
        let message = messages[indexPath.row]
        cell.configure(with: message)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - 性能优化：预取数据
extension ChatDetailViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        // 预加载头像图像
        for indexPath in indexPaths {
            if indexPath.row < messages.count {
                let message = messages[indexPath.row]
                
                // 在后台线程预加载头像
                DispatchQueue.global(qos: .background).async {
                    _ = message.sender.avatar
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        // 可以取消正在进行的加载操作
    }
}
