//
//  Temp.m
//  test
//
//  Created by xy on 2016/11/3.
//  Copyright © 2016年 Yinhaibo. All rights reserved.
//

#import "Temp.h"
#include <objc/runtime.h>

@implementation IRCodes

- (instancetype)init
{
    self = [super init];
    if (self) {
//        [self addObserver:self forKeyPath:@"Info" options:0 context:NULL];
    }
    
    return self;
}

- (void)willChangeValueForKey:(NSString *)key
{
    if ([key isEqualToString:@"Info"]) {
        NSLog(@"OK");
    }
}

//属性发生改变时
- (void)insertEarthquakes:(NSArray *)earthquakes
{
    // this will allow us as an observer to notified
    NSLog(@"insertEarthquakes");
}
//当属性的值发生变化时，自动调用此方法
/* listen for changes to the earthquake list coming from our app delegate. */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{    
    NSLog(@"observeValueForKeyPath");
}

@end

@implementation Temp

- (instancetype)init
{
    self = [super init];
    if (self) {
//        [self addObserver:self forKeyPath:@"iRCodes" options:0 context:NULL];
    }
    
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([value isKindOfClass:[NSNull class]]) {
        
        return;
    }
    
    if ([key isEqualToString:@"IRCodes"]) {
        
        IRCodes *irCodes = [[IRCodes alloc] init];
        [irCodes setValuesForKeysWithDictionary:value];
        _iRCodes = irCodes;
        [super setValue:irCodes forKey:@"iRCodes"];
        return;
    }
    
    NSArray *listkey = [self getObjectPropertyList];
    if (![listkey containsObject:key]) {
        return;
    }
    
    [super setValue:value forKey:key];
}

- (void)willChangeValueForKey:(NSString *)key
{
    if ([key isEqualToString:@"Info"]) {
        NSLog(@"OK");
    }
}

//属性发生改变时
- (void)insertEarthquakes:(NSArray *)earthquakes
{
    // this will allow us as an observer to notified
    NSLog(@"insertEarthquakes");
}
//当属性的值发生变化时，自动调用此方法
/* listen for changes to the earthquake list coming from our app delegate. */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSLog(@"observeValueForKeyPath");
}


#pragma mark - 通过对象获取全部属性
- (NSArray *)getObjectPropertyList
{
    NSArray *list = nil;
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([self class], &propsCount);
    list = propsCount>0 ? @[] : nil;
    for(int i = 0;i < propsCount; i++)
    {
        objc_property_t prop = props[i];
        
        const char *name = property_getName(prop);
        NSString *propName = [NSString stringWithUTF8String:name];
        list = [list arrayByAddingObject:propName];
    }
    
    return list;
}

@end
