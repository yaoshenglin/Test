//
//  Request.h
//  test
//
//  Created by xy on 2016/11/9.
//  Copyright © 2016年 Yinhaibo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Request : NSObject

@property (nonatomic, retain) NSMutableURLRequest *urlRequest;
@property (nonatomic, retain) NSData *HTTPBody;

@property (nonatomic, retain, readonly) NSError *error;
@property (nonatomic, retain, readonly) NSURLResponse *response;
@property (nonatomic, retain, readonly) NSData *data;

- (id)initWithUrl:(NSURL *)url;
- (NSData *)startRequest;

+ (NSString *)translateContent:(NSString *)content;

+ (NSDictionary *)requestWithUrl:(NSURL *)url;
+ (NSData *)requestWithUrl:(NSURL *)url httpBody:(NSData *)httpBody;
+ (NSData *)queryContent:(NSString *)content;

+ (NSString *)queryIPAdress:(NSString *)adress;

@end
