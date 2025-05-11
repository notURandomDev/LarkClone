//
//  ContactListVC.swift
//  Feishu-clone
//
//  Created by Kyle Huang on 2025/4/26.
//

import UIKit

class ContactListVC: UIViewController {
    
    var tableView = UITableView()
    var contacts: [Contact] = []
    
    // 分页加载属性
    private var currentPage = 0 // 当前页码
    private var isLoading = false // 是否正在加载
    private var refreshControl: UIRefreshControl! // 下拉刷新控件
    private var loadingIndicator: UIActivityIndicatorView! // 加载指示器
    private var hasMoreData = true // 是否还有更多数据
    
    // 数据管理器
    private let dataManager = ContactDataManager()
    
    struct Cells {
        static let contactCell = "ContactCell"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 使用正确的本地化字符串
        title = NSLocalizedString("messenger_title", tableName: "MessengerTab", bundle: Bundle.main, comment: "Messenger title")
        
        // 启用大标题样式
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        setupUI()
        loadInitialData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 确保使用大标题样式
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 再次确保正确的样式
        if let navBar = navigationController?.navigationBar {
            navBar.prefersLargeTitles = true
            
            // iOS 15以上使用新API强制设置样式
            if #available(iOS 15.0, *) {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithDefaultBackground()
                appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
                navBar.scrollEdgeAppearance = appearance
                navBar.standardAppearance = appearance
            }
        }
    }
    
    private func setupUI() {
        // 添加下拉刷新功能
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        // 添加上拉加载指示器
        loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44)
        
        configureTableView()
    }
    
    // 加载初始数据
    private func loadInitialData() {
        currentPage = 1
        
        // 从数据管理器获取第一页数据
        contacts = dataManager.getContacts(page: currentPage)
        
        // 如果从plist加载失败，使用默认数据
        if contacts.isEmpty {
            contacts = dataManager.getDefaultContacts()
            hasMoreData = false
        } else {
            hasMoreData = currentPage < dataManager.getTotalPages()
        }
        
        tableView.reloadData()
    }
    
    // 配置表格视图
    func configureTableView() {
        view.addSubview(tableView)
        setTableViewDelegates()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(ContactCell.self, forCellReuseIdentifier: Cells.contactCell)
        tableView.refreshControl = refreshControl
        tableView.tableFooterView = loadingIndicator
        tableView.pin(to: view)
    }
    
    // 设置表格视图代理
    func setTableViewDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    // 刷新数据
    @objc private func refreshData() {
        // 重置到第一页
        currentPage = 1
        contacts = dataManager.getContacts(page: currentPage)
        hasMoreData = currentPage < dataManager.getTotalPages()
        
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // 加载更多数据
    private func loadMoreData() {
        if isLoading || !hasMoreData {
            return
        }
        
        isLoading = true
        loadingIndicator.startAnimating()
        
        // 模拟网络延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            guard let self = self else { return }
            
            // 获取下一页数据
            let nextPage = self.currentPage + 1
            let newContacts = self.dataManager.getContacts(page: nextPage)
            
            if !newContacts.isEmpty {
                // 记录插入前的数据数量
                let currentCount = self.contacts.count
                
                // 添加新数据
                self.contacts.append(contentsOf: newContacts)
                self.currentPage = nextPage
                
                // 创建indexPath数组用于插入新行
                var indexPaths: [IndexPath] = []
                for i in 0..<newContacts.count {
                    indexPaths.append(IndexPath(row: currentCount + i, section: 0))
                }
                
                // 插入新行
                self.tableView.insertRows(at: indexPaths, with: .fade)
                
                // 检查是否还有更多数据
                self.hasMoreData = self.currentPage < self.dataManager.getTotalPages()
            } else {
                self.hasMoreData = false
            }
            
            self.isLoading = false
            self.loadingIndicator.stopAnimating()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ContactListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.contactCell) as! ContactCell
        let contact = contacts[indexPath.row]
        cell.set(contact: contact)
        
        if indexPath.row == contacts.count - 5 && !isLoading && hasMoreData {
            loadMoreData()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 获取选中的联系人
        let selectedContact = contacts[indexPath.row]
        
        // 创建聊天详情视图控制器并传递联系人信息
        let chatDetailVC = ChatDetailViewController(contact: selectedContact)
        
        // 导航到聊天详情页面
        navigationController?.pushViewController(chatDetailVC, animated: true)
    }
    
    // 实现滚动到底部加载更多
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 计算距离底部的位置
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.frame.height
        
        if offsetY > contentHeight - screenHeight - 100 && !isLoading && hasMoreData {
            loadMoreData()
        }
    }
}
