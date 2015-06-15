//
//  HTTPRequest.h
//  iFace
//
//  Created by Yin on 15-3-24.
//  Copyright (c) 2015年 caidan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTTPRequest;
@protocol RequestDelegate
@optional

- (void)wsOK:(HTTPRequest *)iWS;
- (void)wsFailed:(HTTPRequest *)iWS;

@end

@interface HTTPRequest : NSObject

@property (nonatomic) NSTimeInterval timeOut;
@property (retain, nonatomic) NSString *host;//主服务器域名
@property (retain, nonatomic) NSString *hostPort;//端口
@property (retain, nonatomic) NSString *action;//根路径
@property (retain, nonatomic) NSString *urlString;
@property (retain, nonatomic) NSString *tag;
@property (retain, nonatomic) NSString *tagString;

@property (retain, nonatomic) NSDictionary *dicTag;//标签
@property (retain, nonatomic,readonly) NSString *method;//接口名
@property (retain, nonatomic,readonly) NSString *responseString;
@property (retain, nonatomic,readonly) NSDictionary *jsonDic;
@property (retain, nonatomic,readonly) NSString *errMsg;

@property (assign, nonatomic,readonly) int responseStatusCode;//请求响应码
@property (retain, nonatomic,readonly) NSString *responseStatusMessage;//请求响应信息

+ (HTTPRequest *)run:(NSString *)method body:(NSDictionary *)body delegate:(id)thedelegate;
+ (void)run:(NSString *)method body:(NSDictionary *)body completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* error)) handler NS_AVAILABLE(10_7, 5_0);
- (void)run:(NSString *)method body:(NSDictionary *)body delegate:(id)thedelegate;
- (void)run:(NSString *)method body:(NSDictionary *)body completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* error)) handler NS_AVAILABLE(10_7, 5_0);

@end
