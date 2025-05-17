//
//  MailItem+Testing.h
//  LarkClone
//  公开私有方法
//  Created by 张纪龙 on 2025/5/16.
//

#import "MailItem.h"

@interface MailItem (Testing)

// 公开方法以便测试
+ (MailItem *)createMailItemFromDictionary:(NSDictionary *)dict;
+ (NSString *)getMailPlistPath;

@end
