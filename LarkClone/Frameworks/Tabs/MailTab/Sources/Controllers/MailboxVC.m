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

@interface MailboxVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SearchBarView *searchBarView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSArray<MailItem *> *allEmails;
@property (nonatomic, strong) NSMutableArray<MailItem *> *filteredEmails;
@property (nonatomic, assign) BOOL isSearching;

@end

@implementation MailboxVC

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // 使用本地化的标题
    self.title = NSLocalizedStringFromTable(@"mailbox_title", @"MailTab", @"Mailbox title");
    
    [self setupUI];
    [self loadEmails];
    
    // 配置导航栏右侧按钮
    [self setupNavigationBarButtons];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 重新设置标题确保本地化生效
    self.title = NSLocalizedStringFromTable(@"mailbox_title", @"MailTab", @"Mailbox title");
    
    // 更新TabBar标题
    [self updateTabBarTitle];
}

// 更新TabBar标题
- (void)updateTabBarTitle {
    if (self.tabBarController && self.tabBarController.tabBar.items.count > 1) {
        // 邮箱标签
        UITabBarItem *tabBarItem = self.tabBarController.tabBar.items[1];
        tabBarItem.title = NSLocalizedStringFromTable(@"mailbox_tabbar_title", @"MailTab", @"Mailbox");
    }
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
    self.tableView.backgroundColor = [UIColor systemBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 26, 0, 0);
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 设置下拉刷新
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = self.refreshControl;
    
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

#pragma mark - Data Loading

- (void)loadEmails {
    // 加载示例邮件数据
    self.allEmails = [MailItem loadFromPlist];
    self.filteredEmails = [self.allEmails mutableCopy];
    [self.tableView reloadData];
}

- (void)filterEmailsWithText:(NSString *)searchText {
    if (searchText.length == 0) {
        self.isSearching = NO;
        self.filteredEmails = [self.allEmails mutableCopy];
    } else {
        self.isSearching = YES;
        
        NSMutableArray *filtered = [NSMutableArray array];
        for (MailItem *email in self.allEmails) {
            if ([email.sender.lowercaseString containsString:searchText.lowercaseString] ||
                [email.subject.lowercaseString containsString:searchText.lowercaseString] ||
                [email.preview.lowercaseString containsString:searchText.lowercaseString]) {
                [filtered addObject:email];
            }
        }
        
        self.filteredEmails = filtered;
    }
    
    [self.tableView reloadData];
}

// 标记邮件为已读
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
}

#pragma mark - Actions

- (void)refreshData {
    // 模拟网络请求延迟
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 刷新邮件数据
        [self loadEmails];
        [self.refreshControl endRefreshing];
        
        // 确保TabBar外观在刷新后保持一致
        if (self.tabBarController) {
            SEL setupSelector = NSSelectorFromString(@"setupTabBarAppearance");
            if ([self.tabBarController respondsToSelector:setupSelector]) {
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self.tabBarController performSelector:setupSelector];
                #pragma clang diagnostic pop
            }
        }
    });
}

- (void)filterButtonTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"filter_options", @"MailTab", @"Filter Options")
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"all_emails", @"MailTab", @"All Emails")
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.filteredEmails = [weakSelf.allEmails mutableCopy];
        [weakSelf.tableView reloadData];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"unread", @"MailTab", @"Unread")
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * _Nonnull action) {
        NSMutableArray *filtered = [NSMutableArray array];
        for (MailItem *email in weakSelf.allEmails) {
            if (!email.isRead) {
                [filtered addObject:email];
            }
        }
        weakSelf.filteredEmails = filtered;
        [weakSelf.tableView reloadData];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"with_attachments", @"MailTab", @"With Attachments")
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * _Nonnull action) {
        NSMutableArray *filtered = [NSMutableArray array];
        for (MailItem *email in weakSelf.allEmails) {
            if (email.hasAttachment) {
                [filtered addObject:email];
            }
        }
        weakSelf.filteredEmails = filtered;
        [weakSelf.tableView reloadData];
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MailItem *selectedEmail = self.filteredEmails[indexPath.row];
    
    // 创建详情页面并传递标记已读的回调
    __weak typeof(self) weakSelf = self;
    EmailDetailVC *detailVC = [[EmailDetailVC alloc] initWithEmail:selectedEmail onMarkAsRead:^(NSString *emailId) {
        [weakSelf markEmailAsRead:emailId];
    }];
    
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - Empty State

- (void)showEmptyState {
    UILabel *emptyLabel = [[UILabel alloc] init];
    emptyLabel.text = self.isSearching ?
        NSLocalizedStringFromTable(@"no_search_results", @"MailTab", @"No results found") :
        NSLocalizedStringFromTable(@"no_emails", @"MailTab", @"No emails");
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.textColor = [UIColor secondaryLabelColor];
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
