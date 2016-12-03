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
#include <unistd.h>
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
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

NSArray *readChineseFromPath(NSString *path, NSMutableArray *listValue)
{
    BOOL isDir = NO;
    listValue = listValue ?: [NSMutableArray array];
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
                readChineseFromPath(newPath, listValue);
            }
        }else{
            NSString *fileName = path.lastPathComponent;
            if (![fileName hasSuffix:@".m"]) {
                return nil;
            }
            NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
            
            //去掉不需要的部分(比如Log，图片名字，资源文件名字……)
//            content = [content replaceString:@"NSLog(@\"" withString:@"😀"];
//            content = [content replaceString:@"CTBNSLog(@\"" withString:@"😀"];
//            content = [content replaceString:@"%@\"," withString:@",\""];
//            content = [content replaceString:@"[UIImage imageNamed::@\"" withString:@"😀"];
//            content = [content replaceString:@"imageNamed:@\"" withString:@"😀"];
//            content = [content replaceString:@"imageFromLibrary:@\"" withString:@"😀"];
//            content = [content replaceString:@" img:@\"" withString:@"😀"];
//            content = [content replaceString:@" selectedImg:@\"" withString:@"😀"];
//            content = [content replaceString:@" SwitchWithImg:@\"" withString:@"😀"];
//            content = [content replaceString:@" CreateButtonWithImg:@\"" withString:@"😀"];
//            content = [content replaceString:@" pathForResource:@\"" withString:@" pathForResource:@\"✅"];
//            NSArray *list = [content componentSeparatedByString:@"@\""];
//            for (int i=0; i<list.count; i++) {
//                NSString *str = list[i];
//                if (i == 0) {
//                    continue;
//                }
//                
//                NSArray *listO = [str componentSeparatedByString:@"\""];
//                NSString *value = listO.firstObject;
//                
//                //去掉一些没用的(以字符串分割，只要第一部分)
//                value = deleteString(value, @"#pragma mark");
//                value = deleteString(value, @" if (");
//                value = deleteString(value, @" return ");
//                value = deleteString(value, @"//");
//                value = deleteString(value, @"😀");
//                
//                if ([Tools containsChinese:value] && ![listValue containsObject:value]) {
//                    [listValue addObject:value];
//                    //content = [content stringByAppendingFormat:@"%@\n",value];
//                }
//            }
            
            //
            content = [content replaceString:@"NSLocalizedString(" withString:@"😀"];
            content = [content replaceString:@"LocalizedSingle(" withString:@"😀"];
            content = [content replaceString:@"NSLocalizedStr(" withString:@"😀"];
            content = [content replaceString:@"CTBLocalizedStr(" withString:@"😀"];
            content = [content replaceString:@"CTBLocalizedString(" withString:@"😀"];
            content = [content replaceString:@"LocalizedSingles(@[" withString:@"😀"];
            content = [content replaceString:@"])" withString:@"✅"];
            content = [content replaceString:@")" withString:@"✅"];
            NSArray *list = [content componentSeparatedByString:@"😀"];
            for (int i=0; i<list.count; i++) {
                if (i == 0) {
                    continue;
                }
                NSString *str = list[i];
                str = [str deleteSuffix:@"✅"];
                NSArray *listO = [str componentSeparatedByString:@"@\""];
                for (NSString *key in listO) {
                    NSString *value = key;
                    if (key.length > 0) {
                        value = [key deleteSuffix:@"\""];
                        if (![listValue containsObject:value]) {
                            //NSLog(@"%@",value);
                            [listValue addObject:value];
                        }
                    }
                }
            }
        }
    }else{
        NSLog(@"文件夹不存在");
    }
    
    return listValue;
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

NSArray *compareArray(NSArray *arr1,NSArray *arr2)
{
    NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",arr1];
    NSArray * filter = [arr2 filteredArrayUsingPredicate:filterPredicate];
    return filter;
}

int is_debugger_present(void)
{
    int name[4];
    struct kinfo_proc info;
    size_t info_size = sizeof(info);
    
    info.kp_proc.p_flag = 0;
    
    name[0] = CTL_KERN;
    name[1] = KERN_PROC;
    name[2] = KERN_PROC_PID;
    name[3] = getpid();
    
    if (sysctl(name, 4, &info, &info_size, NULL, 0) == -1) {
        perror("sysctl");
        exit(-1);
    }
    return ((info.kp_proc.p_flag & P_TRACED) != 0);
}

int main(int argc, const char * argv[])
{
    printHead(@"");
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
        
        //NSString *path = @"/Users/Yin-Mac/Movies/wifi_v2.06.bin";
        //NSData *data = [NSData dataWithContentsOfFile:path];
        //data = [Rooms ValidCRCWithHost:data];
        
//        NSString *path = @"/Users/Yin-Mac/Library/MobileDevice/Provisioning Profiles/89de85c3-0bd7-4ae1-a4f5-3b5c481d567e.mobileprovision";
//        NSData *data = [NSData dataWithContentsOfFile:path];
//        NSStringEncoding encoding = NSASCIIStringEncoding;
//        NSString *str = [[NSString alloc] initWithData:data encoding:encoding];
//        
//        NSLog(@"%@",str);
        
        
        
//        NSString *prefixString = @"WaitLogin";
//        NSString *suffixString = @"正在登录中,请稍候...";//x
//        NSString *engString = @"Being logged in,please wait……";//
//        
//        NSString *content1 = [NSString format:@"\"%@\" = \"%@\";",prefixString,suffixString];
//        NSString *content2 = [NSString format:@"\"%@\" = \"%@\";\n\n",prefixString,engString];
//        NSString *content3 = [NSString format:@"LocalizedSingle(@\"%@\")\n\n",prefixString];
//        
//        printf("\n%s\n",content1.UTF8String);
//        printf("%s",content2.UTF8String);
//        printf("%s",content3.UTF8String);
//        
//        content1 = [NSString format:@"\"%@\" = \"%@\";",prefixString,suffixString];
//        content2 = [NSString format:@"\"%@\" = \"%@\";\n",prefixString,engString];
//        
//        NSString *path = @"/Users/xy/Documents/CrashInfo/中文翻译.txt";
//        [Tools writeDataToPath:path content:content1];
//        [Tools writeDataToPath:path content:content2];
        
        NSString *path = @"/Volumes/Apple/SVN/IOS_iFace/iFace";
//        NSArray *listValue = readChineseFromPath(path, nil);
//        NSLog(@"%@",[listValue description]);
        
        path = @"/Volumes/Apple/SVN/IOS_iFace/iFace/en.lproj/Localizable.strings";
        NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        
        NSMutableArray *listValue = [NSMutableArray array];
        NSArray *list = [content componentSeparatedByString:@";"];
        for (int i=0; i<list.count; i++) {
            NSString *keyValue = list[i];
            if (keyValue.length > 0 && [keyValue containsString:@"\" = \""]) {
                NSArray *listKey = [keyValue componentSeparatedByString:@"\" = \""];
                NSString *key = listKey.lastObject;
                key = [key deletePrefix:@"\""];
                if (key.length > 0) {
                    [listValue addObject:key];
                }
            }
        }
        
        NSMutableArray *listResult = [NSMutableArray array];
        for (NSString *key in listValue) {
            if (![listResult containsObject:key]) {
                [listResult addObject:key];
            }else{
                NSLog(@"key = \"%@\"",key);
            }
        }
        
//        NSArray *dataArray = @[@"2014-04-01",@"2014-04-02",@"2014-04-03",
//                               @"2014-04-01",@"2014-04-02",@"2014-04-03",
//                               @"2014-04-01",@"2014-04-03",@"2014-04-03",
//                               @"2014-04-01",@"2014-04-02",@"2014-04-03",
//                               @"2014-04-01",@"2014-04-02",@"2014-04-03",
//                               @"2014-04-01",@"2014-04-02",@"2014-04-03",
//                               @"2014-04-04",@"2014-04-06",@"2014-04-08",
//                               @"2014-04-05",@"2014-04-07",@"2014-04-09",];
//        NSSet *set = [NSSet setWithArray:dataArray];
//        NSLog(@"%@",[set allObjects]);
        
        //中英文键值表
//        NSError *error = nil;
//        NSString *path = @"/Users/xy/Documents/Caches/Localizable.strings";
//        NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
//        if (error) {
//            NSLog(@"%@",error.localizedDescription);
//        }else{
//            NSLog(@"%@",content);
//        }
        
//        NSString *str = @"3c21444f43545950";
//        NSData *data = [str dataByHexString];
//        NSString *value = [data stringUsingEncoding:NSASCIIStringEncoding];
//        
//        NSLog(@"value = %@",value);
    }
    
    
    return 0;
}

