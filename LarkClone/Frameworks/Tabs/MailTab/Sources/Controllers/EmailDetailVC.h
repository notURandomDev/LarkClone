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

// 修改初始化方法，添加删除回调参数
- (instancetype)initWithEmail:(MailItem *)email
                 onMarkAsRead:(void (^)(NSString *emailId))onMarkAsRead
                onDeleteEmail:(void (^)(NSString *emailId))onDeleteEmail;

@end

NS_ASSUME_NONNULL_END
