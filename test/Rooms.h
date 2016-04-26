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
@property (nonatomic) int age;
@property (retain, nonatomic) NSString *name;

- (id)initWithID:(int)theID name:(NSString *)theName;
- (void)StartRun;
- (void)setNumber:(CGFloat)value;
- (void)printValue:(CGFloat)value;
- (NSDate *)dateFromString:(NSString *)str withDateFormater:(NSString *)formater;
+ (NSString *)dateToString:(NSDate *)date withDateFormater:(NSString *)formater;
+ (NSData *)ValidCRCWithHost:(NSData *)data;


#pragma mark request
+ (void)startRequest;
+ (NSArray *)requestWithUrl:(NSString *)urlString;
+ (NSArray *)ParseXmlWithString:(NSString *)stringL;

+ (NSArray *)ParseDataFromIFace;

+ (void)PostJson;

+ (NSDate *)dateWith:(NSString *)hourStr week:(Week)weekDay;

+ (void)addProperty:(NSString *)propertyName;

@end
