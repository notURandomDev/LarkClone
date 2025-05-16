//
//  MailboxVC.m
//  LarkClone
//
//  Created by 张纪龙 on 2025/5/10.
//

#import "MailboxVC.h"
#import "EmailCell.h"
#import "MailItem.h"
#import "EmailDetailVC.h"
#import "RelativeDateFormatter.h"
#import "SearchBarView.h"
#import "LarkColorObjC.h"

@interface MailboxVC () <UITableViewDelegate, UITableViewDataSource>

// UI相关属性
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SearchBarView *searchBarView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

// 数据相关属性
@property (nonatomic, strong) NSArray<MailItem *> *allEmails;
@property (nonatomic, strong) NSMutableArray<MailItem *> *filteredEmails;

// 状态相关属性
@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, strong) NSString *currentSearchText;
@property (nonatomic, strong) NSString *currentFilterType;

// 分页加载相关属性
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL hasMoreData;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) NSInteger totalEmailCount;

@end

@implementation MailboxVC

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [LarkColorConfigUI backgroundColor];
    
    // 使用本地化的标题
    self.title = NSLocalizedStringFromTable(@"mailbox_title", @"MailTab", @"Mailbox title");
    
    // 初始化属性
    self.currentPage = 0;
    self.isLoading = NO;
    self.hasMoreData = YES;
    self.pageSize = 15;
    self.filteredEmails = [NSMutableArray array];
    self.currentFilterType = nil;
    self.currentSearchText = nil;
    
    [self setupUI];
    [self loadEmails];
    [self setupNavigationBarButtons];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 重新设置标题确保本地化生效
    self.title = NSLocalizedStringFromTable(@"mailbox_title", @"MailTab", @"Mailbox title");
    
    // 更新TabBar标题
    [self updateTabBarTitle];
}

#pragma mark - UI Setup

- (void)setupUI {
    // 设置搜索栏
    self.searchBarView = [[SearchBarView alloc] init];
    self.searchBarView.translatesAutoresizingMaskIntoConstraints = NO;
    __weak typeof(self) weakSelf = self;
    self.searchBarView.onSearch = ^(NSString *searchText) {
        [weakSelf filterEmailsWithText:searchText];
    };
    
    // 设置表格视图
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[EmailCell class] forCellReuseIdentifier:[EmailCell reuseID]];
    self.tableView.backgroundColor = [LarkColorConfigUI tableViewBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 26, 0, 0);
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 设置下拉刷新
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = self.refreshControl;
    
    // 设置加载指示器
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.loadingIndicator.hidesWhenStopped = YES;
    self.loadingIndicator.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    self.tableView.tableFooterView = self.loadingIndicator;
    
    // 添加视图
    [self.view addSubview:self.searchBarView];
    [self.view addSubview:self.tableView];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        // 搜索栏
        [self.searchBarView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.searchBarView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.searchBarView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.searchBarView.heightAnchor constraintEqualToConstant:50],
        
        // 表格视图
        [self.tableView.topAnchor constraintEqualToAnchor:self.searchBarView.bottomAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)setupNavigationBarButtons {
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc]
                                   initWithImage:[UIImage systemImageNamed:@"line.3.horizontal.decrease"]
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(filterButtonTapped)];
    
    UIBarButtonItem *composeButton = [[UIBarButtonItem alloc]
                                    initWithImage:[UIImage systemImageNamed:@"square.and.pencil"]
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(composeButtonTapped)];
    
    self.navigationItem.rightBarButtonItems = @[composeButton, filterButton];
}

- (void)updateTabBarTitle {
    if (self.tabBarController && self.tabBarController.tabBar.items.count > 1) {
        // 邮箱标签
        UITabBarItem *tabBarItem = self.tabBarController.tabBar.items[1];
        tabBarItem.title = NSLocalizedStringFromTable(@"mailbox_tabbar_title", @"MailTab", @"Mailbox");
    }
}

#pragma mark - Data Loading

- (void)loadEmails {
    if (self.isLoading || !self.hasMoreData) {
        return;
    }
    
    self.isLoading = YES;
    [self.loadingIndicator startAnimating];
    
    __weak typeof(self) weakSelf = self;
    
    // 使用统一的方法处理搜索和筛选
    [MailItem loadCombinedResultsWithPage:self.currentPage
                                pageSize:self.pageSize
                             searchText:self.currentSearchText ?: @""
                             filterType:self.currentFilterType ?: @""
                             completion:^(NSArray<MailItem *> *items, BOOL hasMoreData, NSInteger totalItems) {
        [weakSelf handleLoadedEmails:items hasMoreData:hasMoreData totalItems:totalItems];
    }];
}

- (void)handleLoadedEmails:(NSArray<MailItem *> *)items hasMoreData:(BOOL)hasMoreData totalItems:(NSInteger)totalItems {
    // 保存全局信息
    self.hasMoreData = hasMoreData;
    self.totalEmailCount = totalItems;
    
    if (self.currentPage == 0) {
        // 第一页，只有在非筛选模式下保存所有邮件
        if (!self.currentFilterType && !self.currentSearchText) {
            self.allEmails = items;
        }
        
        // 清空并添加新数据
        [self.filteredEmails removeAllObjects];
        [self.filteredEmails addObjectsFromArray:items];
        
        // 重新加载整个表格
        [self.tableView reloadData];
    } else {
        // 记录当前数据数量，用于创建indexPaths
        NSInteger currentCount = self.filteredEmails.count;
        
        // 添加新数据
        [self.filteredEmails addObjectsFromArray:items];
        
        // 创建indexPaths用于插入新行
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (NSInteger i = 0; i < items.count; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:currentCount + i inSection:0]];
        }
        
        // 使用动画插入新行
        if (indexPaths.count > 0) {
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
    self.isLoading = NO;
    [self.loadingIndicator stopAnimating];
}

- (void)loadMoreData {
    if (self.isLoading || !self.hasMoreData) {
        return;
    }
    
    self.currentPage++;
    [self loadEmails];
}

#pragma mark - User Actions

- (void)filterEmailsWithText:(NSString *)searchText {
    // 更新搜索文本
    self.currentSearchText = searchText.length > 0 ? searchText : nil;
    
    // 重置分页
    self.currentPage = 0;
    self.hasMoreData = YES;
    self.isSearching = searchText.length > 0 || self.currentFilterType.length > 0;
    
    // 重新加载
    [self loadEmails];
}

- (void)refreshData {
    // 重置到第一页
    self.currentPage = 0;
    self.hasMoreData = YES;
    
    [self.refreshControl endRefreshing];
    
    // 重新加载，保持所有条件
    [self loadEmails];
}

- (void)filterButtonTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"filter_options", @"MailTab", @"Filter Options")
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"unread", @"MailTab", @"Unread")
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.isSearching = YES;
        weakSelf.currentFilterType = @"unread";
        weakSelf.currentPage = 0;
        weakSelf.hasMoreData = YES;
        [weakSelf loadEmails];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"with_attachments", @"MailTab", @"With Attachments")
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.isSearching = YES;
        weakSelf.currentFilterType = @"attachment";
        weakSelf.currentPage = 0;
        weakSelf.hasMoreData = YES;
        [weakSelf loadEmails];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"all_emails", @"MailTab", @"All Emails")
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * _Nonnull action) {
        // 清除筛选条件，但保留搜索条件
        weakSelf.currentFilterType = nil;
        weakSelf.isSearching = weakSelf.currentSearchText.length > 0;
        weakSelf.currentPage = 0;
        weakSelf.hasMoreData = YES;
        [weakSelf loadEmails];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", @"MailTab", @"Cancel")
                                             style:UIAlertActionStyleCancel
                                           handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)composeButtonTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"compose_email", @"MailTab", @"Compose Email")
                                                                   message:NSLocalizedStringFromTable(@"feature_under_development", @"MailTab", @"This feature is under development")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"ok", @"MailTab", @"OK")
                                             style:UIAlertActionStyleDefault
                                           handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)markEmailAsRead:(NSString *)emailId {
    // 更新allEmails中的邮件状态
    for (NSUInteger i = 0; i < self.allEmails.count; i++) {
        MailItem *email = self.allEmails[i];
        if ([email.id isEqualToString:emailId]) {
            email.isRead = YES;
            break;
        }
    }
    
    // 更新filteredEmails中的邮件状态
    for (NSUInteger i = 0; i < self.filteredEmails.count; i++) {
        MailItem *email = self.filteredEmails[i];
        if ([email.id isEqualToString:emailId]) {
            email.isRead = YES;
            
            // 更新表格视图中的单元格
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
    }
    
    // 持久化保存已读状态到plist文件
    [MailItem updateReadStatus:emailId isRead:YES];
}

- (void)deleteEmail:(NSString *)emailId {
    // 从内存中的数组删除邮件
    NSMutableArray *allEmailsCopy = [self.allEmails mutableCopy];
    for (NSInteger i = 0; i < allEmailsCopy.count; i++) {
        MailItem *email = allEmailsCopy[i];
        if ([email.id isEqualToString:emailId]) {
            [allEmailsCopy removeObjectAtIndex:i];
            break;
        }
    }
    self.allEmails = allEmailsCopy;
    
    // 从过滤后的数组删除邮件
    for (NSInteger i = 0; i < self.filteredEmails.count; i++) {
        MailItem *email = self.filteredEmails[i];
        if ([email.id isEqualToString:emailId]) {
            [self.filteredEmails removeObjectAtIndex:i];
            break;
        }
    }
    
    // 刷新表格视图
    [self.tableView reloadData];
    
    // 持久化删除到plist文件
    [MailItem deleteEmail:emailId];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = self.filteredEmails.count;
    if (count == 0) {
        [self showEmptyState];
    } else {
        [self hideEmptyState];
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EmailCell *cell = [tableView dequeueReusableCellWithIdentifier:[EmailCell reuseID] forIndexPath:indexPath];
    
    MailItem *email = self.filteredEmails[indexPath.row];
    [cell configureWithEmail:email];
    
    // 触发加载更多数据的逻辑
    if (indexPath.row >= self.filteredEmails.count - 5 && !self.isLoading && self.hasMoreData) {
        [self loadMoreData];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MailItem *selectedEmail = self.filteredEmails[indexPath.row];
    
    // 创建详情页面并传递标记已读和删除的回调
    __weak typeof(self) weakSelf = self;
    EmailDetailVC *detailVC = [[EmailDetailVC alloc] initWithEmail:selectedEmail
                                                      onMarkAsRead:^(NSString *emailId) {
        [weakSelf markEmailAsRead:emailId];
    }
                                                     onDeleteEmail:^(NSString *emailId) {
        [weakSelf deleteEmail:emailId];
    }];
    
    // 设置隐藏标签栏
    detailVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 计算距离底部的位置
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat contentHeight = scrollView.contentSize.height;
    CGFloat screenHeight = scrollView.frame.size.height;
    
    if (offsetY > contentHeight - screenHeight - 100 && !self.isLoading && self.hasMoreData) {
        [self loadMoreData];
    }
}

#pragma mark - Empty State

- (void)showEmptyState {
    UILabel *emptyLabel = [[UILabel alloc] init];
    emptyLabel.text = self.isSearching ?
        NSLocalizedStringFromTable(@"no_search_results", @"MailTab", @"No results found") :
        NSLocalizedStringFromTable(@"no_emails", @"MailTab", @"No emails");
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.textColor = [LarkColorConfigUI emptyLabelColor];
    emptyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.tableView.backgroundView = emptyLabel;
    
    if (self.tableView.backgroundView) {
        [NSLayoutConstraint activateConstraints:@[
            [emptyLabel.centerXAnchor constraintEqualToAnchor:self.tableView.backgroundView.centerXAnchor],
            [emptyLabel.centerYAnchor constraintEqualToAnchor:self.tableView.backgroundView.centerYAnchor]
        ]];
    }
}

- (void)hideEmptyState {
    self.tableView.backgroundView = nil;
}

@end
