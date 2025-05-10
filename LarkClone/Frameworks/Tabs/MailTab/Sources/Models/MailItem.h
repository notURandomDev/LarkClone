//
//  MailItem.h
//  LarkClone
//
//  Created by 张纪龙 on 2025/5/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MailItem : NSObject

@property (nonatomic, strong, readonly) NSString *id;
@property (nonatomic, strong, readonly) NSString *sender;
@property (nonatomic, strong, readonly, nullable) NSString *senderAvatar;
@property (nonatomic, strong, readonly) NSString *subject;
@property (nonatomic, strong, readonly) NSString *preview;
@property (nonatomic, strong, readonly) NSDate *date;
@property (nonatomic, assign) BOOL isRead;
@property (nonatomic, assign, readonly) BOOL hasAttachment;
@property (nonatomic, assign, readonly) BOOL isOfficial;
@property (nonatomic, strong, readonly, nullable) NSNumber *emailCount;

// 初始化方法
- (instancetype)initWithId:(NSString *)id
                    sender:(NSString *)sender
              senderAvatar:(nullable NSString *)senderAvatar
                   subject:(NSString *)subject
                   preview:(NSString *)preview
                dateString:(NSString *)dateString
                    isRead:(BOOL)isRead
             hasAttachment:(BOOL)hasAttachment
                isOfficial:(BOOL)isOfficial
                emailCount:(nullable NSNumber *)emailCount;

// 加载邮件数据
+ (NSArray<MailItem *> *)loadFromPlist;

// 获取模拟数据
+ (NSArray<MailItem *> *)mockEmails;

@end

NS_ASSUME_NONNULL_END
