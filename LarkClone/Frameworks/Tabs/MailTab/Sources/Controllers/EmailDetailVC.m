//
//  EmailDetailVC.m
//  LarkClone
//
//  Created by 张纪龙 on 2025/5/10.
//

#import "EmailDetailVC.h"
#import "MailItem.h"

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
    [self setupUI];
    [self configureWithEmail];
    
    // 标记邮件为已读
    if (!self.email.isRead) {
        [self markAsRead];
    }
}

#pragma mark - Private Methods

- (void)markAsRead {
    // 调用回调函数标记已读
    if (self.onMarkAsRead) {
        self.onMarkAsRead(self.email.id);
    }
}

#pragma mark - UI Setup

- (void)setupUI {
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // 设置滚动视图
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.contentView = [[UIView alloc] init];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentView];
    
    // 设置标题和头部
    self.headerView = [[UIView alloc] init];
    self.headerView.backgroundColor = [UIColor systemBackgroundColor];
    self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.subjectLabel = [[UILabel alloc] init];
    self.subjectLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightBold];
    self.subjectLabel.numberOfLines = 0;
    self.subjectLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 发件人信息
    self.senderInfoView = [[UIView alloc] init];
    self.senderInfoView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.senderLabel = [[UILabel alloc] init];
    self.senderLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.senderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.font = [UIFont systemFontOfSize:14];
    self.dateLabel.textColor = [UIColor secondaryLabelColor];
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
        // 滚动视图
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
        
        // 日期
        [self.dateLabel.topAnchor constraintEqualToAnchor:self.senderLabel.bottomAnchor constant:4],
        [self.dateLabel.leadingAnchor constraintEqualToAnchor:self.senderInfoView.leadingAnchor],
        [self.dateLabel.bottomAnchor constraintEqualToAnchor:self.senderInfoView.bottomAnchor],
        
        // 正文
        [self.bodyLabel.topAnchor constraintEqualToAnchor:self.headerView.bottomAnchor constant:16],
        [self.bodyLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.bodyLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [self.bodyLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-16]
    ]];
    
    // 添加返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                            initWithImage:[UIImage systemImageNamed:@"chevron.left"]
                                            style:UIBarButtonItemStylePlain
                                            target:self
                                            action:@selector(backButtonTapped)];
    
    // 添加邮件操作按钮
    UIBarButtonItem *replyButton = [[UIBarButtonItem alloc]
                                  initWithImage:[UIImage systemImageNamed:@"arrowshape.turn.up.left"]
                                  style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(replyButtonTapped)];
    
    UIBarButtonItem *trashButton = [[UIBarButtonItem alloc]
                                  initWithImage:[UIImage systemImageNamed:@"trash"]
                                  style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(trashButtonTapped)];
    
    self.navigationItem.rightBarButtonItems = @[trashButton, replyButton];
}

- (void)configureWithEmail {
    self.subjectLabel.text = self.email.subject;
    self.senderLabel.text = self.email.sender;
    
    // 格式化日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    self.dateLabel.text = [dateFormatter stringFromDate:self.email.date];
    
    // 生成一些虚拟邮件正文
    self.bodyLabel.text = @"不知道写什么^-^";
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
