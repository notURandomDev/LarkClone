//
//  SearchBarView.h
//  LarkClone
//
//  Created by 张纪龙 on 2025/5/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchBarView : UIView

@property (nonatomic, copy) void (^onSearch)(NSString *searchText);

@end

NS_ASSUME_NONNULL_END
