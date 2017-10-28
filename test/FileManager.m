//
//  FileManager.m
//  test
//
//  Created by xy on 2017/10/20.
//  Copyright © 2017年 Yinhaibo. All rights reserved.
//

#import "FileManager.h"

@implementation FileManager

+ (void)comparePath:(NSString *)path1 withPath:(NSString *)path2
{
    //NSString *path1 = @"/Volumes/Apple/Git/LinPhoneTestDemo/LinPhoneTestDemo/liblinphone-sdk/apple-darwin/lib";
    //NSString *path2 = @"/Volumes/Apple/解压缩文件/liblinphone-sdk/apple-darwin/lib";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *list1 = [fileManager contentsOfDirectoryAtPath:path1 error:nil];
    NSArray *list2 = [fileManager contentsOfDirectoryAtPath:path2 error:nil];
    
    if (list2.count != list1.count) {
        NSLog(@"两者相差:%ld",list2.count-list1.count);
    }
    
    BOOL isContain = YES;
    for (NSString *name in list1) {
        if (![list2 containsObject:name]) {
            //path1中的文件有在path2中不存在
            isContain = NO;
            NSLog(@"%@",name);
        }
    }
    
    //path1中的文件在path2中全部存在
//    if (isContain) {
//        for (NSString *name in list2) {
//            //将path2中的文件写入path1中
//            NSString *filePath2 = [path2 stringByAppendingPathComponent:name];
//            NSString *filePath1 = [path1 stringByAppendingPathComponent:name];
//            NSData *data = [NSData dataWithContentsOfFile:filePath2];
//            [data writeToFile:filePath1 atomically:YES];
//        }
//    }
}

@end
