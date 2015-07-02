//
//  main.m
//  test
//
//  Created by Yinhaibo on 14-1-6.
//  Copyright (c) 2014年 Yinhaibo. All rights reserved.
//  <#(NSString *)#>

#define browPath @"/Volumes/Apple/临时/Face.txt"
#define Log(x) NSLog(@"%@",x)
#define LogD(x) NSLog(@"%d",x)
#define LogLD(x) NSLog(@"%ld",x)
#define NSOK NSLog(@"OK")
#define NSFail NSLog(@"Fail")
#define Linefeed printf("\n")
#define N(x) @(x)
#define S(x) [NSString stringWithCString:x encoding:NSUTF8StringEncoding]
#define Tool "Tools.h"

typedef NS_OPTIONS(NSUInteger, TQRichTextRunTypeList)
{
    TQRichTextRunNoneType  = 0,
    TQRichTextRunURLType   = 1 << 0,
    TQRichTextRunEmojiType = 1 << 1,
};

#import <Foundation/Foundation.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <math.h>
#include <netinet/in.h>
#import "DeviceModel.h"
#import "Tools.h"
#import "Rooms.h"
#import "Encoder.h"
#import "PrintObject.h"
#import "DeleteFile.h"
#import "EnumType.h"
#import "DB.h"
#import "HTTPRequest.h"
#import "Ping.h"
#import "Brands.h"

#define var(var) [NSString stringWithFormat:@"%s",#var]
#define Screen_Width 320.0f
#define viewH 416.0f
#define viewW Screen_Width

FOUNDATION_EXPORT void NSLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

//typedef double NSTimeInterval;

void printHead()
{
    @autoreleasepool {
        NSLog(@"本机IP地址 : %@",[[Tools localIPAddress] convertToString]);
        NSDictionary *dic = [Tools readCustomPath];
        Log(dic[@"iFace"]);
    }
}

NSString *getPath()
{
    return @"/Users/Yin-Mac/Documents/Caches";
}

NSString *getHex(NSInteger value)
{
    NSString *result = [NSString stringWithFormat:@"%02lx",(long)value];
    result = [result uppercaseString];
    return result;
}

int main(int argc, const char * argv[])
{
    printHead();
    @autoreleasepool {
        
//        [Ping PingDomain:@"www.163.com"];//183.61.67.88
//        [Ping PingDomain:@"www.baidu.com"];//180.97.33.107
//        [Ping PingDomain:@"192.168.11.169" count:3];
        
        NSDate *date = [NSDate date];
        
        Brands *brand = [[Brands alloc] init];
        brand.brandname = @"888牌";
        for (int i=0; i<1000; i++) {
            NSString *s1 = [brand getPinyin][@"short"];
            
            NSString *regex = @"^[0-9]+[A-Za-z\u4E00-\u9FA5]*";
            if ([s1 evaluateWithFormat:regex]) {
                
            }
            
            [s1 compare:@"A"];
        }
        
        NSTimeInterval space = [[NSDate date] timeIntervalSinceDate:date];
        NSLog(@"用时 %f s",space);
    }
    return 0;
}

