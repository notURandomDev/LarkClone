//
//  EmailCell.h
//  LarkClone
//
//  Created by 张纪龙 on 2025/5/10.
//

#import <UIKit/UIKit.h>
@class MailItem;

NS_ASSUME_NONNULL_BEGIN

@interface EmailCell : UITableViewCell

+ (NSString *)reuseID;
- (void)configureWithEmail:(MailItem *)email;

@end

NS_ASSUME_NONNULL_END
