//
//  Rooms.h
//  test
//
//  Created by Yin on 14-7-6.
//  Copyright (c) 2014年 Yinhaibo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EnumTypes.h"

@interface Rooms : NSObject
{
    @public
}

@property (nonatomic) int ID;
@property (retain, nonatomic) NSString *name;

- (id)initWithID:(int)theID name:(NSString *)theName;
- (void)StartRun;
- (void)setNumber:(CGFloat)value;
- (void)printValue:(CGFloat)value;
- (NSDate *)dateFromString:(NSString *)str withDateFormater:(NSString *)formater;
+ (NSString *)dateToString:(NSDate *)date withDateFormater:(NSString *)formater;
+ (void)startRequest;
+ (void)requestWithUrl:(NSString *)urlString;

+ (void)PostJson;

+ (NSDate *)dateWith:(NSString *)hourStr week:(Week)weekDay;

+ (void)addProperty:(NSString *)propertyName;

@end
