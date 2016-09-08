//
//  ExpendFileAttributes.m
//  test
//
//  Created by xy on 16/9/6.
//  Copyright © 2016年 Yinhaibo. All rights reserved.
//
/**
 *   ExpendFileAttributes工具类下载源码：https://github.com/HeYang123456789/NSURLSession-ExpendedAttributesTool
 */


#import "ExpendFileAttributes.h"

#include <sys/xattr.h>

@implementation ExpendFileAttributes
//为文件增加一个扩展属性
+ (BOOL)addExtendedAttributeWithPath:(NSString *)path key:(NSString *)key value:(NSString *)stringValue
{
    NSData *value = [stringValue dataUsingEncoding:NSUTF8StringEncoding];
    ssize_t writelen = setxattr([path fileSystemRepresentation],
                                [key UTF8String],
                                [value bytes],
                                [value length],
                                0,
                                0);
    return writelen==0?YES:NO;
}

+ (BOOL)addExtendedAttributeWithPath:(NSString *)path attributes:(NSDictionary *)attributes
{
    if (attributes.count <= 0) {
        return NO;
    }
    
    BOOL result = YES;
    for (NSString *key in attributes) {
        id value = attributes[key];
        if (![self addExtendedAttributeWithPath:path key:key value:value]) {
            result = NO;//有一个失败，则为NO
        }
    }
    
    return result;
}

//读取文件扩展属性
+ (NSString *)readExtendedAttributeWithPath:(NSString *)path key:(NSString *)key
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:nil];
        NSDictionary *fileExtendedAttributes = fileAttributes[@"NSFileExtendedAttributes"];
        NSData *data = [fileExtendedAttributes objectForKey:key];
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return result;
    }
    
    return nil;
}
@end