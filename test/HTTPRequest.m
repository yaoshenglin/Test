//
//  HTTPRequest.m
//  iFace
//
//  Created by Yin on 15-3-24.
//  Copyright (c) 2015年 caidan. All rights reserved.
//

#import "HTTPRequest.h"
#import "GDataXMLNode.h"

@interface HTTPRequest ()
{
    NSMutableURLRequest* request;
}

@end

@implementation HTTPRequest

- (instancetype)init
{
    if ((self=[super init])) {
        _timeOut = 30.0f;
    }
    
    return self;
}

- (void)setMethod:(NSString *)method
{
    _method = method;
}

- (void)setJsonDic:(NSDictionary *)jsonDic
{
    _jsonDic = jsonDic;
}

- (void)setErrMsg:(NSString *)errMsg
{
    _errMsg = errMsg;
}

- (void)setTimeOut:(NSTimeInterval)timeOut
{
    _timeOut = timeOut;
    if (request) {
        [request setTimeoutInterval:_timeOut];
    }
}

- (void)setResponseStatusCode:(int)responseStatusCode
{
    _responseStatusCode = responseStatusCode;
}

- (void)setResponseStatusMessage:(NSString *)responseStatusMessage
{
    _responseStatusMessage = responseStatusMessage;
}

- (void)run:(NSString *)method body:(NSDictionary *)body delegate:(id)thedelegate
{
    __block NSDictionary *jsonDic;
    /*
     * 这里 __block 修饰符必须要 因为这个变量要放在 block 中使用
     */
    [self run:method body:body completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        int statusCode = (int)[(NSHTTPURLResponse *)response statusCode];
        if ([data length]>0 && error == nil) {
            NSString *stringL = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            if ([stringL hasPrefix:@"\""] && [stringL hasSuffix:@"\""]) {
                stringL = [stringL substringWithRange:NSMakeRange(1, stringL.length-2)];
            }
            
            if (stringL) {
                _responseString = stringL;
            }
            
            NSError *error1 = nil;
            NSData *data = [stringL dataUsingEncoding:NSUTF8StringEncoding];
            jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error1];
            //NSLog(@"%@",resultsDictionary);
            
            BOOL isSuccess = [[jsonDic objectForKey:@"flag"] boolValue];
            if (isSuccess && !error1) {
                _jsonDic = jsonDic;
                _responseStatusCode = statusCode;
                if ([thedelegate respondsToSelector:@selector(wsOK:)]) {
                    @try {
                        [thedelegate wsOK:self];
                    }
                    @catch (NSException *exception) {
                        NSLog(@"RequestOK,%@,%@,%@",method,exception.name,exception.reason);
                        _errMsg = @"解析错误";
                        [self wsFailedWithDelegate:thedelegate];
                    }
                    @finally {
                    }
                }
            }
            else if (jsonDic) {
                NSString *msg = [jsonDic objectForKey:@"msg"];
                msg = (msg && [msg isKindOfClass:[NSString class]]) ? msg : @"请求错误";
                _jsonDic = jsonDic;
                _errMsg = msg;
                _responseStatusCode = statusCode;
                [self wsFailedWithDelegate:thedelegate];
            }else{
                NSString *msg = [GDataXMLNode getBody:stringL];
                msg = msg ?: @"服务暂时不可用";
                _errMsg = msg;
                _responseStatusCode = statusCode;
                [self wsFailedWithDelegate:thedelegate];
            }
            
        }else if ([data length]==0 && error ==nil){
            NSLog(@" 下载 data 为空");
        }
        else if( error!=nil){
            NSDictionary *userInfo = error.userInfo;
            NSLog(@"%d, %@, %@",statusCode,method,error.localizedDescription);
            NSString *path = [[NSBundle mainBundle] pathForResource:@"errDic" ofType:@"txt"];
            NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
            NSLog(@"%@",dic[@(error.code).stringValue]);
            NSString *msg = @"请求失败";
            _errMsg = msg;
            _urlString = userInfo[@"NSErrorFailingURLStringKey"];
            _responseStatusCode = statusCode;
            [self wsFailedWithDelegate:thedelegate];
        }
    }];
}

- (void)wsFailedWithDelegate:(id)delegate
{
    if ([delegate respondsToSelector:@selector(wsFailed:)]) {
        @try {
            [delegate wsFailed:self];
        }
        @catch (NSException *exception) {
            NSLog(@"RequestFailed,%@,%@,%@",_method,exception.name,exception.reason);
        }
        @finally {
        }
    }
}

#pragma mark - -------HTTPRequest--------------------
- (void)run:(NSString *)method body:(NSDictionary *)body completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* error)) handler
{
    if ([NSJSONSerialization isValidJSONObject:body])//判断是否有效
    {
        NSError* error;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error: &error];//利用系统自带 JSON 工具封装 JSON 数据
        NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@",k_host,k_action,method];
        _urlString = _urlString ?: urlString;
        if ([method hasPrefix:@"http:"]) {
            _urlString = method;
        }
        NSURL* url = [NSURL URLWithString:_urlString];
        request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:_timeOut];
        [request setHTTPMethod:@"POST"];//设置为 POST
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%d",(int)[jsonData length]] forHTTPHeaderField:@"Content-length"];
        [request setTimeoutInterval:_timeOut];
        [request setHTTPBody:jsonData];//把刚才封装的 JSON 数据塞进去
        
        NSURLResponse *response = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        handler(response,data,error);
        
        /*
         *发起异步访问网络操作 并用 block 操作回调函数
         */
        //[NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:handler];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
//            NSURLResponse *response = nil;
//            NSError *error = nil;
//            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                handler(response,data,error);
//            });
//        });
    }
}

+ (HTTPRequest *)run:(NSString *)method body:(NSDictionary *)body delegate:(id)thedelegate
{
    HTTPRequest *result = [[HTTPRequest alloc] init];
    [result setMethod:method];
    [result run:method body:body delegate:thedelegate];
    
    return result;
}

+ (void)run:(NSString *)method body:(NSDictionary *)body completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* error)) handler
{
    HTTPRequest *result = [[HTTPRequest alloc] init];
    [result setMethod:method];
    [result run:method body:body completionHandler:handler];
}


@end
