//
//  MailItem.m
//  LarkClone
//
//  Created by 张纪龙 on 2025/5/10.

#import "MailItem.h"

@interface MailItem ()
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *sender;
@property (nonatomic, strong, nullable) NSString *senderAvatar;
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
              senderAvatar:(nullable NSString *)senderAvatar
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
        _senderAvatar = senderAvatar;
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

+ (NSArray<MailItem *> *)loadFromPlist {
    // 首先尝试从应用程序包中读取
    NSString *path = [[NSBundle mainBundle] pathForResource:@"mock_emails" ofType:@"plist" inDirectory:@"MockData"];
    if (path) {
        NSData *plistData = [[NSFileManager defaultManager] contentsAtPath:path];
        if (plistData) {
            NSError *error;
            NSArray<NSDictionary *> *plistItems = [NSPropertyListSerialization propertyListWithData:plistData options:0 format:NULL error:&error];
            if (plistItems && !error) {
                return [self convertDictionariesToMailItems:plistItems];
            }
        }
    }
    
    // 如果应用程序包中没有，使用模拟数据
    return [self mockEmails];
}

+ (NSArray<MailItem *> *)convertDictionariesToMailItems:(NSArray<NSDictionary *> *)dictionaries {
    NSMutableArray<MailItem *> *items = [NSMutableArray array];
    
    for (NSDictionary *dict in dictionaries) {
        NSString *id = dict[@"id"];
        NSString *sender = dict[@"sender"];
        NSString *subject = dict[@"subject"];
        NSString *preview = dict[@"preview"];
        NSString *dateString = dict[@"date"];
        NSNumber *isReadNum = dict[@"isRead"];
        NSNumber *hasAttachmentNum = dict[@"hasAttachment"];
        NSNumber *isOfficialNum = dict[@"isOfficial"];
        
        // 确保必要的字段存在
        if (!id || !sender || !subject || !preview || !dateString || !isReadNum || !hasAttachmentNum || !isOfficialNum) {
            continue;
        }
        
        NSString *senderAvatar = dict[@"senderAvatar"];
        NSNumber *emailCount = dict[@"emailCount"];
        
        MailItem *item = [[MailItem alloc] initWithId:id
                                               sender:sender
                                         senderAvatar:senderAvatar
                                              subject:subject
                                              preview:preview
                                           dateString:dateString
                                               isRead:[isReadNum boolValue]
                                        hasAttachment:[hasAttachmentNum boolValue]
                                           isOfficial:[isOfficialNum boolValue]
                                           emailCount:emailCount];
        
        [items addObject:item];
    }
    
    return items;
}

+ (NSArray<MailItem *> *)mockEmails {
    return @[
        [[MailItem alloc] initWithId:@"1"
                              sender:@"ByteTech 官方公共邮箱"
                        senderAvatar:nil
                             subject:@"ByteTech | MCP x 业务: 达人选品 AI Agent 简易版发布"
                             preview:@"Dear ByteDancers, ByteTech 本周为你精选了..."
                          dateString:@"2025-05-09 10:50:00"
                              isRead:NO
                       hasAttachment:NO
                          isOfficial:YES
                          emailCount:nil],
        
        [[MailItem alloc] initWithId:@"2"
                              sender:@"张纪龙"
                        senderAvatar:nil
                             subject:@"v7.44 版本启动邮件 - Lark IM & AI Architecture & UI"
                             preview:@"一、版本时间信息 节点 时间 排人会议 2025/04..."
                          dateString:@"2025-04-25 14:30:00"
                              isRead:YES
                       hasAttachment:NO
                          isOfficial:NO
                          emailCount:nil],
        
        [[MailItem alloc] initWithId:@"3"
                              sender:@"乔子铭"
                        senderAvatar:nil
                             subject:@"v7.43 版本启动邮件 - Lark IM & AI Architecture & UI"
                             preview:@"[Lark IM & Product Architecture & AI Arch v7..."
                          dateString:@"2025-04-25 12:15:00"
                              isRead:YES
                       hasAttachment:NO
                          isOfficial:NO
                          emailCount:@2],
        
        [[MailItem alloc] initWithId:@"4"
                              sender:@"The Postman Team"
                        senderAvatar:nil
                             subject:@"[External] Postman API Night 東京のご案内"
                             preview:@""
                          dateString:@"2025-04-25 09:40:00"
                              isRead:YES
                       hasAttachment:NO
                          isOfficial:NO
                          emailCount:nil],
        
        [[MailItem alloc] initWithId:@"5"
                              sender:@"kodeco.com"
                        senderAvatar:nil
                             subject:@"[External] Reset password instructions"
                             preview:@"[图片] Hello supeng.charlie@bytedance.com! ..."
                          dateString:@"2025-04-24 16:50:00"
                              isRead:YES
                       hasAttachment:YES
                          isOfficial:NO
                          emailCount:@2],
        
        [[MailItem alloc] initWithId:@"6"
                              sender:@"系统服务"
                        senderAvatar:nil
                             subject:@"[External] 您有一张来自【北京钟爱纯粹自然餐饮有限公司】的增值税专用发票"
                             preview:@"[图片] 尊敬的客户，您好：北京钟爱纯粹自然..."
                          dateString:@"2025-04-24 13:20:00"
                              isRead:YES
                       hasAttachment:YES
                          isOfficial:NO
                          emailCount:nil],
        
        [[MailItem alloc] initWithId:@"7"
                              sender:@"DeveloperCenter Shanghai"
                        senderAvatar:nil
                             subject:@"[External] Apple 开发者官方微信公众号现已上线"
                             preview:@"尊敬的开发者，我们是 Apple 全球开发者关系团队..."
                          dateString:@"2025-04-24 10:15:00"
                              isRead:YES
                       hasAttachment:NO
                          isOfficial:NO
                          emailCount:nil]
    ];
}

@end
