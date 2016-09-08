//
//  ExpendFileAttributes.h
//  test
//
//  Created by xy on 16/9/6.
//  Copyright © 2016年 Yinhaibo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExpendFileAttributes : NSObject

/** 为文件增加一个扩展属性，值是字符串 */
+ (BOOL)addExtendedAttributeWithPath:(NSString *)path key:(NSString *)key value:(NSString *)value;
+ (BOOL)addExtendedAttributeWithPath:(NSString *)path attributes:(NSDictionary *)attributes;

/** 读取文件扩展属性，值是字符串 */
+ (NSString *)readExtendedAttributeWithPath:(NSString *)path key:(NSString *)key;

@end
