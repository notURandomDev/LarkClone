//
//  MailItem.m
//  LarkClone
//
//  Created by 张纪龙 on 2025/5/10.

#import "MailItem.h"
#import <LarkSDK/LarkSDK-Swift.h>
#import <LarkBridgeModels/ObjCMailItemList.h>

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
        
        // 解析日期字符串
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        _date = [dateFormatter dateFromString:dateString] ?: [NSDate date];
    }
    return self;
}

#pragma mark - Static Methods

+ (void)loadFromRustBridgeWithCompletion:(void (^)(NSArray<MailItem *> *items))completion {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"mock_emails" ofType:@"plist"];
    if (!path) {
        NSLog(@"⚠️ 找不到 plist 路径，fallback 到默认数据");
        completion([self mockEmails]);
        return;
    }

    [RustBridge fetchMailItemsWithPage:0
                              pageSize:10000
                              filePath:path
                            completion:^(NSArray<ObjCMailItem *> * _Nullable objcItems, NSError * _Nullable error) {
        if (error || objcItems == nil) {
            NSLog(@"❌ RustBridge 加载失败：%@", error);
            completion([self mockEmails]);
            return;
        }

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

        completion([converted copy]);
    }];
}


+ (NSArray<MailItem *> *)loadFromPlist {
    // 从应用程序包中读取loadFromPlist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"mock_emails" ofType:@"plist" inDirectory:@"MockData"];
    
    if (!path) {
        // 如果找不到文件，尝试直接从根目录加载
        path = [[NSBundle mainBundle] pathForResource:@"mock_emails" ofType:@"plist"];
        
        if (!path) {
            // 如果仍然找不到文件，使用模拟数据
            NSLog(@"警告: 无法找到mock_emails.plist文件，使用内置模拟数据");
            return [self mockEmails];
        }
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
        
        // 批量处理
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
    
    // 邮件2
    [items addObject:[[MailItem alloc] initWithId:@"2"
                                          sender:@"张纪龙"
                                         subject:@"v7.44 版本启动邮件 - Lark IM & AI Architecture & UI"
                                         preview:@"一、版本时间信息 节点 时间 排人会议 2025/04..."
                                      dateString:@"2025-04-25 14:30:00"
                                          isRead:YES
                                   hasAttachment:NO
                                      isOfficial:NO
                                      emailCount:nil]];
    
    // 邮件3
    [items addObject:[[MailItem alloc] initWithId:@"3"
                                          sender:@"乔子铭"
                                         subject:@"v7.43 版本启动邮件 - Lark IM & AI Architecture & UI"
                                         preview:@"[Lark IM & Product Architecture & AI Arch v7..."
                                      dateString:@"2025-04-25 12:15:00"
                                          isRead:YES
                                   hasAttachment:NO
                                      isOfficial:NO
                                      emailCount:@2]];
    
    // 邮件4
    [items addObject:[[MailItem alloc] initWithId:@"4"
                                          sender:@"The Postman Team"
                                         subject:@"[External] Postman API Night 東京のご案内"
                                         preview:@""
                                      dateString:@"2025-04-25 09:40:00"
                                          isRead:YES
                                   hasAttachment:NO
                                      isOfficial:NO
                                      emailCount:nil]];
    
    // 邮件5
    [items addObject:[[MailItem alloc] initWithId:@"5"
                                          sender:@"kodeco.com"
                                         subject:@"[External] Reset password instructions"
                                         preview:@"[图片] Hello supeng.charlie@bytedance.com! ..."
                                      dateString:@"2025-04-24 16:50:00"
                                          isRead:YES
                                   hasAttachment:YES
                                      isOfficial:NO
                                      emailCount:@2]];
    
    // 邮件6
    [items addObject:[[MailItem alloc] initWithId:@"6"
                                          sender:@"系统服务"
                                         subject:@"[External] 您有一张来自【北京钟爱纯粹自然餐饮有限公司】的增值税专用发票"
                                         preview:@"[图片] 尊敬的客户，您好：北京钟爱纯粹自然..."
                                      dateString:@"2025-04-24 13:20:00"
                                          isRead:YES
                                   hasAttachment:YES
                                      isOfficial:NO
                                      emailCount:nil]];
    
    // 邮件7
    [items addObject:[[MailItem alloc] initWithId:@"7"
                                          sender:@"DeveloperCenter Shanghai"
                                         subject:@"[External] Apple 开发者官方微信公众号现已上线"
                                         preview:@"尊敬的开发者，我们是 Apple 全球开发者关系团队..."
                                      dateString:@"2025-04-24 10:15:00"
                                          isRead:YES
                                   hasAttachment:NO
                                      isOfficial:NO
                                      emailCount:nil]];
    
    // 添加一些随机邮件，确保有足够的测试数据
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

+ (NSArray<MailItem *> *)convertDictionariesToMailItems:(NSArray<NSDictionary *> *)dictionaries {
    NSMutableArray<MailItem *> *items = [NSMutableArray array];
    
    for (NSDictionary *dict in dictionaries) {
        MailItem *item = [self createMailItemFromDictionary:dict];
        if (item) {
            [items addObject:item];
        }
    }
    
    return items;
}

@end
