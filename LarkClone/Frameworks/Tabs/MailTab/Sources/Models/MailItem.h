//
//  MailItem.h
//  LarkClone
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MailItem : NSObject

@property (nonatomic, readonly) NSString *id;
@property (nonatomic, readonly) NSString *sender;
@property (nonatomic, readonly) NSString *subject;
@property (nonatomic, readonly) NSString *preview;
@property (nonatomic, readonly) NSString *dateString;
@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, assign) BOOL isRead;
@property (nonatomic, readonly) BOOL hasAttachment;
@property (nonatomic, readonly) BOOL isOfficial;
@property (nonatomic, readonly, nullable) NSNumber *emailCount;

#pragma mark - Initialization
- (instancetype)initWithId:(NSString *)id
                    sender:(NSString *)sender
                   subject:(NSString *)subject
                   preview:(NSString *)preview
                dateString:(NSString *)dateString
                    isRead:(BOOL)isRead
             hasAttachment:(BOOL)hasAttachment
                isOfficial:(BOOL)isOfficial
                emailCount:(nullable NSNumber *)emailCount;

#pragma mark - Loading Methods
// 基本加载方法
+ (NSArray<MailItem *> *)loadFromPlist;
+ (NSArray<MailItem *> *)mockEmails;

// 分页加载方法
+ (void)loadFromRustBridgeWithCompletion:(void (^)(NSArray<MailItem *> *items))completion;
+ (void)loadFromRustBridgeWithPage:(NSInteger)page
                          pageSize:(NSInteger)pageSize
                        completion:(void (^)(NSArray<MailItem *> *items, BOOL hasMoreData, NSInteger totalItems))completion;

// 筛选和搜索方法
+ (void)loadCombinedResultsWithPage:(NSInteger)page
                           pageSize:(NSInteger)pageSize
                         searchText:(NSString *)searchText
                         filterType:(NSString *)filterType
                         completion:(void (^)(NSArray<MailItem *> *items, BOOL hasMoreData, NSInteger totalItems))completion;

#pragma mark - File Management
+ (NSString *)getMailPlistPath;
+ (BOOL)updateReadStatus:(NSString *)emailId isRead:(BOOL)isRead;
+ (BOOL)deleteEmail:(NSString *)emailId;

@end

NS_ASSUME_NONNULL_END
