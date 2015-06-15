//
//  Room.m
//  test
//
//  Created by Yinhaibo on 14-2-27.
//  Copyright (c) 2014年 Yinhaibo. All rights reserved.
//

#import "Encoder.h"

@implementation Door

@synthesize ReceiveTime, RoomCode, isRead, isPreOrder;

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)encoder {
    
	[encoder encodeObject:self.RoomCode forKey:@"RoomCode"];
	[encoder encodeObject:self.ReceiveTime forKey:@"ReceiveTime"];
	[encoder encodeBool:self.isPreOrder forKey:@"isPreOrder"];
	[encoder encodeBool:self.isRead forKey:@"isRead"];
	
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super init];
    if (self) {
        
        self.RoomCode = [decoder decodeObjectForKey:@"RoomCode"];
		self.ReceiveTime = [decoder decodeObjectForKey:@"ReceiveTime"];
        self.isPreOrder = [decoder decodeBoolForKey:@"isPreOrder"];
        self.isRead = [decoder decodeBoolForKey:@"isRead"];
        
	}
	return self;
}

+(NSDate *)stringToDate:(NSString *)str withDateFormater:(NSString *)formater
{
	NSString *strDate = [str stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:formater];
    NSDate *date=[dateFormatter dateFromString:strDate];
	return date;
}

+(NSString *)dateToString:(NSDate *)date withDateFormater:(NSString *)formater
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:formater];
	return [dateFormatter stringFromDate:date];
}

+(NSArray *)arrayWithObjects:(id)firstObj, ...
{
    NSMutableArray *arr = [NSMutableArray array];
    
    va_list args;
    // scan for arguments after firstObject.
    va_start(args, firstObj);
    
    // get rest of the objects until nil is found
    for (id obj = firstObj; &obj != nil; obj = va_arg(args,id)) {
        if (obj==NULL) {
            obj = @"";
        }
        [arr addObject:obj];
    }
    
    va_end(args);
    
    return arr;
}

+ (void)setNullString:(NSString **)string
{
    if (string!=NULL) {
        if (*string==NULL) {
            *string = @"";
        }
    }
}

+ (void)setNullListString:(NSString **)string, ...
{
    va_list args;
    // scan for arguments after firstObject.
    va_start(args, string);
    
    // get rest of the objects until nil is found
    for (NSString **obj = string; obj != nil; obj = va_arg(args,NSString **)) {
        if (*obj==NULL) {
            *obj = @"";
        }
    }
    
    va_end(args);
}

@end
