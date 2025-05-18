//
//  MailItem.m
//  LarkClone
//
//  Created by 张纪龙 on 2025/5/10.

#import "MailItem.h"
#if __has_include(<LarkSDK/LarkSDK-Swift.h>)
    // 使用 RustBridge 的代码
    #import <LarkSDK/LarkSDK-Swift.h>
    #ifdef IS_XCODE_BUILD
        #import <LarkBridgeModels/ObjCMailItemList.h>
    #else
        #import <LarkBridgeModels/LarkBridgeModels-Swift.h>
    #endif

#endif



@interface MailItem ()
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *sender;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *preview;
@property (nonatomic, strong) NSString *dateString;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) BOOL hasAttachment;
@property (nonatomic, assign) BOOL isOfficial;
@property (nonatomic, strong, readwrite, nullable) NSNumber *emailCount;
@end

@implementation MailItem

#pragma mark - Initialization

- (instancetype)initWithId:(NSString *)id
                    sender:(NSString *)sender
                   subject:(NSString *)subject
                   preview:(NSString *)preview
                dateString:(NSString *)dateString
                    isRead:(BOOL)isRead
             hasAttachment:(BOOL)hasAttachment
                isOfficial:(BOOL)isOfficial
                emailCount:(nullable NSNumber *)emailCount {
    self = [super init];
    if (self) {
        _id = id;
        _sender = sender;
        _subject = subject;
        _preview = preview;
        _dateString = dateString;
        _isRead = isRead;
        _hasAttachment = hasAttachment;
        _isOfficial = isOfficial;
        _emailCount = emailCount;
        
        // 改进日期解析：添加固定的locale和时区设置以提高解析成功率
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        
        // 确保NSDateFormatter的行为一致
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        
        // 尝试解析日期
        NSDate *parsedDate = [dateFormatter dateFromString:dateString];
        
        // 如果解析失败，检查是否有毫秒格式
        if (!parsedDate && [dateString containsString:@"."]) {
            // 尝试带毫秒的格式
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
            parsedDate = [dateFormatter dateFromString:dateString];
        }
        
        // 仍然失败，尝试几种常见格式
        if (!parsedDate) {
            NSArray *formats = @[
                @"yyyy-MM-dd",
                @"yyyy/MM/dd HH:mm:ss",
                @"yyyy/MM/dd"
            ];
            
            for (NSString *format in formats) {
                dateFormatter.dateFormat = format;
                parsedDate = [dateFormatter dateFromString:dateString];
                if (parsedDate) break;
            }
        }
        
        // 所有解析方法都失败时才使用当前时间，并记录警告
        if (!parsedDate) {
            NSLog(@"⚠️ 警告: 无法解析日期字符串 '%@'，使用当前时间作为替代", dateString);
            parsedDate = [NSDate date];
        }
        
        _date = parsedDate;
    }
    return self;
}

#pragma mark - Loading Methods

// 从Rust桥接分页加载
+ (void)loadFromRustBridgeWithPage:(NSInteger)page
                          pageSize:(NSInteger)pageSize
                        completion:(void (^)(NSArray<MailItem *> *items, BOOL hasMoreData, NSInteger totalItems))completion {
    NSString *path = [self getMailPlistPath];
    if (!path) {
        NSLog(@"⚠️ 找不到 plist 路径，fallback 到默认数据");
        NSArray *mockData = [self mockEmails];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(mockData, NO, mockData.count);
        });
        return;
    }

    // 使用RustBridge进行加载
    [RustBridge fetchMailItemsWithPage:(int)page
                              pageSize:(int)pageSize
                              filePath:path
                            completion:^(NSArray<ObjCMailItem *> * _Nullable objcItems, NSError * _Nullable error) {
        if (error || objcItems == nil) {
            NSLog(@"❌ RustBridge 加载失败：%@", error);
            NSArray *mockData = [self mockEmails];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(mockData, NO, mockData.count);
            });
            return;
        }

        // 计算分页信息
        NSInteger totalItems = 0;
        BOOL hasMoreData = NO;
        
        if (objcItems.count == pageSize) {
            hasMoreData = YES;
            totalItems = (page + 1) * pageSize + pageSize; // 估计值
        } else {
            totalItems = page * pageSize + objcItems.count;
            hasMoreData = NO;
        }
        
        // 转换为MailItem对象
        NSMutableArray<MailItem *> *converted = [NSMutableArray arrayWithCapacity:objcItems.count];
        for (ObjCMailItem *item in objcItems) {
            MailItem *mail = [[MailItem alloc] initWithId:item.id
                                                   sender:item.sender
                                                  subject:item.subject
                                                  preview:item.preview
                                               dateString:item.dateString
                                                   isRead:item.isRead
                                            hasAttachment:item.hasAttachment
                                               isOfficial:item.isOfficial
                                               emailCount:item.emailCount];
            [converted addObject:mail];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion([converted copy], hasMoreData, totalItems);
        });
    }];
}

// 向后兼容的加载方法
+ (void)loadFromRustBridgeWithCompletion:(void (^)(NSArray<MailItem *> *items))completion {
    [self loadFromRustBridgeWithPage:0 pageSize:15 completion:^(NSArray<MailItem *> *items, BOOL hasMoreData, NSInteger totalItems) {
        completion(items);
    }];
}

// 统一的搜索和筛选加载方法
+ (void)loadCombinedResultsWithPage:(NSInteger)page
                           pageSize:(NSInteger)pageSize
                         searchText:(NSString *)searchText
                         filterType:(NSString *)filterType
                         completion:(void (^)(NSArray<MailItem *> *items, BOOL hasMoreData, NSInteger totalItems))completion {
    
    // 如果没有搜索和筛选条件，直接使用RustBridge加载
    if (searchText.length == 0 && filterType.length == 0) {
        [self loadFromRustBridgeWithPage:page pageSize:pageSize completion:completion];
        return;
    }
    
    // 后台高优先级处理
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        @autoreleasepool {
            // 获取plist文件路径
            NSString *plistPath = [self getMailPlistPath];
            if (!plistPath) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(@[], NO, 0);
                });
                return;
            }
            
            // 优化数据读取
            NSData *plistData = [NSData dataWithContentsOfFile:plistPath
                                                      options:NSDataReadingMappedIfSafe
                                                        error:nil];
            if (!plistData) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(@[], NO, 0);
                });
                return;
            }
            
            // 解析plist数据
            NSError *error;
            NSArray *allEmails = [NSPropertyListSerialization propertyListWithData:plistData
                                                                          options:NSPropertyListImmutable
                                                                           format:NULL
                                                                            error:&error];
            
            if (error || ![allEmails isKindOfClass:[NSArray class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(@[], NO, 0);
                });
                return;
            }
            
            // 准备搜索条件
            NSString *lowercaseSearchText = searchText.length > 0 ? [searchText lowercaseString] : nil;
            
            // 预计算符合条件的邮件索引
            NSMutableArray<NSNumber *> *matchingIndices = [NSMutableArray array];
            
            // 高效的索引扫描
            [allEmails enumerateObjectsUsingBlock:^(NSDictionary *emailDict, NSUInteger idx, BOOL *stop) {
                BOOL matchesFilter = YES;
                BOOL matchesSearch = YES;
                
                // 应用筛选条件
                if (filterType.length > 0) {
                    if ([filterType isEqualToString:@"unread"]) {
                        matchesFilter = ![emailDict[@"isRead"] boolValue];
                    } else if ([filterType isEqualToString:@"attachment"]) {
                        matchesFilter = [emailDict[@"hasAttachment"] boolValue];
                    }
                    
                    if (!matchesFilter) return;
                }
                
                // 应用搜索条件
                if (lowercaseSearchText.length > 0) {
                    NSString *sender = [emailDict[@"sender"] lowercaseString] ?: @"";
                    NSString *subject = [emailDict[@"subject"] lowercaseString] ?: @"";
                    NSString *preview = [emailDict[@"preview"] lowercaseString] ?: @"";
                    
                    matchesSearch = [sender containsString:lowercaseSearchText] ||
                                   [subject containsString:lowercaseSearchText] ||
                                   [preview containsString:lowercaseSearchText];
                    
                    if (!matchesSearch) return;
                }
                
                // 保存匹配的索引
                [matchingIndices addObject:@(idx)];
            }];
            
            // 计算分页信息
            NSInteger totalCount = matchingIndices.count;
            NSInteger startIndex = page * pageSize;
            NSInteger endIndex = MIN(startIndex + pageSize, totalCount);
            BOOL hasMoreData = endIndex < totalCount;
            
            NSMutableArray<MailItem *> *pagedItems = [NSMutableArray array];
            
            // 处理无结果的情况
            if (totalCount == 0 || startIndex >= totalCount) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(@[], NO, 0);
                });
                return;
            }
            
            // 创建当前页对象
            for (NSInteger i = startIndex; i < endIndex; i++) {
                NSUInteger originalIndex = [matchingIndices[i] unsignedIntegerValue];
                NSDictionary *dict = allEmails[originalIndex];
                MailItem *item = [self createMailItemFromDictionary:dict];
                if (item) {
                    [pagedItems addObject:item];
                }
            }
            
            // 返回结果
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(pagedItems, hasMoreData, totalCount);
            });
        }
    });
}

// 从plist加载所有邮件
+ (NSArray<MailItem *> *)loadFromPlist {
    NSString *path = [self getMailPlistPath];
    
    if (!path) {
        NSLog(@"警告: 无法找到mock_emails.plist文件，使用内置模拟数据");
        return [self mockEmails];
    }
    
    @autoreleasepool {
        NSData *plistData = [NSData dataWithContentsOfFile:path];
        if (!plistData) {
            NSLog(@"警告: 无法读取plist文件数据，使用内置模拟数据");
            return [self mockEmails];
        }
        
        NSError *error;
        id plistObject = [NSPropertyListSerialization propertyListWithData:plistData
                                                                   options:NSPropertyListImmutable
                                                                    format:NULL
                                                                     error:&error];
        
        if (error || ![plistObject isKindOfClass:[NSArray class]]) {
            NSLog(@"警告: plist解析错误: %@，使用内置模拟数据", error);
            return [self mockEmails];
        }
        
        NSArray<NSDictionary *> *plistItems = (NSArray<NSDictionary *> *)plistObject;
        NSMutableArray<MailItem *> *items = [NSMutableArray arrayWithCapacity:plistItems.count];
        
        for (NSDictionary *dict in plistItems) {
            @autoreleasepool {
                MailItem *item = [self createMailItemFromDictionary:dict];
                if (item) {
                    [items addObject:item];
                }
            }
        }
        
        NSLog(@"成功从plist加载了 %lu 封邮件", (unsigned long)items.count);
        return [items copy];
    }
}

#pragma mark - File Management

+ (NSString *)getMailPlistPath {
    // 获取Documents目录路径
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"mock_emails.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 检查bundle中的文件
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"mock_emails" ofType:@"plist"];
    
    // 检查是否需要更新文件
    if (bundlePath) {
        BOOL shouldUpdateFile = NO;
        
        // 检查是否应该更新文件
        if ([fileManager fileExistsAtPath:plistPath]) {
            // 比较修改时间
            NSDictionary *bundleAttrs = [fileManager attributesOfItemAtPath:bundlePath error:nil];
            NSDictionary *docAttrs = [fileManager attributesOfItemAtPath:plistPath error:nil];
            
            NSDate *bundleDate = bundleAttrs[NSFileModificationDate];
            NSDate *docDate = docAttrs[NSFileModificationDate];
            
            // 如果bundle文件更新，则使用bundle文件
            if ([bundleDate compare:docDate] == NSOrderedDescending) {
                shouldUpdateFile = YES;
                NSLog(@"📍 Bundle文件较新，将更新Documents中的文件");
            } else {
                NSLog(@"📍 使用现有的Documents文件");
            }
        } else {
            shouldUpdateFile = YES;
            NSLog(@"📍 Documents中不存在文件，将从Bundle复制");
        }
        
        // 更新文件
        if (shouldUpdateFile) {
            // 删除旧文件
            if ([fileManager fileExistsAtPath:plistPath]) {
                [fileManager removeItemAtPath:plistPath error:nil];
                NSLog(@"📍 已删除旧文件");
            }
            
            // 复制新文件
            NSError *copyError;
            [fileManager copyItemAtPath:bundlePath toPath:plistPath error:&copyError];
        }
    } else {
        NSLog(@"📍 Bundle中不存在文件，使用Documents文件或创建新文件");
    }
    return plistPath;
}

+ (BOOL)updateReadStatus:(NSString *)emailId isRead:(BOOL)isRead {
    // 获取plist文件路径
    NSString *plistPath = [self getMailPlistPath];
    if (!plistPath) {
        NSLog(@"无法获取plist文件路径");
        return NO;
    }
    
    // 读取plist文件内容
    NSMutableArray *emails = [NSMutableArray arrayWithContentsOfFile:plistPath];
    if (!emails) {
        NSLog(@"无法读取plist文件内容");
        return NO;
    }
    
    // 查找并更新邮件的已读状态
    BOOL found = NO;
    for (NSMutableDictionary *email in emails) {
        if ([email[@"id"] isEqualToString:emailId]) {
            email[@"isRead"] = isRead ? @YES : @NO;
            found = YES;
            break;
        }
    }
    
    if (!found) {
        NSLog(@"未找到ID为%@的邮件", emailId);
        return NO;
    }
    
    // 写回plist文件
    BOOL success = [emails writeToFile:plistPath atomically:YES];
    if (!success) {
        NSLog(@"写入plist文件失败");
    } else {
        NSLog(@"成功更新邮件已读状态: ID=%@, isRead=%@", emailId, isRead ? @"YES" : @"NO");
    }
    
    return success;
}

+ (BOOL)deleteEmail:(NSString *)emailId {
    // 获取plist文件路径
    NSString *plistPath = [self getMailPlistPath];
    if (!plistPath) {
        NSLog(@"无法获取plist文件路径");
        return NO;
    }
    
    // 读取plist文件内容
    NSMutableArray *emails = [NSMutableArray arrayWithContentsOfFile:plistPath];
    if (!emails) {
        NSLog(@"无法读取plist文件内容");
        return NO;
    }
    
    // 查找并删除邮件
    NSInteger indexToDelete = -1;
    for (NSInteger i = 0; i < emails.count; i++) {
        NSDictionary *email = emails[i];
        if ([email[@"id"] isEqualToString:emailId]) {
            indexToDelete = i;
            break;
        }
    }
    
    if (indexToDelete == -1) {
        NSLog(@"未找到ID为%@的邮件", emailId);
        return NO;
    }
    
    // 删除邮件
    [emails removeObjectAtIndex:indexToDelete];
    
    // 写回plist文件
    BOOL success = [emails writeToFile:plistPath atomically:YES];
    if (!success) {
        NSLog(@"写入plist文件失败");
    } else {
        NSLog(@"成功删除邮件: ID=%@", emailId);
    }
    
    return success;
}

#pragma mark - Utility Methods

+ (MailItem *)createMailItemFromDictionary:(NSDictionary *)dict {
    // 验证必要字段
    NSString *id = dict[@"id"];
    NSString *sender = dict[@"sender"];
    NSString *subject = dict[@"subject"];
    NSString *preview = dict[@"preview"];
    NSString *dateString = dict[@"date"];
    NSNumber *isReadNum = dict[@"isRead"];
    NSNumber *hasAttachmentNum = dict[@"hasAttachment"];
    NSNumber *isOfficialNum = dict[@"isOfficial"];
    
    if (!id || !sender || !subject || !dateString ||
        !isReadNum || !hasAttachmentNum || !isOfficialNum) {
        return nil;
    }
    
    // 获取可选字段
    NSNumber *emailCount = dict[@"emailCount"];
    
    // 处理空预览
    NSString *finalPreview = preview ?: @"";
    
    return [[MailItem alloc] initWithId:id
                                 sender:sender
                                subject:subject
                                preview:finalPreview
                             dateString:dateString
                                 isRead:[isReadNum boolValue]
                          hasAttachment:[hasAttachmentNum boolValue]
                             isOfficial:[isOfficialNum boolValue]
                             emailCount:emailCount];
}

#pragma mark - Mock Data

+ (NSArray<MailItem *> *)mockEmails {
    // 创建模拟邮件数据，当plist加载失败时使用
    NSMutableArray<MailItem *> *items = [NSMutableArray array];
    
    // 邮件1
    [items addObject:[[MailItem alloc] initWithId:@"1"
                                          sender:@"ByteTech 官方公共邮箱"
                                         subject:@"ByteTech | MCP x 业务: 达人选品 AI Agent 简易版发布"
                                         preview:@"Dear ByteDancers, ByteTech 本周为你精选了..."
                                      dateString:@"2025-05-09 10:50:00"
                                          isRead:NO
                                   hasAttachment:NO
                                      isOfficial:YES
                                      emailCount:nil]];
    
    // 邮件2-7 省略...
    
    // 添加一些随机邮件
    NSArray *senders = @[@"黄子烨", @"苏鹏", @"蒋元", @"严文华", @"王恂"];
    NSArray *subjects = @[
        @"会议通知 - 下周",
        @"项目进度 - 本周",
        @"新产品发布 - 重要提醒",
        @"系统升级 - 周末",
        @"安全警告 - 紧急"
    ];
    NSArray *previews = @[
        @"会议将在下午3点在会议室A举行，请准时参加...",
        @"本月项目进展顺利，预计按时完成交付...",
        @"新产品即将在下周正式发布，敬请期待...",
        @"系统将在本周末进行维护，预计影响时间为2小时...",
        @"发现您的账户有异常登录，请及时修改密码..."
    ];
    
    for (int i = 8; i < 20; i++) {
        NSInteger randomIndex = arc4random_uniform((uint32_t)senders.count);
        NSInteger randomSubjectIndex = arc4random_uniform((uint32_t)subjects.count);
        NSInteger randomPreviewIndex = arc4random_uniform((uint32_t)previews.count);
        
        // 创建随机日期
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setDay:-(int)(arc4random_uniform(30))];
        NSDate *randomDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:[NSDate date] options:0];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *dateString = [formatter stringFromDate:randomDate];
        
        [items addObject:[[MailItem alloc] initWithId:[NSString stringWithFormat:@"%d", i]
                                             sender:senders[randomIndex]
                                            subject:subjects[randomSubjectIndex]
                                            preview:previews[randomPreviewIndex]
                                         dateString:dateString
                                             isRead:arc4random_uniform(2) == 0
                                      hasAttachment:arc4random_uniform(2) == 0
                                         isOfficial:NO
                                         emailCount:arc4random_uniform(3) == 0 ? @(arc4random_uniform(5) + 2) : nil]];
    }
    
    // 按日期排序
    [items sortUsingComparator:^NSComparisonResult(MailItem *email1, MailItem *email2) {
        return [email2.date compare:email1.date];
    }];
    
    return items;
}

@end
