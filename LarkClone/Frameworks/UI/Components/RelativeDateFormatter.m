//
//  RelativeDateFormatter.m
//  LarkClone
//
//  Created by 张纪龙 on 2025/5/10.
//

#import "RelativeDateFormatter.h"

@interface RelativeDateFormatter ()
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation RelativeDateFormatter

- (instancetype)init {
    self = [super init];
    if (self) {
        _calendar = [NSCalendar currentCalendar];
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return self;
}

- (NSString *)stringFromDate:(NSDate *)date {
    NSDate *now = [NSDate date];
    
    if ([self.calendar isDateInToday:date]) {
        self.dateFormatter.dateFormat = @"HH:mm";
        return [self.dateFormatter stringFromDate:date];
    } else if ([self.calendar isDateInYesterday:date]) {
        return NSLocalizedStringFromTable(@"yesterday", @"MailTab", @"Yesterday");
    } else if ([self.calendar isDate:date equalToDate:now toUnitGranularity:NSCalendarUnitWeekOfYear]) {
        self.dateFormatter.dateFormat = @"E";
        return [self.dateFormatter stringFromDate:date];
    } else if ([self.calendar isDate:date equalToDate:now toUnitGranularity:NSCalendarUnitYear]) {
        self.dateFormatter.dateFormat = @"M月d日";
        return [self.dateFormatter stringFromDate:date];
    } else {
        self.dateFormatter.dateFormat = @"yyyy/MM/dd";
        return [self.dateFormatter stringFromDate:date];
    }
}

@end
