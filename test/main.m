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

#define var(v) [NSString stringWithFormat:@"%s",#v]
#define Screen_Width 320.0f
#define viewH 416.0f
#define viewW Screen_Width

//FOUNDATION_EXPORT void NSLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

//typedef double NSTimeInterval;

void printHead()
{
    @autoreleasepool {
        NSLog(@"本机IP地址 : %@",[[Tools localIPAddress] convertToString]);
        NSDictionary *dic = [Tools readCustomPath];
        Log(dic[@"iFace"]);
        printf("---------------------------------------\n");
    }
}

void deleteCrashFile()
{
    NSError *error = nil;
    NSDictionary *dic = [Tools readCustomPath];
    NSString *path = dic[@"iFace"];
    path = [path stringByAppendingPathComponent:@"CrashInfo"];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path]) {
        NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: path error:nil];
        if (directoryContents.count > 0) {
            if (![manager removeItemAtPath:path error:&error]) {
                if (error) {
                    NSLog(@"删除文件, %@",error.localizedDescription);
                }else{
                    NSLog(@"删除文件失败");
                }
            }else{
                NSLog(@"删除Crash文件成功");
            }
        }else{
            NSLog(@"Crash文件不存在");
        }
    }else{
        NSLog(@"Crash文件夹不存在");
    }
}

void deleteImage()
{
    @autoreleasepool {
        NSDictionary *dic = [Tools readCustomPath];
        NSString *path = [dic objectForKey:@"iFace"];
        path = [path stringByAppendingPathComponent:@"images"];
        NSFileManager *manager = [NSFileManager defaultManager];
        NSError *error = nil;
        if ([manager fileExistsAtPath:path]) {
            if (![manager removeItemAtPath:path error:&error]) {
                if (error) {
                    NSLog(@"删除文件, %@",error.localizedDescription);
                }else{
                    NSLog(@"删除文件失败");
                }
            }else{
                NSLog(@"删除成功");
            }
        }else{
            NSLog(@"文件不存在");
        }
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

void BatchRename()
{
    NSError *error = nil;
    NSString *path = @"/Users/Yin-Mac/Documents/其它/批量重命名.txt";
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"读取文件失败,%@",error.localizedDescription);
    }else{
        char *str = (char *)[content UTF8String];
        printf("%s\n",str);
    }
}

int main(int argc, const char * argv[])
{
    printHead();
    @autoreleasepool {
        
//        [Ping PingDomain:@"www.163.com"];//183.61.67.88
//        [Ping PingDomain:@"www.baidu.com"];//180.97.33.107
//        [Ping PingDomain:@"192.168.11.169" count:3];
        
//        NSString *path = @"http://www.baidu.com";
//        //path = [path stringByExpandingTildeInPath];
//        NSString *format = @"^((https?|ftp|news):\\/\\/)?([a-z]([a-z0-9\\-]*[\\.])+([a-z]{2}|aero|arpa|biz|com|coop|edu|gov|info|int|jobs|mil|museum|name|nato|net|org|pro|travel)|(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]))(\\/[a-z0-9_\\-\\.~]+)*(\\/([a-z0-9_\\-\\.]*)(\\?[a-z0-9+_\\-\\.%=&]*)?)?(#[a-z][a-z0-9_]*)?$";
//        format = @"^http[s]{0,1}$";
//        
//        if ([path evaluateWithFormat:format]) {
//            NSOK;
//        }
        
        
        Rooms *room = [[Rooms alloc] init];
        room.name = @"A";
        
        NSLog(@"value = %@", [room valueForKey:@"name"]);
    }
    
    return 0;
}

