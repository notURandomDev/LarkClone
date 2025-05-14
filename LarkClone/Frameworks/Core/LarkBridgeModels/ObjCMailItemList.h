//
//  ObjCMailItemList.h
//  LarkBridgeModels
//
//  Created by Kyle Huang on 2025/5/13.
//

#ifndef ObjCMailItemList_h
#define ObjCMailItemList_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ObjCMailItem : NSObject

@property (nonatomic, readonly) NSString *id;
@property (nonatomic, readonly) NSString *sender;
@property (nonatomic, readonly) NSString *subject;
@property (nonatomic, readonly) NSString *preview;
@property (nonatomic, readonly) NSString *dateString;
@property (nonatomic, readonly) BOOL isRead;
@property (nonatomic, readonly) BOOL hasAttachment;
@property (nonatomic, readonly) BOOL isOfficial;
@property (nonatomic, readonly, nullable) NSNumber *emailCount;

@end

NS_ASSUME_NONNULL_END

#endif /* ObjCMailItemList_h */
