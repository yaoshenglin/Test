//
//  Polymorphism.m
//  test
//
//  Created by Yin on 14-3-25.
//  Copyright (c) 2014年 Yinhaibo. All rights reserved.
//

#import "Polymorphism.h"

@implementation Polymorphism

-(id)init
{
    self = [super init];
    if (self) {
        //test
        NSString *str = [self addMoreArguments:@"hello",@"world",@"this",@"is",@"a",@"test", nil];
        NSLog(@"str = %@",str);
        //output: str = * hello * world * this * is * a * test
    }
    return self;
}

//.m
- (NSString *)addMoreArguments:(NSString *)firstStr,...
{
    va_list args;
    va_start(args, firstStr); // scan for arguments after firstObject.
    
    // get rest of the objects until nil is found
    NSMutableString *allStr = [[NSMutableString alloc] initWithCapacity:16];
    for (NSString *str = firstStr; str != nil; str = va_arg(args,NSString*)) {
        [allStr appendFormat:@"* %@ ",str];
    }
    
    va_end(args);
    return allStr;
}

@end
