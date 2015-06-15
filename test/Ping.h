//
//  Ping.h
//  test
//
//  Created by Yin on 15-5-25.
//  Copyright (c) 2015年 Yinhaibo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Ping : NSObject

@property (retain, nonatomic) id delegate;

+ (Ping *)getInstance;
+ (void)PingDomain:(NSString *)domain;
- (void)PingDomain:(NSString *)domain;
+ (void)PingDomain:(NSString *)domain count:(int)count;
- (void)PingDomain:(NSString *)domain completion:(void (^)(NSData *data))handler;
- (void)close;
//void ping(char *address);

@end

@interface NSObject (PingDelegate)

- (void)receiveData:(NSData *)data;

@end
