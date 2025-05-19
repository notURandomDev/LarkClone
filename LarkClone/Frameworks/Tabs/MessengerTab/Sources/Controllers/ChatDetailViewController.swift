//import UIKit
//import LarkColor
//
//// 聊天控制器
//class ChatDetailViewController: UIViewController {
//    
//    // MARK: - UI组件
//    private let tableView = UITableView()
//    private let inputField = UITextField()
//    private let sendButton = UIButton(type: .system)
//    private let inputContainer = UIView()
//    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
//    
//    // MARK: - 数据
//    private var contact: Contact
//    private var messages: [Message] = []
//    private var inputContainerBottomConstraint: NSLayoutConstraint!
//    private var isViewAppeared = false
//    private var registrationToken: NSObjectProtocol?
//    private var isDataLoaded = false
//    private var recalledMessageContent: String?
//    private var recallExpireTimer: Timer?
//    private var replyReferenceView: UIView?
//    private var replyReferenceLabel: UILabel?
//    private var replyReferenceCloseBtn: UIButton?
//    private var replyTargetMessage: Message?
//    private var replyCountDict: [String: Int] = [:]
//    
//    // MARK: - 初始化
//    init(contact: Contact) {
//        self.contact = contact
//        super.init(nibName: nil, bundle: nil)
//        
//        // 性能优化：在初始化时就开始异步预加载消息数据
//        preloadMessages()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    deinit {
//        if let token = registrationToken {
//            NotificationCenter.default.removeObserver(token)
//        }
//        recallExpireTimer?.invalidate()
//    }
//    
//    // 预加载消息数据
//    private func preloadMessages() {
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            guard let self = self else { return }
//            // 预加载消息数据但不更新UI
//            self.messages = Message.getMockMessages(contact: self.contact)
//            self.isDataLoaded = true
//        }
//    }
//    
//    // MARK: - 生命周期
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        setupUI()
//        registerForAppearanceChanges()
//        startRecallExpireTimer()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        // 添加键盘监听
//        addKeyboardObservers()
//        
//        
//        // 确保标题居中
//        navigationItem.largeTitleDisplayMode = .never
//        if let navigationBar = navigationController?.navigationBar {
//            navigationBar.prefersLargeTitles = false
//            
//            // 确保标题视图正确居中
//            let titleLabel = UILabel()
//            titleLabel.text = contact.name
//            titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
//            titleLabel.textAlignment = .center
//            titleLabel.textColor = LarkColorStyle.Text.primary
//            navigationItem.titleView = titleLabel
//        }
//        
//        // 如果数据已加载但UI尚未更新，立即更新UI
//        if isDataLoaded && messages.count > 0 && tableView.numberOfRows(inSection: 0) == 0 {
//            updateUIWithLoadedMessages()
//        }
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        isViewAppeared = true
//        
//        // 如果预加载已完成，显示消息
//        if isDataLoaded {
//            updateUIWithLoadedMessages()
//        } else {
//            // 如果预加载未完成，显示加载指示器
//            loadingIndicator.startAnimating()
//            loadMessages()
//        }
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        // 移除键盘监听
//        removeKeyboardObservers()
//        
//        // 确保退出时正确恢复导航栏状态
//        if isMovingFromParent {
//            // 使用扩展中的方法恢复大标题
//            navigationController?.navigationBar.prefersLargeTitles = true
//            if let previousVC = navigationController?.viewControllers.last {
//                previousVC.navigationItem.largeTitleDisplayMode = .automatic
//            }
//        }
//    }
//    
//    // MARK: - UI设置
//    private func setupUI() {
//        // 使用动态背景色
//        view.backgroundColor = LarkColorStyle.Chat.backgroundColor
//        
//        // 确保导航栏设置正确
//        setupNavigationBar()
//        
//        // 1. 设置表格视图
//        setupTableView()
//        
//        // 2. 设置输入容器
//        setupInputContainer()
//        
//        // 3. 设置约束
//        setupConstraints()
//        
//        // 4. 设置加载指示器
//        setupLoadingIndicator()
//    }
//    
//    private func setupLoadingIndicator() {
//        loadingIndicator.hidesWhenStopped = true
//        loadingIndicator.color = LarkColorStyle.Text.secondary
//        view.addSubview(loadingIndicator)
//        
//        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50)
//        ])
//    }
//    
//    private func registerForAppearanceChanges() {
//        if #available(iOS 17.0, *) {
//            registrationToken = registerForTraitChanges([UITraitUserInterfaceStyle.self]) { [weak self] (viewController: UIViewController, previousTraitCollection: UITraitCollection) in
//                if previousTraitCollection.userInterfaceStyle != self?.traitCollection.userInterfaceStyle {
//                    self?.updateColorForCurrentTraitCollection()
//                }
//            }
//        }
//    }
//    
//    private func updateColorForCurrentTraitCollection() {
//        // 更新视图的背景色
//        view.backgroundColor = LarkColorStyle.Chat.backgroundColor
//        tableView.backgroundColor = LarkColorStyle.Chat.backgroundColor
//        inputContainer.backgroundColor = LarkColorStyle.Chat.inputContainerColor
//        
//        // 更新输入框颜色
//        inputField.backgroundColor = LarkColorStyle.Chat.inputFieldColor
//        
//        // 更新导航栏颜色
//        if let navigationBar = navigationController?.navigationBar {
//            navigationBar.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : .systemBlue
//            navigationBar.barTintColor = LarkColorStyle.Chat.backgroundColor
//            
//            // 更新标题颜色
//            if let titleLabel = navigationItem.titleView as? UILabel {
//                titleLabel.textColor = LarkColorStyle.Text.primary
//            }
//        }
//    }
//    
//    private func setupNavigationBar() {
//        // 设置导航栏样式
//        navigationController?.navigationBar.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : LarkColorStyle.TabBar.tintColor
//        navigationController?.navigationBar.barTintColor = LarkColorStyle.Chat.backgroundColor
//        navigationController?.navigationBar.isTranslucent = false
//        navigationController?.navigationBar.shadowImage = UIImage()
//        
//        // 设置返回按钮
//        let backButtonImage = UIImage(systemName: "chevron.left")
//        navigationController?.navigationBar.backIndicatorImage = backButtonImage
//        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backButtonImage
//        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//    }
//    
//    private func setupTableView() {
//        tableView.backgroundColor = LarkColorStyle.Chat.backgroundColor
//        tableView.register(MessageCell.self, forCellReuseIdentifier: "MessageCell")
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.separatorStyle = .none
//        tableView.keyboardDismissMode = .interactive
//        
//        // 设置正确的内容插入，确保内容不会被遮挡
//        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
//        
//        // 设置表格视图的转换方向，使消息从下到上显示
//        tableView.transform = CGAffineTransform.identity
//        
//        view.addSubview(tableView)
//    }
//    
//    private func setupInputContainer() {
//        inputContainer.backgroundColor = LarkColorStyle.Chat.inputContainerColor
//        inputContainer.layer.borderColor = LarkColorStyle.UI.borderColor.cgColor
//        inputContainer.layer.borderWidth = 0.5
//        view.addSubview(inputContainer)
//        
//        // 引用视图
//        let refView = UIView()
//        refView.backgroundColor = UIColor(white: 0.95, alpha: 1)
//        refView.layer.cornerRadius = 6
//        refView.isHidden = true
//        refView.translatesAutoresizingMaskIntoConstraints = false
//        inputContainer.addSubview(refView)
//        replyReferenceView = refView
//
//        let refLabel = UILabel()
//        refLabel.font = UIFont.systemFont(ofSize: 14)
//        refLabel.textColor = .darkGray
//        refLabel.numberOfLines = 1
//        refLabel.translatesAutoresizingMaskIntoConstraints = false
//        refView.addSubview(refLabel)
//        replyReferenceLabel = refLabel
//
//        let closeBtn = UIButton(type: .system)
//        closeBtn.setTitle("✕", for: .normal)
//        closeBtn.setTitleColor(.gray, for: .normal)
//        closeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
//        closeBtn.translatesAutoresizingMaskIntoConstraints = false
//        closeBtn.addTarget(self, action: #selector(hideReplyReference), for: .touchUpInside)
//        refView.addSubview(closeBtn)
//        replyReferenceCloseBtn = closeBtn
//
//        // 设置输入框 - 修复浅色模式下的颜色
//        inputField.borderStyle = .roundedRect
//        inputField.placeholder = "输入消息..."
//        inputField.backgroundColor = LarkColorStyle.Chat.inputFieldColor
//        inputField.textColor = LarkColorStyle.Text.primary
//        inputField.layer.cornerRadius = 22
//        inputField.layer.masksToBounds = true
//        // 增加内边距（UITextField没有textInsets，需用leftView/rightView或自定义）
//        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 44))
//        inputField.leftView = paddingView
//        inputField.leftViewMode = .always
//        inputField.rightView = paddingView
//        inputField.rightViewMode = .always
//        inputContainer.addSubview(inputField)
//        
//        // 设置发送按钮
//        sendButton.setTitle("发送", for: .normal)
//        sendButton.setTitleColor(LarkColorStyle.ChatBubble.Sent.backgroundColor, for: .normal)
//        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
//        inputContainer.addSubview(sendButton)
//    }
//    
//    private func setupConstraints() {
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        inputContainer.translatesAutoresizingMaskIntoConstraints = false
//        inputField.translatesAutoresizingMaskIntoConstraints = false
//        sendButton.translatesAutoresizingMaskIntoConstraints = false
//        replyReferenceView?.translatesAutoresizingMaskIntoConstraints = false
//        replyReferenceLabel?.translatesAutoresizingMaskIntoConstraints = false
//        replyReferenceCloseBtn?.translatesAutoresizingMaskIntoConstraints = false
//        
//        // 添加约束
//        inputContainerBottomConstraint = inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
//        
//        var constraints: [NSLayoutConstraint] = [
//            // TableView约束
//            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor),
//            
//            // 输入容器约束
//            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            inputContainerBottomConstraint,
//            
//            // 输入框约束
//            inputField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 16),
//            inputField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
//            inputField.heightAnchor.constraint(equalToConstant: 44),
//            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -16),
//            sendButton.centerYAnchor.constraint(equalTo: inputField.centerYAnchor),
//            sendButton.widthAnchor.constraint(equalToConstant: 60)
//        ]
//        if let refView = replyReferenceView, let refLabel = replyReferenceLabel, let closeBtn = replyReferenceCloseBtn {
//            constraints += [
//                refView.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 8),
//                refView.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -8),
//                refView.topAnchor.constraint(equalTo: inputContainer.topAnchor, constant: 4),
//                refView.heightAnchor.constraint(equalToConstant: 28),
//                refLabel.leadingAnchor.constraint(equalTo: refView.leadingAnchor, constant: 8),
//                refLabel.centerYAnchor.constraint(equalTo: refView.centerYAnchor),
//                closeBtn.leadingAnchor.constraint(equalTo: refLabel.trailingAnchor, constant: 8),
//                closeBtn.trailingAnchor.constraint(equalTo: refView.trailingAnchor, constant: -8),
//                closeBtn.centerYAnchor.constraint(equalTo: refView.centerYAnchor),
//                inputField.topAnchor.constraint(equalTo: refView.bottomAnchor, constant: 8)
//            ]
//        } else {
//            constraints.append(inputField.topAnchor.constraint(equalTo: inputContainer.topAnchor, constant: 8))
//        }
//        // 输入容器底部与输入框底部对齐，保证自适应
//        constraints.append(inputField.bottomAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: -8))
//        NSLayoutConstraint.activate(constraints)
//    }
//    
//    // MARK: - 键盘处理
//    private func addKeyboardObservers() {
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(keyboardWillShow),
//                                               name: UIResponder.keyboardWillShowNotification,
//                                               object: nil)
//        
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(keyboardWillHide),
//                                               name: UIResponder.keyboardWillHideNotification,
//                                               object: nil)
//    }
//    
//    private func removeKeyboardObservers() {
//        NotificationCenter.default.removeObserver(self,
//                                                  name: UIResponder.keyboardWillShowNotification,
//                                                  object: nil)
//        
//        NotificationCenter.default.removeObserver(self,
//                                                  name: UIResponder.keyboardWillHideNotification,
//                                                  object: nil)
//    }
//    
//    @objc private func keyboardWillShow(_ notification: Notification) {
//        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
//            let keyboardHeight = keyboardFrame.height
//            
//            UIView.animate(withDuration: 0.3) {
//                self.inputContainerBottomConstraint.constant = -keyboardHeight
//                self.view.layoutIfNeeded()
//            }
//            
//            // 键盘显示时确保滚动到最新消息
//            scrollToBottom(animated: true)
//        }
//    }
//    
//    @objc private func keyboardWillHide(_ notification: Notification) {
//        UIView.animate(withDuration: 0.3) {
//            self.inputContainerBottomConstraint.constant = 0
//            self.view.layoutIfNeeded()
//        }
//    }
//    
//    // MARK: - 数据加载
//    private func loadMessages() {
//        // 如果数据已经加载，直接更新UI
//        if isDataLoaded {
//            updateUIWithLoadedMessages()
//            return
//        }
//        
//        // 否则异步加载
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            guard let self = self else { return }
//            
//            // 从Message类获取测试数据
//            self.messages = Message.getMockMessages(contact: self.contact)
//            self.isDataLoaded = true
//            
//            // 在主线程更新UI
//            DispatchQueue.main.async {
//                self.updateUIWithLoadedMessages()
//            }
//        }
//    }
//    
//    // 更新UI显示已加载的消息
//    private func updateUIWithLoadedMessages() {
//        loadingIndicator.stopAnimating()
//        
//        // 使用无动画更新视图
//        UIView.performWithoutAnimation {
//            tableView.reloadData()
//        }
//        
//        // 滚动到底部
//        if messages.count > 0 {
//            scrollToBottom(animated: false)
//        }
//    }
//    
//    // MARK: - 操作方法
//    @objc private func sendMessage() {
//        guard let text = inputField.text, !text.isEmpty else { return }
//        // 创建当前用户
//        let currentUser = Contact(
//            avatar: UIImage(named: "zhang-jilong") ?? UIImage(systemName: "person.circle.fill") ?? UIImage(),
//            name: "我",
//            latestMsg: "",
//            datetime: "",
//            type: .user
//        )
//        let newMessage = Message(
//            content: text,
//            sender: currentUser,
//            type: .sent,
//            isRead: false,
//            replyTo: replyTargetMessage
//        )
//        let replyToId = replyTargetMessage?.id
//        // 自动隐藏引用视图
//        if replyTargetMessage != nil {
//            hideReplyReference()
//        }
//        messages.append(newMessage)
//        updateReplyCountDict()
//        let indexPath = IndexPath(row: messages.count - 1, section: 0)
//        tableView.insertRows(at: [indexPath], with: .automatic)
//        // 刷新被引用消息cell
//        if let replyId = replyToId, let replyIndex = messages.firstIndex(where: { $0.id == replyId }) {
//            let replyIndexPath = IndexPath(row: replyIndex, section: 0)
//            tableView.reloadRows(at: [replyIndexPath], with: .none)
//        }
//        scrollToBottom(animated: true)
//        inputField.text = ""
//    }
//    
//    private func scrollToBottom(animated: Bool) {
//        if messages.count > 0 {
//            let indexPath = IndexPath(row: messages.count - 1, section: 0)
//            // 确保UI更新完成后再滚动
//            DispatchQueue.main.async {
//                if self.tableView.window != nil {
//                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
//                }
//            }
//        }
//    }
//    
//    @objc private func handleMessageLongPress(_ gesture: UILongPressGestureRecognizer) {
//        guard gesture.state == .began,
//              let cell = gesture.view,
//              cell.tag < messages.count else { return }
//        let message = messages[cell.tag]
//        let isSelf = message.type == .sent
//        let isWithin5Min = Date().timeIntervalSince(message.timestamp) < 300
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        if isSelf && isWithin5Min {
//            alert.addAction(UIAlertAction(title: "撤回", style: .destructive, handler: { [weak self] _ in
//                self?.recallMessage(at: cell.tag)
//            }))
//        }
//        alert.addAction(UIAlertAction(title: "回复", style: .default, handler: { [weak self] _ in
//            self?.replyMessage(at: cell.tag)
//        }))
//        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
//        if let popover = alert.popoverPresentationController {
//            popover.sourceView = cell
//            popover.sourceRect = cell.bounds
//        }
//        present(alert, animated: true, completion: nil)
//    }
//    
//    // 撤回消息，插入 recallTip 类型
//    private func recallMessage(at index: Int) {
//        let recalled = messages[index]
//        let recallTip = Message(
//            content: "你撤回了一条消息",
//            sender: recalled.sender,
//            timestamp: Date(),
//            type: .recallTip,
//            isRead: true,
//            recallContent: recalled.content,
//            recallEditExpireAt: nil
//        )
//        messages.remove(at: index)
//        // 插入 recallTip
//        messages.insert(recallTip, at: index)
//        // 只让第一个 recallTip 有倒计时
//        activateFirstRecallTipTimer()
//        tableView.reloadData()
//    }
//    
//    private func activateFirstRecallTipTimer() {
//        let now = Date()
//        var found = false
//        for msg in messages where msg.type == .recallTip {
//            if !found && (msg.recallEditExpireAt == nil || (msg.recallEditExpireAt != nil && msg.recallEditExpireAt! > now)) {
//                msg.recallEditExpireAt = now.addingTimeInterval(60)
//                found = true
//            } else {
//                msg.recallEditExpireAt = nil
//            }
//        }
//    }
//    
//    private func checkRecallExpire() {
//        let now = Date()
//        var needReload = false
//        var firstActiveIdx: Int? = nil
//        for (idx, msg) in messages.enumerated() where msg.type == .recallTip {
//            if let expire = msg.recallEditExpireAt, expire < now {
//                msg.recallEditExpireAt = Date.distantPast // 标记为已过期
//                needReload = true
//                firstActiveIdx = idx
//                break
//            }
//        }
//        // 激活下一个 recallTip
//        if let idx = firstActiveIdx {
//            for i in (idx+1)..<messages.count {
//                let msg = messages[i]
//                if msg.type == .recallTip && (msg.recallEditExpireAt == nil) {
//                    msg.recallEditExpireAt = Date().addingTimeInterval(60)
//                    needReload = true
//                    break
//                }
//            }
//        }
//        if needReload { tableView.reloadData() }
//    }
//    
//    private func startRecallExpireTimer() {
//        recallExpireTimer?.invalidate()
//        recallExpireTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
//            self?.checkRecallExpire()
//        }
//    }
//    
//    // 预留回复功能
//    private func replyMessage(at index: Int) {
//        let message = messages[index]
//        replyTargetMessage = message
//        replyReferenceLabel?.text = "回复 \(message.sender.name)：\(message.content)"
//        replyReferenceView?.isHidden = false
//    }
//
//    @objc private func hideReplyReference() {
//        replyTargetMessage = nil
//        replyReferenceView?.isHidden = true
//    }
//    
//    private func updateReplyCountDict() {
//        replyCountDict = [:]
//        for msg in messages {
//            if let replyId = msg.replyTo?.id {
//                replyCountDict[replyId, default: 0] += 1
//            }
//        }
//    }
//}
//
//// MARK: - UITableViewDataSource, UITableViewDelegate
//extension ChatDetailViewController: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return messages.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let message = messages[indexPath.row]
//        if message.type == .recallTip {
//            let cellId = "RecallTipCell"
//            var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
//            if cell == nil {
//                cell = UITableViewCell(style: .default, reuseIdentifier: cellId)
//                cell?.selectionStyle = .none
//                cell?.backgroundColor = .clear
//            }
//            cell?.contentView.subviews.forEach { $0.removeFromSuperview() }
//            let container = UIView()
//            container.translatesAutoresizingMaskIntoConstraints = false
//            cell?.contentView.addSubview(container)
//            NSLayoutConstraint.activate([
//                container.centerXAnchor.constraint(equalTo: cell!.contentView.centerXAnchor),
//                container.centerYAnchor.constraint(equalTo: cell!.contentView.centerYAnchor),
//                container.topAnchor.constraint(equalTo: cell!.contentView.topAnchor, constant: 8),
//                container.bottomAnchor.constraint(equalTo: cell!.contentView.bottomAnchor, constant: -8)
//            ])
//            let label = UILabel()
//            label.text = "你撤回了一条消息"
//            label.textColor = UIColor.systemGray
//            label.font = UIFont.systemFont(ofSize: 15)
//            label.translatesAutoresizingMaskIntoConstraints = false
//            container.addSubview(label)
//            var editBtn: UIButton? = nil
//            // 只要 recallEditExpireAt 没过期或为 nil，都显示"重新编辑"按钮
//            if message.recallEditExpireAt == nil || (message.recallEditExpireAt != Date.distantPast && message.recallEditExpireAt! > Date()) {
//                let btn = UIButton(type: .system)
//                btn.setTitle("重新编辑", for: .normal)
//                btn.setTitleColor(.systemBlue, for: .normal)
//                btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
//                btn.translatesAutoresizingMaskIntoConstraints = false
//                btn.tag = indexPath.row
//                btn.addTarget(self, action: #selector(reEditMessageFromTip(_:)), for: .touchUpInside)
//                container.addSubview(btn)
//                editBtn = btn
//            }
//            if let editBtn = editBtn {
//                NSLayoutConstraint.activate([
//                    label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
//                    label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
//                    editBtn.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 2),
//                    editBtn.centerYAnchor.constraint(equalTo: container.centerYAnchor),
//                    editBtn.trailingAnchor.constraint(equalTo: container.trailingAnchor),
//                    container.heightAnchor.constraint(greaterThanOrEqualToConstant: 32)
//                ])
//            } else {
//                NSLayoutConstraint.activate([
//                    label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
//                    label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
//                    label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
//                    container.heightAnchor.constraint(greaterThanOrEqualToConstant: 32)
//                ])
//            }
//            return cell!
//        }
//        // 普通消息cell
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
//        cell.configure(with: message)
//        // 移除旧手势，避免复用问题
//        cell.contentView.gestureRecognizers?.forEach { cell.contentView.removeGestureRecognizer($0) }
//        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleMessageLongPress(_:)))
//        cell.contentView.addGestureRecognizer(longPress)
//        cell.contentView.tag = indexPath.row
//        // 新增：如果有回复引用，渲染引用条
//        cell.showReplyIfNeeded(message.replyTo)
//        // 新增：只在被回复的那条消息下方显示"X条回复"
//        let replyCount = replyCountDict[message.id] ?? 0
//        if replyCount > 0 {
//            cell.showReplyCount(replyCount)
//        } else {
//            cell.hideReplyCount()
//        }
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 80
//    }
//    
//    // 点击"重新编辑"按钮
//    @objc private func reEditMessageFromTip(_ sender: UIButton) {
//        let idx = sender.tag
//        guard idx < messages.count, messages[idx].type == .recallTip, let content = messages[idx].recallContent else { return }
//        inputField.text = content
//        inputField.isUserInteractionEnabled = true
//        inputField.becomeFirstResponder()
//        // 续时1分钟（只对当前激活的 recallTip 有效）
//        if let _ = messages[idx].recallEditExpireAt, messages[idx].recallEditExpireAt != Date.distantPast {
//            messages[idx].recallEditExpireAt = Date().addingTimeInterval(60)
//            tableView.reloadRows(at: [IndexPath(row: idx, section: 0)], with: .none)
//        }
//    }
//}
//
//// MARK: - 性能优化：预取数据
//extension ChatDetailViewController: UITableViewDataSourcePrefetching {
//    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
//        // 预加载头像图像
//        for indexPath in indexPaths {
//            if indexPath.row < messages.count {
//                let message = messages[indexPath.row]
//                
//                // 在后台线程预加载头像
//                DispatchQueue.global(qos: .background).async {
//                    _ = message.sender.avatar
//                }
//            }
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
//        // 可以取消正在进行的加载操作
//    }
//}
//
//// MARK: - Testing Helpers
//#if DEBUG
//extension ChatDetailViewController {
//    // 暴露关键属性供测试使用
//    func testHelper_getContact() -> Contact {
//        return self.contact
//    }
//    
//    func testHelper_getMessages() -> [Message] {
//        return self.messages
//    }
//    
//    func testHelper_setMessages(_ messages: [Message]) {
//        self.messages = messages
//    }
//    
//    func testHelper_isDataLoaded() -> Bool {
//        return self.isDataLoaded
//    }
//    
//    func testHelper_setDataLoaded(_ loaded: Bool) {
//        self.isDataLoaded = loaded
//    }
//    
//    func testHelper_getTableView() -> UITableView {
//        return self.tableView
//    }
//    
//    func testHelper_getInputField() -> UITextField {
//        return self.inputField
//    }
//    
//    // 模拟加载消息的便捷方法
//    func testHelper_loadTestMessages() {
//        let testMessages = [
//            Message(content: "测试消息1",
//                    sender: self.contact,
//                    type: .received,
//                    isRead: true),
//            Message(content: "测试消息2",
//                    sender: Contact(
//                        avatar: UIImage(systemName: "person.circle")!,
//                        name: "我",
//                        latestMsg: "",
//                        datetime: "",
//                        type: .user
//                    ),
//                    type: .sent,
//                    isRead: true),
//            Message(content: "测试消息3",
//                    sender: self.contact,
//                    type: .received,
//                    isRead: false)
//        ]
//        
//        self.messages = testMessages
//        self.isDataLoaded = true
//        self.tableView.reloadData()
//    }
//}
//#endif
//

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
    private var contact: Contact
    private var messages: [Message] = []
    private var inputContainerBottomConstraint: NSLayoutConstraint!
    private var isViewAppeared = false
    private var registrationToken: NSObjectProtocol?
    private var isDataLoaded = false
    private var recalledMessageContent: String?
    private var recallExpireTimer: Timer?
    private var replyReferenceView: UIView?
    private var replyReferenceLabel: UILabel?
    private var replyReferenceCloseBtn: UIButton?
    private var replyTargetMessage: Message?
    private var replyCountDict: [String: Int] = [:]
    
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
        recallExpireTimer?.invalidate()
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
        startRecallExpireTimer()
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
        
        // 引用视图
        let refView = UIView()
        refView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        refView.layer.cornerRadius = 6
        refView.isHidden = true
        refView.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.addSubview(refView)
        replyReferenceView = refView

        let refLabel = UILabel()
        refLabel.font = UIFont.systemFont(ofSize: 14)
        refLabel.textColor = .darkGray
        refLabel.numberOfLines = 1
        refLabel.translatesAutoresizingMaskIntoConstraints = false
        refView.addSubview(refLabel)
        replyReferenceLabel = refLabel

        let closeBtn = UIButton(type: .system)
        closeBtn.setTitle("✕", for: .normal)
        closeBtn.setTitleColor(.gray, for: .normal)
        closeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.addTarget(self, action: #selector(hideReplyReference), for: .touchUpInside)
        refView.addSubview(closeBtn)
        replyReferenceCloseBtn = closeBtn

        // 设置输入框 - 修复浅色模式下的颜色
        inputField.borderStyle = .roundedRect
        inputField.placeholder = "输入消息..."
        inputField.backgroundColor = LarkColorStyle.Chat.inputFieldColor
        inputField.textColor = LarkColorStyle.Text.primary
        inputField.layer.cornerRadius = 22
        inputField.layer.masksToBounds = true
        // 增加内边距（UITextField没有textInsets，需用leftView/rightView或自定义）
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 44))
        inputField.leftView = paddingView
        inputField.leftViewMode = .always
        inputField.rightView = paddingView
        inputField.rightViewMode = .always
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
        replyReferenceView?.translatesAutoresizingMaskIntoConstraints = false
        replyReferenceLabel?.translatesAutoresizingMaskIntoConstraints = false
        replyReferenceCloseBtn?.translatesAutoresizingMaskIntoConstraints = false
        
        // 添加约束
        inputContainerBottomConstraint = inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        var constraints: [NSLayoutConstraint] = [
            // TableView约束
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor),
            
            // 输入容器约束
            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainerBottomConstraint,
            
            // 输入框约束
            inputField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 16),
            inputField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            inputField.heightAnchor.constraint(equalToConstant: 44),
            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -16),
            sendButton.centerYAnchor.constraint(equalTo: inputField.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60)
        ]
        if let refView = replyReferenceView, let refLabel = replyReferenceLabel, let closeBtn = replyReferenceCloseBtn {
            constraints += [
                refView.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 8),
                refView.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -8),
                refView.topAnchor.constraint(equalTo: inputContainer.topAnchor, constant: 4),
                refView.heightAnchor.constraint(equalToConstant: 28),
                refLabel.leadingAnchor.constraint(equalTo: refView.leadingAnchor, constant: 8),
                refLabel.centerYAnchor.constraint(equalTo: refView.centerYAnchor),
                closeBtn.leadingAnchor.constraint(equalTo: refLabel.trailingAnchor, constant: 8),
                closeBtn.trailingAnchor.constraint(equalTo: refView.trailingAnchor, constant: -8),
                closeBtn.centerYAnchor.constraint(equalTo: refView.centerYAnchor),
                inputField.topAnchor.constraint(equalTo: refView.bottomAnchor, constant: 8)
            ]
        } else {
            constraints.append(inputField.topAnchor.constraint(equalTo: inputContainer.topAnchor, constant: 8))
        }
        // 输入容器底部与输入框底部对齐，保证自适应
        constraints.append(inputField.bottomAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: -8))
        NSLayoutConstraint.activate(constraints)
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
            isRead: false,
            replyTo: replyTargetMessage
        )
        let replyToId = replyTargetMessage?.id
        // 自动隐藏引用视图
        if replyTargetMessage != nil {
            hideReplyReference()
        }
        messages.append(newMessage)
        updateReplyCountDict()
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        // 刷新被引用消息cell
        if let replyId = replyToId, let replyIndex = messages.firstIndex(where: { $0.id == replyId }) {
            let replyIndexPath = IndexPath(row: replyIndex, section: 0)
            tableView.reloadRows(at: [replyIndexPath], with: .none)
        }
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
    
    @objc private func handleMessageLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began,
              let cell = gesture.view,
              cell.tag < messages.count else { return }
        let message = messages[cell.tag]
        let isSelf = message.type == .sent
        let isWithin5Min = Date().timeIntervalSince(message.timestamp) < 300
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if isSelf && isWithin5Min {
            alert.addAction(UIAlertAction(title: "撤回", style: .destructive, handler: { [weak self] _ in
                self?.recallMessage(at: cell.tag)
            }))
        }
        alert.addAction(UIAlertAction(title: "回复", style: .default, handler: { [weak self] _ in
            self?.replyMessage(at: cell.tag)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = cell
            popover.sourceRect = cell.bounds
        }
        present(alert, animated: true, completion: nil)
    }
    
    // 撤回消息，插入 recallTip 类型
    private func recallMessage(at index: Int) {
        let recalled = messages[index]
        let replyToId = recalled.replyTo?.id
        let recallTip = Message(
            content: "你撤回了一条消息",
            sender: recalled.sender,
            timestamp: Date(),
            type: .recallTip,
            isRead: true,
            recallContent: recalled.content,
            recallEditExpireAt: nil,
            recallReplyTo: recalled.replyTo
        )
        messages.remove(at: index)
        // 插入 recallTip
        messages.insert(recallTip, at: index)
        updateReplyCountDict()
        tableView.reloadData()
        // 新增：刷新被引用消息cell
        if let replyId = replyToId, let replyIndex = messages.firstIndex(where: { $0.id == replyId }) {
            let replyIndexPath = IndexPath(row: replyIndex, section: 0)
            tableView.reloadRows(at: [replyIndexPath], with: .none)
        }
    }
    
    private func activateFirstRecallTipTimer() {
        let now = Date()
        var found = false
        for msg in messages where msg.type == .recallTip {
            if !found && (msg.recallEditExpireAt == nil || (msg.recallEditExpireAt != nil && msg.recallEditExpireAt! > now)) {
                msg.recallEditExpireAt = now.addingTimeInterval(60)
                found = true
            } else {
                msg.recallEditExpireAt = nil
            }
        }
    }
    
    private func checkRecallExpire() {
        let now = Date()
        var needReload = false
        var firstActiveIdx: Int? = nil
        for (idx, msg) in messages.enumerated() where msg.type == .recallTip {
            if let expire = msg.recallEditExpireAt, expire < now {
                msg.recallEditExpireAt = Date.distantPast // 标记为已过期
                needReload = true
                firstActiveIdx = idx
                break
            }
        }
        // 激活下一个 recallTip
        if let idx = firstActiveIdx {
            for i in (idx+1)..<messages.count {
                let msg = messages[i]
                if msg.type == .recallTip && (msg.recallEditExpireAt == nil) {
                    msg.recallEditExpireAt = Date().addingTimeInterval(60)
                    needReload = true
                    break
                }
            }
        }
        if needReload { tableView.reloadData() }
    }
    
    private func startRecallExpireTimer() {
        recallExpireTimer?.invalidate()
        recallExpireTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.checkRecallExpire()
        }
    }
    
    // 预留回复功能
    private func replyMessage(at index: Int) {
        let message = messages[index]
        replyTargetMessage = message
        replyReferenceLabel?.text = "回复 \(message.sender.name)：\(message.content)"
        replyReferenceView?.isHidden = false
    }

    @objc private func hideReplyReference() {
        replyTargetMessage = nil
        replyReferenceView?.isHidden = true
    }
    
    private func updateReplyCountDict() {
        replyCountDict = [:]
        for msg in messages {
            if let replyId = msg.replyTo?.id {
                replyCountDict[replyId, default: 0] += 1
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
        let message = messages[indexPath.row]
        if message.type == .recallTip {
            let cellId = "RecallTipCell"
            var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: cellId)
                cell?.selectionStyle = .none
                cell?.backgroundColor = .clear
            }
            cell?.contentView.subviews.forEach { $0.removeFromSuperview() }
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            cell?.contentView.addSubview(container)
            NSLayoutConstraint.activate([
                container.centerXAnchor.constraint(equalTo: cell!.contentView.centerXAnchor),
                container.centerYAnchor.constraint(equalTo: cell!.contentView.centerYAnchor),
                container.topAnchor.constraint(equalTo: cell!.contentView.topAnchor, constant: 8),
                container.bottomAnchor.constraint(equalTo: cell!.contentView.bottomAnchor, constant: -8)
            ])
            let label = UILabel()
            label.text = "你撤回了一条消息"
            label.textColor = UIColor.systemGray
            label.font = UIFont.systemFont(ofSize: 15)
            label.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(label)
            var editBtn: UIButton? = nil
            // 只要 recallEditExpireAt 没过期或为 nil，都显示"重新编辑"按钮
            if message.recallEditExpireAt == nil || (message.recallEditExpireAt != Date.distantPast && message.recallEditExpireAt! > Date()) {
                let btn = UIButton(type: .system)
                btn.setTitle("重新编辑", for: .normal)
                btn.setTitleColor(.systemBlue, for: .normal)
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
                btn.translatesAutoresizingMaskIntoConstraints = false
                btn.tag = indexPath.row
                btn.addTarget(self, action: #selector(reEditMessageFromTip(_:)), for: .touchUpInside)
                container.addSubview(btn)
                editBtn = btn
            }
            if let editBtn = editBtn {
                NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                    label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                    editBtn.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 2),
                    editBtn.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                    editBtn.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                    container.heightAnchor.constraint(greaterThanOrEqualToConstant: 32)
                ])
            } else {
                NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                    label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                    label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                    container.heightAnchor.constraint(greaterThanOrEqualToConstant: 32)
                ])
            }
            return cell!
        }
        // 普通消息cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        cell.configure(with: message)
        // 移除旧手势，避免复用问题
        cell.contentView.gestureRecognizers?.forEach { cell.contentView.removeGestureRecognizer($0) }
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleMessageLongPress(_:)))
        cell.contentView.addGestureRecognizer(longPress)
        cell.contentView.tag = indexPath.row
        // 新增：如果有回复引用，渲染引用条
        cell.showReplyIfNeeded(message.replyTo)
        // 新增：只在被回复的那条消息下方显示"X条回复"
        let replyCount = replyCountDict[message.id] ?? 0
        if replyCount > 0 {
            cell.showReplyCount(replyCount)
        } else {
            cell.hideReplyCount()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // 点击"重新编辑"按钮
    @objc private func reEditMessageFromTip(_ sender: UIButton) {
        let idx = sender.tag
        guard idx < messages.count, messages[idx].type == .recallTip, let content = messages[idx].recallContent else { return }
        inputField.text = content
        inputField.isUserInteractionEnabled = true
        inputField.becomeFirstResponder()
        // 新增：如果 recallTip 有 recallReplyTo，则设置引用条
        if let replyTo = messages[idx].recallReplyTo {
            replyTargetMessage = replyTo
            replyReferenceLabel?.text = "回复 \(replyTo.sender.name)：\(replyTo.content)"
            replyReferenceView?.isHidden = false
        }
        // 续时1分钟（只对当前激活的 recallTip 有效）
        if let _ = messages[idx].recallEditExpireAt, messages[idx].recallEditExpireAt != Date.distantPast {
            messages[idx].recallEditExpireAt = Date().addingTimeInterval(60)
            tableView.reloadRows(at: [IndexPath(row: idx, section: 0)], with: .none)
        }
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

// MARK: - Testing Helpers
#if DEBUG
extension ChatDetailViewController {
    // 暴露关键属性供测试使用
    func testHelper_getContact() -> Contact {
        return self.contact
    }
    
    func testHelper_getMessages() -> [Message] {
        return self.messages
    }
    
    func testHelper_setMessages(_ messages: [Message]) {
        self.messages = messages
    }
    
    func testHelper_isDataLoaded() -> Bool {
        return self.isDataLoaded
    }
    
    func testHelper_setDataLoaded(_ loaded: Bool) {
        self.isDataLoaded = loaded
    }
    
    func testHelper_getTableView() -> UITableView {
        return self.tableView
    }
    
    func testHelper_getInputField() -> UITextField {
        return self.inputField
    }
    
    // 模拟加载消息的便捷方法
    func testHelper_loadTestMessages() {
        let testMessages = [
            Message(content: "测试消息1",
                    sender: self.contact,
                    type: .received,
                    isRead: true),
            Message(content: "测试消息2",
                    sender: Contact(
                        avatar: UIImage(systemName: "person.circle")!,
                        name: "我",
                        latestMsg: "",
                        datetime: "",
                        type: .user
                    ),
                    type: .sent,
                    isRead: true),
            Message(content: "测试消息3",
                    sender: self.contact,
                    type: .received,
                    isRead: false)
        ]
        
        self.messages = testMessages
        self.isDataLoaded = true
        self.tableView.reloadData()
    }
}
#endif

