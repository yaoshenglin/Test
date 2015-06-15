//
//  Rooms.h
//  test
//
//  Created by Yin on 14-7-6.
//  Copyright (c) 2014年 Yinhaibo. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark 星期(Week)
typedef NS_OPTIONS(NSInteger, Week) {
    Week_None       = 0,      // 0
    Week_Sunday     = 1,      // 1  1 1
    Week_Monday     = 1 << 1, // 2  2 10 转换成 10进制 2
    Week_Tuesday    = 1 << 2, // 4  3 100 转换成 10进制 4
    Week_Wednesday  = 1 << 3, // 8  4 1000 转换成 10进制 8
    Week_Thursday   = 1 << 4, // 16 5 10000 转换成 10进制 16
    Week_Friday     = 1 << 5, // 32 6 100000 转换成 10进制 32
    Week_Saturday   = 1 << 6, // 64 7 1000000 转换成 10进制 64
    Week_All        = Week_Monday | Week_Tuesday | Week_Wednesday| Week_Thursday| Week_Friday| Week_Saturday| Week_Sunday, // 127
};

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

@end
