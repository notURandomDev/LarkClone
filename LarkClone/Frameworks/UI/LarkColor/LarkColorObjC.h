//
//  LarkColorObjC.h
//  LarkClone
//
//  Created by 张纪龙 on 2025/5/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LarkColorConfig : NSObject
// 空实现，仅用于命名空间
@end

// 邮件单元格颜色配置
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

// UI通用颜色配置
@interface LarkColorConfigUI : NSObject

// 背景色
+ (UIColor *)backgroundColor;

// 表格视图背景色
+ (UIColor *)tableViewBackgroundColor;

// 轻微灰色背景 (alpha 0.96)
+ (UIColor *)lightGrayBackground;

// 边框颜色 (alpha 0.3)
+ (UIColor *)borderColor;

// 轻微边框颜色 (alpha 0.5)
+ (UIColor *)lightBorderColor;

// 空标签颜色
+ (UIColor *)emptyLabelColor;

@end

// 文本颜色配置
@interface LarkColorConfigText : NSObject

// 主要文本颜色
+ (UIColor *)primaryColor;

// 次要文本颜色
+ (UIColor *)secondaryColor;

@end

// 聊天界面颜色配置
@interface LarkColorConfigChat : NSObject

// 背景色
+ (UIColor *)backgroundColor;

// 输入容器背景色
+ (UIColor *)inputContainerColor;

// 输入框背景色
+ (UIColor *)inputFieldColor;

@end

NS_ASSUME_NONNULL_END
