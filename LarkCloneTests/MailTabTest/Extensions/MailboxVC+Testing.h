//
//  MailboxVC+Testing.h
//  LarkClone
//  公开私有属性
//  Created by 张纪龙 on 2025/5/16.
//

#import "MailboxVC.h"

@interface MailboxVC (Testing)

@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, readonly) SearchBarView *searchBarView;
@property (nonatomic, readonly) UIRefreshControl *refreshControl;
@property (nonatomic, readonly) NSArray<MailItem *> *allEmails;
@property (nonatomic, readonly) NSMutableArray<MailItem *> *filteredEmails;
@property (nonatomic, readonly) BOOL isSearching;
@property (nonatomic, readonly) NSString *currentSearchText;
@property (nonatomic, readonly) NSString *currentFilterType;
@property (nonatomic, readonly) NSInteger currentPage;
@property (nonatomic, readonly) BOOL isLoading;
@property (nonatomic, readonly) BOOL hasMoreData;

// 公开方法以便测试
- (void)filterEmailsWithText:(NSString *)searchText;
- (void)refreshData;
- (void)markEmailAsRead:(NSString *)emailId;
- (void)filterButtonTapped;
- (void)composeButtonTapped;

- (void)filterEmailsWithText:(NSString *)searchText;
- (void)refreshData;
- (void)markEmailAsRead:(NSString *)emailId;
- (void)filterButtonTapped;
- (void)composeButtonTapped;

@end
