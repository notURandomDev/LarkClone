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
                   subject:(NSString *)subject
                   preview:(NSString *)preview
                dateString:(NSString *)dateString
                    isRead:(BOOL)isRead
             hasAttachment:(BOOL)hasAttachment
                isOfficial:(BOOL)isOfficial
                emailCount:(nullable NSNumber *)emailCount;

// 加载邮件数据
+ (NSArray<MailItem *> *)loadFromPlist;

// 异步加载邮件数据
+ (void)loadFromRustBridgeWithCompletion:(void (^)(NSArray<MailItem *> *items))completion;

// 分页加载邮件
+ (void)loadFromRustBridgeWithPage:(NSInteger)page
                          pageSize:(NSInteger)pageSize
                        completion:(void (^)(NSArray<MailItem *> *items, BOOL hasMoreData, NSInteger totalItems))completion;


// 获取模拟数据
+ (NSArray<MailItem *> *)mockEmails;

/**
 * 将邮件的已读状态并持久化到文件
 * @param emailId 需要更新的邮件ID
 * @param isRead 是否已读
 * @return 操作是否成功
 */
+ (BOOL)updateReadStatus:(NSString *)emailId isRead:(BOOL)isRead;

/**
 * 删除指定ID的邮件并持久化到文件
 * @param emailId 需要删除的邮件ID
 * @return 操作是否成功
 */
+ (BOOL)deleteEmail:(NSString *)emailId;


 // 先尝试获取Documents目录下的文件，如果不存在则复制bundle中的文件
+ (NSString *)getMailPlistPath;

@end

NS_ASSUME_NONNULL_END
