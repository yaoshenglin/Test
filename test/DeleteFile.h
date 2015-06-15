//
//  DeleteFile.h
//  test
//
//  Created by Yin on 14-4-25.
//  Copyright (c) 2014年 Yinhaibo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeleteFile : NSObject

#pragma mark 删除该文件夹下的所以文件
+(BOOL)deleteDirectoryByPath:(NSString *)path;

+ (void)test;

+(NSArray *)getFileInDirectoryByPath:(NSString *)path;

@end
