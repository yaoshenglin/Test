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
#import Tool
#import "Tools.h"
#import "Rooms.h"
#import "Encoder.h"
#import "PrintObject.h"
#import "DeleteFile.h"
#import "EnumType.h"
#import "DB.h"
#import "HTTPRequest.h"
#import "Ping.h"

#define var(var) [NSString stringWithFormat:@"%s",#var]

FOUNDATION_EXPORT void NSLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

#pragma mark 发送超时时间(主机)(Enum_ReceiveTimeOut)
typedef NS_ENUM(int, Enum_ReceiveTimeOut) {
    
    TimeOut_Never       = -1,          //默认不设置超时
    TimeOut_Online      = 5,          //远程模式超时（单位：秒）
    TimeOut_Offline     = 3           //离线模式超时（单位：秒）
};

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
        
        Rooms *room = [[Rooms alloc] initWithID:1 name:@"A"];
        NSArray *list = @[room];
        NSInteger index = [list indexOfObject:nil];
        if ([list containsObject:nil]) {
            NSOK;
        }else{
            NSFail;
        }
        if (index == NSNotFound) {
            NSOK;
        }
    }
    return 0;
}

