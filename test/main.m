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
#import "Header.h"
#import "Weather.h"
#import "Temp.h"
#import "NSXMLParser+Cobbler.h"

#define var(v) [NSString stringWithFormat:@"%s",#v]
#define Screen_Width 320.0f
#define viewH 416.0f
#define viewW Screen_Width

//FOUNDATION_EXPORT void NSLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

//typedef double NSTimeInterval;

NSString *printHead(NSString *filePath)
{
    @autoreleasepool {
        filePath = filePath ?: @"";
        NSLog(@"本机IP地址 : %@",[[Tools localIPAddress] stringUsingASCIIEncoding]);
        NSDictionary *dic = [Tools readCustomPath];
        NSString *path = dic[@"iFace"];
        path = [path stringByAppendingPathComponent:filePath];
        if (path) {
            Log(path);
        }
        
        printf("---------------------------------------\n");
        return path;
    }
    
    return nil;
}

void readFile(NSString *path, NSMutableArray *list)
{
    BOOL isDir = NO;
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path isDirectory:&isDir]) {
        if (isDir) {
            NSError *error = nil;
            NSArray *listFile = [manager contentsOfDirectoryAtPath:path error:&error];
            if (error) {
                NSLog(@"%@",error.localizedDescription);
            }
            for (NSString *fileName in listFile) {
                NSString *newPath = [path stringByAppendingPathComponent:fileName];
                readFile(newPath, list);
            }
        }else{
            NSString *name = path.lastPathComponent;
            [list addObject:name];
        }
    }
}

NSArray *compareArray(NSArray *arr1,NSArray *arr2)
{
    NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",arr1];
    NSArray * filter = [arr2 filteredArrayUsingPredicate:filterPredicate];
    return filter;
}

int main(int argc, const char * argv[])
{
    printHead(@"/Volumes/Apple/Applications/IOS_CloudHome/CloudHome/Images/common/绿色背景图@2x.png");
    @autoreleasepool {
        
//        [Ping PingDomain:@"www.163.com"];//183.61.67.88
//        [Ping PingDomain:@"www.baidu.com"];//180.97.33.107
//        [Ping PingDomain:@"192.168.11.169" count:3];
        
        CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
        
        NSString *path = @"/Volumes/Apple/iOS工程/ImgSize/ImgSize/Image";
        NSArray *list = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
        NSString *content = [list componentsJoinedByString:@","];
        
        NSLog(@"%@",content);
    
        NSLog(@"Time: %f", CFAbsoluteTimeGetCurrent() - start);
        
    }
    
    
    return 0;
}

