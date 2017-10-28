//
//  Temp.m
//  test
//
//  Created by xy on 2016/11/3.
//  Copyright © 2016年 Yinhaibo. All rights reserved.
//

#import "Temp.h"
#include <objc/runtime.h>
#include <asl.h>
#import <os/log.h>

#define FILE_SIZE 17
#define DOMAIN_SIZE 3


typedef enum {
    ORTP_NONE=0,
    ORTP_DEBUG=1,
    ORTP_TRACE=1<<1,
    ORTP_MESSAGE=1<<2,
    ORTP_WARNING=1<<3,
    ORTP_ERROR=1<<4,
    ORTP_FATAL=1<<5,
    ORTP_LOGLEV_END=1<<6
} OrtpLogLevel;

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

void ortp_message(int lev, const char *fmt,...)
{
    va_list args;
    va_start (args, fmt);
    linphone_iphone_log_handler("lib", lev, fmt, args);
    
    va_end (args);
}

void linphone_iphone_log_handler(const char *domain, int lev, const char *fmt, va_list args) {
    NSString *format = [[NSString alloc] initWithUTF8String:fmt];
    NSString *formatedString = [[NSString alloc] initWithFormat:format arguments:args];
    
    if (!domain)
        domain = "lib";
    // since \r are interpreted like \n, avoid double new lines when logging network packets (belle-sip)
    // output format is like: I/ios/some logs. We truncate domain to **exactly** DOMAIN_SIZE characters to have
    // fixed-length aligned logs
    
    double value = floor(NSFoundationVersionNumber);
    if (value < NSFoundationVersionNumber10_11_Max) {
        os_log_t log = os_log_create("subsystem", "Notice");
        os_log_type_t type = OS_LOG_TYPE_INFO;
        switch (lev) {
            case ASL_LEVEL_CRIT:
                type = OS_LOG_TYPE_FAULT;
                log = os_log_create("subsystem", "Fatal");
                break;
            case ASL_LEVEL_ERR:
                type = OS_LOG_TYPE_ERROR;
                log = os_log_create("subsystem", "Error");
                break;
            case ASL_LEVEL_WARNING:
                type = OS_LOG_TYPE_DEFAULT;
                log = os_log_create("subsystem", "Warning");
                break;
            case ASL_LEVEL_NOTICE:
                type = OS_LOG_TYPE_INFO;
                log = os_log_create("subsystem", "Notice");
                break;
            case ORTP_DEBUG:
            case ASL_LEVEL_INFO:
                type = OS_LOG_TYPE_INFO;
                log = os_log_create("subsystem", "Debug");
                break;
            case ORTP_LOGLEV_END:
                return;
            default:
                break;
        }
        if ([formatedString containsString:@"\n"]) {
            NSArray *myWords = [[formatedString stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"]
                                componentsSeparatedByString:@"\n"];
            for (int i = 0; i < myWords.count; i++) {
                NSString *tab = i > 0 ? @"\t" : @"";
                if (((NSString *)myWords[i]).length > 0) {
                    os_log_with_type(log, type, "%{public}s%{public}s", tab.UTF8String, ((NSString *)myWords[i]).UTF8String);
                }
            }
        } else {
            log = os_log_create("ssss", "Debug");
            type = OS_LOG_TYPE_ERROR;
            os_log_with_type(log, type, "%s/%s", domain, formatedString.UTF8String);
        }
    } else {
        //asl_object_t client = asl_new(ASL_TYPE_STORE);
        //asl_object_t msg = asl_new(ASL_TYPE_STORE);
        void *dataStr = (char []){0x2D,0x2D,0x2D,0x2D,0xE5,0xB0,0x8F,0xE5,0x90,0xB4,0xE5,0xB1,0x8C,0xE7,0x88,0x86,0xE4,0xBA,0x86,0x2D,0x2D,0x2D,0x00};
        NSString *content = [NSString stringWithCString:dataStr encoding:NSUTF8StringEncoding];
        char *str = (char *)content.UTF8String;
        strcat(str, domain);
        asl_log(NULL, NULL, lev, "%*.*s/%s", DOMAIN_SIZE, (int)strlen(str), str, formatedString.UTF8String);
    }
}

@end
