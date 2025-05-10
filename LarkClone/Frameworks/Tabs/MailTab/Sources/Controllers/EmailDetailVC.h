//
//  EmailDetailVC.h
//  LarkClone
//
//  Created by 张纪龙 on 2025/5/10.
//
#import <UIKit/UIKit.h>
@class MailItem;

NS_ASSUME_NONNULL_BEGIN

@interface EmailDetailVC : UIViewController

// 初始化方法，传入email和标记已读的回调
- (instancetype)initWithEmail:(MailItem *)email onMarkAsRead:(void (^)(NSString *emailId))onMarkAsRead;

@end

NS_ASSUME_NONNULL_END
