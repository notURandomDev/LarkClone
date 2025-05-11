//
//  SearchBarView.m
//  LarkClone
//
//  Created by 张纪龙 on 2025/5/10.
//

#import "SearchBarView.h"

@interface SearchBarView () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) UIImageView *searchIconView;
@end

@implementation SearchBarView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor systemBackgroundColor];
    
    // 创建搜索图标
    self.searchIconView = [[UIImageView alloc] init];
    self.searchIconView.image = [UIImage systemImageNamed:@"magnifyingglass"];
    self.searchIconView.tintColor = [UIColor placeholderTextColor];
    self.searchIconView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 创建搜索文本框
    self.searchTextField = [[UITextField alloc] init];
    self.searchTextField.placeholder = NSLocalizedStringFromTable(@"search_emails", @"MailTab", @"Search emails");
    self.searchTextField.borderStyle = UITextBorderStyleNone;
    self.searchTextField.backgroundColor = [UIColor systemGray5Color];
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    self.searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.searchTextField.delegate = self;
    self.searchTextField.layer.cornerRadius = 10.0;
    self.searchTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 36, 20)];
    self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
    self.searchTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    // 添加子视图
    [self addSubview:self.searchTextField];
    [self.searchTextField addSubview:self.searchIconView];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        [self.searchTextField.topAnchor constraintEqualToAnchor:self.topAnchor constant:8],
        [self.searchTextField.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16],
        [self.searchTextField.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16],
        [self.searchTextField.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-8],
        
        [self.searchIconView.leadingAnchor constraintEqualToAnchor:self.searchTextField.leadingAnchor constant:10],
        [self.searchIconView.centerYAnchor constraintEqualToAnchor:self.searchTextField.centerYAnchor],
        [self.searchIconView.widthAnchor constraintEqualToConstant:16],
        [self.searchIconView.heightAnchor constraintEqualToConstant:16]
    ]];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (self.onSearch) {
        self.onSearch(textField.text ?: @"");
    }
    
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (self.onSearch) {
        self.onSearch(textField.text ?: @"");
    }
}

@end
