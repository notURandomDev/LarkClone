import UIKit

class MailboxVC: UIViewController {
    // MARK: - Properties
    private let tableView = UITableView()
    private let searchBarView = SearchBarView()
    private let refreshControl = UIRefreshControl()
    
    private var allEmails: [MailItem] = []
    private var filteredEmails: [MailItem] = []
    private var isSearching = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // 使用本地化的标题
        title = NSLocalizedString("mailbox_title", tableName: "MailTab", comment: "Mailbox title")
        
        setupUI()
        loadEmails()
        
        // 配置导航栏右侧按钮
        setupNavigationBarButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 重新设置标题确保本地化生效
        title = NSLocalizedString("mailbox_title", tableName: "MailTab", comment: "Mailbox title")
        
        // 更新TabBar标题
        updateTabBarTitle()
    }
    
    // 更新TabBar标题
    private func updateTabBarTitle() {
        if let tabBarItem = tabBarController?.tabBar.items?[1] { // 假设邮箱是第二个标签
            tabBarItem.title = NSLocalizedString("mailbox_tabbar_title", tableName: "MailTab", comment: "Mailbox")
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // 设置搜索栏
        searchBarView.translatesAutoresizingMaskIntoConstraints = false
        searchBarView.onSearch = { [weak self] searchText in
            self?.filterEmails(with: searchText)
        }
        
        // 设置表格视图
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(EmailCell.self, forCellReuseIdentifier: EmailCell.reuseID)
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 26, bottom: 0, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // 设置下拉刷新
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        // 添加视图
        view.addSubview(searchBarView)
        view.addSubview(tableView)
        
        // 设置约束
        NSLayoutConstraint.activate([
            // 搜索栏
            searchBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBarView.heightAnchor.constraint(equalToConstant: 50),
            
            // 表格视图
            tableView.topAnchor.constraint(equalTo: searchBarView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNavigationBarButtons() {
        let filterButton = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease"),
            style: .plain,
            target: self,
            action: #selector(filterButtonTapped)
        )
        
        let composeButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain,
            target: self,
            action: #selector(composeButtonTapped)
        )
        
        navigationItem.rightBarButtonItems = [composeButton, filterButton]
    }
    
    // MARK: - Data Loading
    private func loadEmails() {
        // 加载示例邮件数据
        allEmails = MailItem.loadFromPlist()
        filteredEmails = allEmails
        tableView.reloadData()
    }
    
    private func filterEmails(with searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredEmails = allEmails
        } else {
            isSearching = true
            filteredEmails = allEmails.filter { email in
                email.sender.lowercased().contains(searchText.lowercased()) ||
                email.subject.lowercased().contains(searchText.lowercased()) ||
                email.preview.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
    
    // 标记邮件为已读
    private func markEmailAsRead(_ emailId: String) {
        // 更新allEmails中的邮件状态
        if let index = allEmails.firstIndex(where: { $0.id == emailId }) {
            allEmails[index].isRead = true
        }
        
        // 更新filteredEmails中的邮件状态
        if let index = filteredEmails.firstIndex(where: { $0.id == emailId }) {
            filteredEmails[index].isRead = true
            
            // 更新表格视图中的单元格
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    // MARK: - Actions
    @objc private func refreshData() {
        // 模拟网络请求延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            // 刷新邮件数据
            self?.loadEmails()
            self?.refreshControl.endRefreshing()
            
            // 确保TabBar外观在刷新后保持一致
            if let tabBarController = self?.tabBarController as? MainTabBarController {
                tabBarController.setupTabBarAppearance()
            }
        }
    }
    
    @objc private func filterButtonTapped() {
        let alert = UIAlertController(title: NSLocalizedString("filter_options", tableName: "MailTab", comment: "Filter Options"), message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("all_emails", tableName: "MailTab", comment: "All Emails"), style: .default) { [weak self] _ in
            self?.filteredEmails = self?.allEmails ?? []
            self?.tableView.reloadData()
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("unread", tableName: "MailTab", comment: "Unread"), style: .default) { [weak self] _ in
            self?.filteredEmails = self?.allEmails.filter { !$0.isRead } ?? []
            self?.tableView.reloadData()
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("with_attachments", tableName: "MailTab", comment: "With Attachments"), style: .default) { [weak self] _ in
            self?.filteredEmails = self?.allEmails.filter { $0.hasAttachment } ?? []
            self?.tableView.reloadData()
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", tableName: "MailTab", comment: "Cancel"), style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func composeButtonTapped() {
        let alert = UIAlertController(title: NSLocalizedString("compose_email", tableName: "MailTab", comment: "Compose Email"), message: NSLocalizedString("feature_under_development", tableName: "MailTab", comment: "This feature is under development"), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", tableName: "MailTab", comment: "OK"), style: .default))
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension MailboxVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = filteredEmails.count
        if count == 0 {
            showEmptyState()
        } else {
            hideEmptyState()
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EmailCell.reuseID, for: indexPath) as? EmailCell else {
            return UITableViewCell()
        }
        
        let email = filteredEmails[indexPath.row]
        cell.configure(with: email)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedEmail = filteredEmails[indexPath.row]
        
        // 创建详情页面并传递标记已读的回调
        let detailVC = EmailDetailVC(email: selectedEmail) { [weak self] emailId in
            self?.markEmailAsRead(emailId)
        }
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // MARK: - Empty State
    private func showEmptyState() {
        let emptyLabel = UILabel()
        emptyLabel.text = isSearching ?
            NSLocalizedString("no_search_results", tableName: "MailTab", comment: "No results found") :
            NSLocalizedString("no_emails", tableName: "MailTab", comment: "No emails")
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.backgroundView = emptyLabel
        
        if let backgroundView = tableView.backgroundView {
            NSLayoutConstraint.activate([
                emptyLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
                emptyLabel.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor)
            ])
        }
    }
    
    private func hideEmptyState() {
        tableView.backgroundView = nil
    }
}
