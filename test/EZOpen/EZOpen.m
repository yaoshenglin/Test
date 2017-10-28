//
//  EZOpen.m
//  test
//
//  Created by xy on 2017/10/25.
//  Copyright © 2017年 Yinhaibo. All rights reserved.
//

#import "EZOpen.h"

@implementation EZOpen

+ (void)operationErrorCode
{
    NSError *error = nil;
    NSString *path = @"/Users/xy/Documents/萤石云开放平台ErrorCode.txt";
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"error, %@",error.localizedDescription);
    }
    
    NSArray *list = [content componentsSeparatedByString:@"public class ErrorCode {"];
    content = list.lastObject;
    list = [content componentsSeparatedByString:@"/**\n     *"];
    list = [list subarrayWithRange:NSMakeRange(1, list.count-1)];
    NSMutableArray *listData = [NSMutableArray array];
    for (NSString *dataStr in list) {
        NSArray *list = [dataStr componentsSeparatedByString:@"\n     */\n    public static final int "];
        
        if (list.count != 2) {
            list = [dataStr componentsSeparatedByString:@"\n     */\n    public final static int"];
        }
        
        if (list.count != 2) {
            NSLog(@"%@",list.firstObject);
            continue;
        }
        
        NSString *value = list.firstObject;
        NSString *key = list.lastObject;
        
        if ([value containsString:@"设备开启了隐私保护"]) {
            //NSLog(@"%@,%@",key,value);
        }
        
        while ([value hasPrefix:@" "]) {
            value = [value substringFromIndex:1];
        }
        
        list = [key componentsSeparatedByString:@" = "];
        key = list.firstObject;
        long num = [[[list.lastObject componentsSeparatedByString:@";"] firstObject] longLongValue];
        NSDictionary *dic = @{@"num":@(num),@"data":@{key:value}};
        [listData addObject:dic];
    }
    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"num" ascending:NO];
    [listData sortUsingDescriptors:@[sorter]];
    NSEnumerator *enumerator = [listData reverseObjectEnumerator];//逆向遍历
    listData.array = [enumerator allObjects];
    NSMutableString *string = [NSMutableString stringWithString:@""];
    for (NSDictionary *dic in listData) {
        NSDictionary *dicData = [dic objectForKey:@"data"];
        NSString *key = dicData.allKeys.firstObject;
        NSString *value = dicData.allValues.firstObject;
        [string appendFormat:@"@(%@):@\"%@\",\n",key,value];
    }
    
    NSLog(@"%@",string);
}

@end
