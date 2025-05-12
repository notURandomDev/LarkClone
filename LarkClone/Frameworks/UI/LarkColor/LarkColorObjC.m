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

@implementation LarkColorConfigUI

// 背景色
+ (UIColor *)backgroundColor {
    return UIColor.systemBackgroundColor;
}

// 表格视图背景色
+ (UIColor *)tableViewBackgroundColor {
    return UIColor.systemBackgroundColor;
}

// 轻微灰色背景 (alpha 0.96)
+ (UIColor *)lightGrayBackground {
    return [UIColor colorWithWhite:0.96 alpha:1.0];
}

// 边框颜色 (alpha 0.3)
+ (UIColor *)borderColor {
    return [UIColor.lightGrayColor colorWithAlphaComponent:0.3];
}

// 轻微边框颜色 (alpha 0.5)
+ (UIColor *)lightBorderColor {
    return [UIColor.lightGrayColor colorWithAlphaComponent:0.5];
}

// 空标签颜色
+ (UIColor *)emptyLabelColor {
    return UIColor.secondaryLabelColor;
}

@end

@implementation LarkColorConfigText

// 主要文本颜色
+ (UIColor *)primaryColor {
    return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
        return traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark
            ? UIColor.whiteColor
            : UIColor.blackColor;
    }];
}

// 次要文本颜色
+ (UIColor *)secondaryColor {
    return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
        return traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark
            ? UIColor.lightGrayColor
            : UIColor.systemGrayColor;
    }];
}

@end

@implementation LarkColorConfigChat

// 背景色
+ (UIColor *)backgroundColor {
    return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
        return traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark
            ? UIColor.blackColor
            : UIColor.whiteColor;
    }];
}

// 输入容器背景色
+ (UIColor *)inputContainerColor {
    return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
        return traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark
            ? [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0]
            : UIColor.whiteColor;
    }];
}

// 输入框背景色
+ (UIColor *)inputFieldColor {
    return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
        return traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark
            ? [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0]
            : [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0];
    }];
}

@end
