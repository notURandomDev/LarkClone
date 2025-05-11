//
//  LarkColorObjC.m
//  LarkClone
//
//  Created by 张纪龙 on 2025/5/11.
//

#import "LarkColorObjC.h"

@implementation LarkColorConfig
// 空实现，仅用于命名空间
@end

@implementation LarkColorConfigEmailCell

// 未读指示器颜色
+ (UIColor *)unreadIndicatorColor {
    return UIColor.systemBlueColor;
}

// 背景色
+ (UIColor *)backgroundColor {
    return UIColor.systemBackgroundColor;
}

// 未读邮件背景色
+ (UIColor *)unreadBackgroundColor {
    return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
        return traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark
            ? [UIColor colorWithRed:0.17 green:0.17 blue:0.18 alpha:1.0]
            : [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0];
    }];
}

// 发件人标签颜色
+ (UIColor *)senderLabelColor {
    return UIColor.labelColor;
}

// 日期标签颜色
+ (UIColor *)dateLabelColor {
    return UIColor.secondaryLabelColor;
}

// 主题标签颜色
+ (UIColor *)subjectLabelColor {
    return UIColor.labelColor;
}

// 预览标签颜色
+ (UIColor *)previewLabelColor {
    return UIColor.secondaryLabelColor;
}

// 附件图标颜色
+ (UIColor *)attachmentIconColor {
    return UIColor.secondaryLabelColor;
}

@end
