//
//  DeleteFile.m
//  test
//
//  Created by Yin on 14-4-25.
//  Copyright (c) 2014年 Yinhaibo. All rights reserved.
//

#import "DeleteFile.h"

@implementation DeleteFile

#pragma mark 删除该文件夹下的所以文件
+(BOOL)deleteDirectoryByPath:(NSString *)path
{
    NSString *lastPart = [path lastPathComponent];//获取路径下的最后一部分
    //判断最后一部分是否为文件名
    if ([lastPart rangeOfString:@"."].location!=NSNotFound) {
        //删除文件名,获得路径
        path = [path stringByDeletingLastPathComponent];
    }
    NSString *FilePath = [path stringByExpandingTildeInPath];//扩展成路径
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator *direnum = [manager enumeratorAtPath:FilePath];
    
    NSArray *listAllItems = [direnum allObjects];
    BOOL isExist = NO;
    if (listAllItems.count>0) {
        isExist = YES;
    }else{
        isExist = NO;
    }
    
    direnum = [manager enumeratorAtPath:FilePath];
    NSString *filename = nil;
    while (filename = [direnum nextObject]) {
        NSError *error = nil;
        NSString *ItemPath = [FilePath stringByAppendingPathComponent:filename];
        [manager removeItemAtPath:ItemPath error:&error];
        if (error) {
            NSLog(@"错误:%@",error.localizedDescription);
        }
    }
    
    return isExist;
}

+ (void)test
{
    NSArray *arrFileName = [DeleteFile getFileInDirectoryByPath:@"/Users/xy/Pictures/首页pic/大图标"];
    for (NSString *str in arrFileName) {
        if (![str hasSuffix:@"@2x.png"]) {
            NSLog(@"%@",str);
        }
    }
}

+(NSArray *)getFileInDirectoryByPath:(NSString *)path
{
    NSString *lastPart = [path lastPathComponent];//获取路径下的最后一部分
    //判断最后一部分是否为文件名
    if ([lastPart rangeOfString:@"."].location!=NSNotFound) {
        //删除文件名,获得路径
        path = [path stringByDeletingLastPathComponent];
    }
    NSString *FilePath = [path stringByExpandingTildeInPath];//扩展成路径
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator *direnum = [manager enumeratorAtPath:FilePath];
    
    NSArray *listAllItems = [direnum allObjects];
    return listAllItems;
}

@end
