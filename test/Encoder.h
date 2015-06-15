//
//  Door.h
//  test
//
//  Created by Yinhaibo on 14-2-27.
//  Copyright (c) 2014年 Yinhaibo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Door : NSObject

@property (nonatomic, strong) NSString *RoomCode;
@property (nonatomic, strong) NSString *ReceiveTime;
@property (nonatomic) BOOL isPreOrder;
@property (nonatomic) BOOL isRead;

+(NSDate *)stringToDate:(NSString *)str withDateFormater:(NSString *)formater;

+(NSString *)dateToString:(NSDate *)date withDateFormater:(NSString *)formater;

+(NSArray *)arrayWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION;

+ (void)setNullString:(NSString **)string;

+ (void)setNullListString:(NSString **)string, ... NS_REQUIRES_NIL_TERMINATION;

@end
