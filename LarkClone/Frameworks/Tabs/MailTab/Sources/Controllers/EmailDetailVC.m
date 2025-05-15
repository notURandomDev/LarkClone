//
//  EmailDetailVC.m
//  LarkClone
//
//  Created by 张纪龙 on 2025/5/10.
//

#import "EmailDetailVC.h"
#import "MailItem.h"
#import "LarkColorObjC.h"

@interface EmailDetailVC ()

// 属性
@property (nonatomic, strong) MailItem *email;
@property (nonatomic, copy) void (^onMarkAsRead)(NSString *emailId);

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UILabel *subjectLabel;
@property (nonatomic, strong) UIView *senderInfoView;
@property (nonatomic, strong) UILabel *senderLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *bodyLabel;

// 自定义导航栏属性
@property (nonatomic, strong) UIView *customNavigationView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *replyButton;
@property (nonatomic, strong) UIButton *trashButton;

@end

@implementation EmailDetailVC

#pragma mark - Initialization

- (instancetype)initWithEmail:(MailItem *)email onMarkAsRead:(void (^)(NSString *emailId))onMarkAsRead {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _email = email;
        _onMarkAsRead = onMarkAsRead;
    }
    return self;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 隐藏底部标签栏
    self.hidesBottomBarWhenPushed = YES;
    
    [self setupUI];
    [self setupCustomNavigation]; // 添加自定义导航栏
    [self configureWithEmail];
    
    // 标记邮件为已读
    if (!self.email.isRead) {
        [self markAsRead];
    }
}

// 隐藏导航栏
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

// 恢复导航栏
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - Private Methods

- (void)markAsRead {
    // 调用回调函数标记已读
    if (self.onMarkAsRead) {
        self.onMarkAsRead(self.email.id);
    }
}

#pragma mark - UI Setup

- (void)setupCustomNavigation {
    // 创建自定义导航视图
    self.customNavigationView = [[UIView alloc] init];
    self.customNavigationView.backgroundColor = [LarkColorConfigUI backgroundColor];
    self.customNavigationView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.customNavigationView];
    
    // 创建返回按钮
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton setImage:[UIImage systemImageNamed:@"chevron.left"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.customNavigationView addSubview:self.backButton];
    
    // 创建回复按钮
    self.replyButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.replyButton setImage:[UIImage systemImageNamed:@"arrowshape.turn.up.left"] forState:UIControlStateNormal];
    [self.replyButton addTarget:self action:@selector(replyButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.replyButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.customNavigationView addSubview:self.replyButton];
    
    // 创建删除按钮
    self.trashButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.trashButton setImage:[UIImage systemImageNamed:@"trash"] forState:UIControlStateNormal];
    [self.trashButton addTarget:self action:@selector(trashButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.trashButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.customNavigationView addSubview:self.trashButton];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        // 自定义导航视图
        [self.customNavigationView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.customNavigationView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.customNavigationView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.customNavigationView.heightAnchor constraintEqualToConstant:44],
        
        // 返回按钮
        [self.backButton.leadingAnchor constraintEqualToAnchor:self.customNavigationView.leadingAnchor constant:16],
        [self.backButton.centerYAnchor constraintEqualToAnchor:self.customNavigationView.centerYAnchor],
        [self.backButton.widthAnchor constraintEqualToConstant:30],
        [self.backButton.heightAnchor constraintEqualToConstant:30],
        
        // 删除按钮
        [self.trashButton.trailingAnchor constraintEqualToAnchor:self.customNavigationView.trailingAnchor constant:-16],
        [self.trashButton.centerYAnchor constraintEqualToAnchor:self.customNavigationView.centerYAnchor],
        [self.trashButton.widthAnchor constraintEqualToConstant:30],
        [self.trashButton.heightAnchor constraintEqualToConstant:30],
        
        // 回复按钮
        [self.replyButton.trailingAnchor constraintEqualToAnchor:self.trashButton.leadingAnchor constant:-16],
        [self.replyButton.centerYAnchor constraintEqualToAnchor:self.customNavigationView.centerYAnchor],
        [self.replyButton.widthAnchor constraintEqualToConstant:30],
        [self.replyButton.heightAnchor constraintEqualToConstant:30],
    ]];
    
    // 调整滚动视图的顶部约束，使其位于自定义导航栏下方
    for (NSLayoutConstraint *constraint in self.view.constraints) {
        if (constraint.firstItem == self.scrollView && constraint.firstAttribute == NSLayoutAttributeTop) {
            [constraint setActive:NO];
            break;
        }
    }
    
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.customNavigationView.bottomAnchor]
    ]];
}

- (void)setupUI {
    self.view.backgroundColor = [LarkColorConfigUI backgroundColor];
    
    // 设置滚动视图
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.contentView = [[UIView alloc] init];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentView];
    
    // 设置标题和头部
    self.headerView = [[UIView alloc] init];
    self.headerView.backgroundColor = [LarkColorConfigUI backgroundColor];
    self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.subjectLabel = [[UILabel alloc] init];
    self.subjectLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightBold];
    self.subjectLabel.numberOfLines = 0;
    self.subjectLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 发件人信息
    self.senderInfoView = [[UIView alloc] init];
    self.senderInfoView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 增大发件人字体
    self.senderLabel = [[UILabel alloc] init];
    self.senderLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightSemibold];
    self.senderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.font = [UIFont systemFontOfSize:14];
    self.dateLabel.textColor = [LarkColorConfigText secondaryColor];
    self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 邮件正文
    self.bodyLabel = [[UILabel alloc] init];
    self.bodyLabel.font = [UIFont systemFontOfSize:16];
    self.bodyLabel.numberOfLines = 0;
    self.bodyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 添加子视图
    [self.contentView addSubview:self.headerView];
    [self.headerView addSubview:self.subjectLabel];
    [self.headerView addSubview:self.senderInfoView];
    [self.senderInfoView addSubview:self.senderLabel];
    [self.senderInfoView addSubview:self.dateLabel];
    [self.contentView addSubview:self.bodyLabel];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        // 滚动视图 - 稍后会在setupCustomNavigation中调整顶部约束
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        
        // 内容视图
        [self.contentView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        [self.contentView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor],
        
        // 头部视图
        [self.headerView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [self.headerView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [self.headerView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        
        // 主题
        [self.subjectLabel.topAnchor constraintEqualToAnchor:self.headerView.topAnchor constant:16],
        [self.subjectLabel.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor constant:16],
        [self.subjectLabel.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor constant:-16],
        
        // 发件人信息视图
        [self.senderInfoView.topAnchor constraintEqualToAnchor:self.subjectLabel.bottomAnchor constant:16],
        [self.senderInfoView.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor constant:16],
        [self.senderInfoView.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor constant:-16],
        [self.senderInfoView.bottomAnchor constraintEqualToAnchor:self.headerView.bottomAnchor constant:-16],
        
        // 发件人
        [self.senderLabel.topAnchor constraintEqualToAnchor:self.senderInfoView.topAnchor],
        [self.senderLabel.leadingAnchor constraintEqualToAnchor:self.senderInfoView.leadingAnchor],
        [self.senderLabel.trailingAnchor constraintEqualToAnchor:self.senderInfoView.trailingAnchor],
        
        // 日期 - 增加与发件人的间距
        [self.dateLabel.topAnchor constraintEqualToAnchor:self.senderLabel.bottomAnchor constant:8], // 从4改为8
        [self.dateLabel.leadingAnchor constraintEqualToAnchor:self.senderInfoView.leadingAnchor],
        [self.dateLabel.bottomAnchor constraintEqualToAnchor:self.senderInfoView.bottomAnchor],
        
        // 正文
        [self.bodyLabel.topAnchor constraintEqualToAnchor:self.headerView.bottomAnchor constant:16],
        [self.bodyLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.bodyLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [self.bodyLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-16]
    ]];
}

- (void)configureWithEmail {
    self.subjectLabel.text = self.email.subject;
    self.senderLabel.text = self.email.sender;
    
    // 格式化日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    self.dateLabel.text = [dateFormatter stringFromDate:self.email.date];
    
    // 只使用原始预览内容
    NSString *previewContent = [NSString stringWithFormat:@"%@\n\n我不知道写什么OvO", self.email.preview];
    
    self.bodyLabel.text = previewContent;
}

#pragma mark - Actions

- (void)backButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)replyButtonTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"回复"
                                                                   message:@"回复功能正在开发中"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)trashButtonTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"删除"
                                                                   message:@"删除功能正在开发中"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
