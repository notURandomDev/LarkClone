//
//  EmailCell.m
//  LarkClone
//
//  Created by 张纪龙 on 2025/5/10.
//

#import "EmailCell.h"
#import "MailItem.h"
#import "RelativeDateFormatter.h"

@interface EmailCell ()
// UI Elements
@property (nonatomic, strong) UIView *unreadIndicator;
@property (nonatomic, strong) UILabel *senderLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *subjectLabel;
@property (nonatomic, strong) UILabel *previewLabel;
@property (nonatomic, strong) UIImageView *attachmentIcon;
@end

@implementation EmailCell

#pragma mark - Class Methods

+ (NSString *)reuseID {
    return @"EmailCell";
}

#pragma mark - Initialization

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

#pragma mark - UI Setup

- (void)setupUI {
    // 设置基本属性
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor systemBackgroundColor];
    self.contentView.backgroundColor = [UIColor systemBackgroundColor];
    
    // 未读指示器
    self.unreadIndicator = [[UIView alloc] init];
    self.unreadIndicator.backgroundColor = [UIColor systemBlueColor];
    self.unreadIndicator.layer.cornerRadius = 4;
    self.unreadIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 发件人标签
    self.senderLabel = [[UILabel alloc] init];
    self.senderLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.senderLabel.textColor = [UIColor labelColor];
    self.senderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 日期标签
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.font = [UIFont systemFontOfSize:13];
    self.dateLabel.textColor = [UIColor secondaryLabelColor];
    self.dateLabel.textAlignment = NSTextAlignmentRight;
    self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 主题标签
    self.subjectLabel = [[UILabel alloc] init];
    self.subjectLabel.font = [UIFont systemFontOfSize:15];
    self.subjectLabel.textColor = [UIColor labelColor];
    self.subjectLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 预览标签
    self.previewLabel = [[UILabel alloc] init];
    self.previewLabel.font = [UIFont systemFontOfSize:14];
    self.previewLabel.textColor = [UIColor secondaryLabelColor];
    self.previewLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 附件图标
    self.attachmentIcon = [[UIImageView alloc] init];
    self.attachmentIcon.image = [UIImage systemImageNamed:@"paperclip"];
    self.attachmentIcon.tintColor = [UIColor secondaryLabelColor];
    self.attachmentIcon.translatesAutoresizingMaskIntoConstraints = NO;
    self.attachmentIcon.hidden = YES;
    
    // 添加子视图
    [self.contentView addSubview:self.unreadIndicator];
    [self.contentView addSubview:self.senderLabel];
    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:self.subjectLabel];
    [self.contentView addSubview:self.previewLabel];
    [self.contentView addSubview:self.attachmentIcon];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        // 未读指示器
        [self.unreadIndicator.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:12],
        [self.unreadIndicator.centerYAnchor constraintEqualToAnchor:self.senderLabel.centerYAnchor],
        [self.unreadIndicator.widthAnchor constraintEqualToConstant:8],
        [self.unreadIndicator.heightAnchor constraintEqualToConstant:8],
        
        // 发件人
        [self.senderLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:12],
        [self.senderLabel.leadingAnchor constraintEqualToAnchor:self.unreadIndicator.trailingAnchor constant:10],
        [self.senderLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.dateLabel.leadingAnchor constant:-8],
        
        // 日期
        [self.dateLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:12],
        [self.dateLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [self.dateLabel.widthAnchor constraintGreaterThanOrEqualToConstant:70],
        
        // 主题
        [self.subjectLabel.topAnchor constraintEqualToAnchor:self.senderLabel.bottomAnchor constant:4],
        [self.subjectLabel.leadingAnchor constraintEqualToAnchor:self.senderLabel.leadingAnchor],
        [self.subjectLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        
        // 预览
        [self.previewLabel.topAnchor constraintEqualToAnchor:self.subjectLabel.bottomAnchor constant:4],
        [self.previewLabel.leadingAnchor constraintEqualToAnchor:self.senderLabel.leadingAnchor],
        [self.previewLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [self.previewLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-12],
        
        // 附件图标
        [self.attachmentIcon.centerYAnchor constraintEqualToAnchor:self.dateLabel.centerYAnchor],
        [self.attachmentIcon.trailingAnchor constraintEqualToAnchor:self.dateLabel.leadingAnchor constant:-8],
        [self.attachmentIcon.widthAnchor constraintEqualToConstant:16],
        [self.attachmentIcon.heightAnchor constraintEqualToConstant:16],
    ]];
}

#pragma mark - Configuration

- (void)configureWithEmail:(MailItem *)email {
    self.senderLabel.text = email.sender;
    self.subjectLabel.text = email.subject;
    self.previewLabel.text = email.preview;
    
    // 设置日期格式
    RelativeDateFormatter *formatter = [[RelativeDateFormatter alloc] init];
    self.dateLabel.text = [formatter stringFromDate:email.date];
    
    // 设置未读状态
    self.unreadIndicator.hidden = email.isRead;
    
    // 更新背景色设置 - 适配暗黑模式
    if (email.isRead) {
        self.backgroundColor = [UIColor systemBackgroundColor];
        self.contentView.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        // 使用动态颜色，支持暗黑模式
        self.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            return traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ?
                [UIColor colorWithRed:0.17 green:0.17 blue:0.18 alpha:1.0] :
                [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0];
        }];
        self.contentView.backgroundColor = self.backgroundColor;
    }
    
    // 设置字体粗细基于已读/未读状态
    if (!email.isRead) {
        self.senderLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
        self.subjectLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
        self.previewLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    } else {
        self.senderLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        self.subjectLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        self.previewLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    }
    
    // 显示附件图标
    self.attachmentIcon.hidden = !email.hasAttachment;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // 选中状态不改变背景色
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    // 高亮状态不改变背景色
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.unreadIndicator.hidden = YES;
    self.attachmentIcon.hidden = YES;
    
    // 重置字体
    self.senderLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
    self.subjectLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    self.previewLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    
    // 重置背景色为默认系统背景色
    self.backgroundColor = [UIColor systemBackgroundColor];
    self.contentView.backgroundColor = [UIColor systemBackgroundColor];
}

@end
