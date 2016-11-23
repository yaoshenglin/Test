//
//  Request.m
//  test
//
//  Created by xy on 2016/11/9.
//  Copyright © 2016年 Yinhaibo. All rights reserved.
//

#import "Request.h"
#import "Tools.h"

@implementation Request

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (id)initWithUrl:(NSURL *)url
{
    _urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    _urlRequest.HTTPMethod = @"POST";
    
    return self;
}

- (void)setHTTPBody:(NSData *)HTTPBody
{
    _HTTPBody = HTTPBody;
    _urlRequest.HTTPBody = HTTPBody;
}

- (void)setValue:(nullable NSString *)value forHTTPHeaderField:(NSString *)field
{
    [_urlRequest setValue:value forHTTPHeaderField:field];
}

- (NSData *)startRequest
{
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:_urlRequest returningResponse:&response error:&error];
    
    _error = error;
    _response = response;
    _data = data;
    
    return data;
}

//- (NSURLRequest *)requestWithUrl:(NSURL *)url
//{
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
//    request.HTTPMethod = @"POST";
//    
//    return request;
//}

+ (NSString *)translateContent:(NSString *)content
{
    NSString *urlString = @"http://fanyi.baidu.com/v2transapi";
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSData *httpBody = [Request queryContent:content];
    Request *request = [[Request alloc] initWithUrl:url];
    request.HTTPBody = httpBody;
    [request startRequest];
    
    NSString *value = nil;
    NSError *error = request.error;
    if (!error) {
        NSData *data = request.data;
        NSDictionary *dicData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSDictionary *result = [[dicData valueForKeyPath:@"trans_result.data"] firstObject];
        value = [result valueForKey:@"dst"];
        //NSLog(@"%@",[result valueForKey:@"src"]);
        //NSLog(@"%@",value);
        if (value.length <= 0) {
            NSLog(@"%@, %@",content,result);
        }
        
        if (![value isKindOfClass:[NSString class]]) {
            value = nil;
        }
    }else{
        NSLog(@"%@",error.localizedDescription);
    }
    
    return value;
}

+ (NSDictionary *)requestWithUrl:(NSURL *)url
{
    //boundary
    NSString *theBoundary = @"from=zh&to=en&query=搞笑的手机号码&transtype=translang&simple_means_flag=3";
//    theBoundary = [theBoundary stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //访问请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    //用来拼接参数
    NSMutableData *data = [NSMutableData data];
    //拼接第一个参数
    [data appendData:[theBoundary dataUsingEncoding:NSUTF8StringEncoding]];
//    //拼接参数名
//    [data appendData:[@"Content-Disposition:form-data;name=\\\"uid\\\"\\r\\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    [data appendData:[@"\\r\\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    //拼接参数值
//    [data appendData:[@"11230953" dataUsingEncoding:NSUTF8StringEncoding]];
//    [data appendData:[@"\\r\\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    //拼接第二个参数
//    [data appendData:[[NSString stringWithFormat:@"--%@\\r\\n", theBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    //拼接参数名
//    [data appendData:[@"Content-Disposition:form-data;name=\\\"file\\\";filename=\\\"myText.txt\\\"\\r\\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    //拼接文件类型
//    [data appendData:[@"Content-Type:text/plain" dataUsingEncoding:NSUTF8StringEncoding]];
//    [data appendData:[@"\\r\\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    //拼接参数值
//    [data appendData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"myText" ofType:@"txt"]]];
//    [data appendData:[@"\\r\\n" dataUsingEncoding:NSUTF8StringEncoding]];
    //拼接结束标志
    
    //[request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    //[request setValue:@"http://fanyi.baidu.com" forHTTPHeaderField:@"Origin"];
    //[request setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    //[request setValue:@"http://fanyi.baidu.com/?aldtype=16047" forHTTPHeaderField:@"Referer"];
    //[request setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    //[request setValue:@"zh-CN,zh;q=0.8" forHTTPHeaderField:@"Accept-Language"];
    //[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    request.HTTPBody = data;
    [request setValue:[NSString stringWithFormat:@"%ld", data.length] forHTTPHeaderField:@"Content-Length"];
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    data.data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    //NSURLSession *session = [NSURLSession sharedSession];
    //NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    //    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    //    NSLog(@"%@", dic);
    //}];
    //[dataTask resume];
    NSMutableDictionary *dicValue = [NSMutableDictionary dictionary];
    if (data) {
        [dicValue setObject:data forKey:@"data"];
    }
    
    if (response) {
        [dicValue setObject:response forKey:@"response"];
    }
    
    if (error) {
        [dicValue setObject:error forKey:@"error"];
    }
    
    return dicValue;
}

+ (NSData *)queryContent:(NSString *)content
{
    NSString *theBoundary = [NSString stringWithFormat:@"from=zh&to=en&query=%@&transtype=translang&simple_means_flag=3",content];
    
    NSData *data = [theBoundary dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

+ (NSString *)content
{
    NSString *path = @"/Users/xy/Documents/CrashInfo/中文翻译1.TXT";
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *listWords = [content componentsSeparatedByString:@";"];
    NSMutableArray *list = [NSMutableArray array];
    for (NSString *words in listWords) {
        NSString *value = [Request translateContent:words];
        if (value.length <= 0) {
            value = @"NULL";
        }
        
        NSString *word = [words replaceString:@"\n" withString:@""];
        NSString *result = [NSString stringWithFormat:@"%@ = %@",value,word];
        [list addObject:result];
    }
    
    content = [list componentsJoinedByString:@";\n"];
    path = @"/Users/xy/Documents/CrashInfo/中文翻译2.TXT";
    [content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSLog(@"%@",content);
    
    return content;
}

+ (NSData *)requestWithUrl:(NSURL *)url httpBody:(NSData *)httpBody
{
    __block NSError *_error = nil;
    __block NSURLResponse *_response = nil;
    __block NSData *_data = nil;
    NSMutableURLRequest *_urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    _urlRequest.HTTPBody = httpBody;
    _urlRequest.HTTPMethod = @"GET";
    
    dispatch_semaphore_t disp = dispatch_semaphore_create(0);
    
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:_urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        _error = error;
        _response = response;
        _data = data;
        dispatch_semaphore_signal(disp);
    }];
    [dataTask resume];
    
    dispatch_semaphore_wait(disp, DISPATCH_TIME_FOREVER);
    
    if (_error) {
        NSLog(@"%ld, %@",(long)_error.code,_error.localizedDescription);
    }
    
    return _data;
}

+ (NSString *)queryIPAdress:(NSString *)adress
{
    adress = adress ?: @"120.197.55.147";
    NSString *urlString = [NSString stringWithFormat:@"https://sp0.baidu.com/8aQDcjqpAAV3otqbppnN2DJv/api.php?query=%@&co=&resource_id=6006&t=1478844763925&ie=utf8&oe=gbk&cb=op_aladdin_callback&format=json&tn=baidu&cb=jQuery1102046848492178260515_1478844287070&_=1478844287074",adress];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [self.class requestWithUrl:url httpBody:nil];
    
    NSString *path = @"/Users/xy/Documents/CrashInfo/iP地址.txt";
    [data writeToFile:path atomically:YES];
    
    NSString *content = [data stringUsingEncode:GBEncoding];
    if (!content) {
        content = [data stringUsingEncode:NSUTF8StringEncoding];
    }
    return content;
}

@end
