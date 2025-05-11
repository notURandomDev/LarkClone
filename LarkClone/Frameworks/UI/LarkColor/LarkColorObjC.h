//
//  LarkColorObjC.h
//  LarkClone
//
//  Created by 张纪龙 on 2025/5/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LarkColorConfig : NSObject
@end

@interface LarkColorConfigEmailCell : NSObject

// 未读指示器颜色
+ (UIColor *)unreadIndicatorColor;

// 背景色
+ (UIColor *)backgroundColor;

// 未读邮件背景色
+ (UIColor *)unreadBackgroundColor;

// 发件人标签颜色
+ (UIColor *)senderLabelColor;

// 日期标签颜色
+ (UIColor *)dateLabelColor;

// 主题标签颜色
+ (UIColor *)subjectLabelColor;

// 预览标签颜色
+ (UIColor *)previewLabelColor;

// 附件图标颜色
+ (UIColor *)attachmentIconColor;

@end

NS_ASSUME_NONNULL_END
