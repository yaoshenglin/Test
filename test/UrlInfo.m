//
//  UrlInfo.m
//  test
//
//  Created by xy on 16/4/23.
//  Copyright © 2016年 Yinhaibo. All rights reserved.
//

#import "UrlInfo.h"
#import "Tools.h"

@implementation UrlInfo

- (instancetype)initWithUrl:(NSURL *)url
{
    if ((self = [super init])) {
        _absoluteString = url.absoluteString;
        _relativeString = url.relativeString;
        _baseURL = url.baseURL;
        _absoluteURL = url.absoluteURL;
        _scheme = url.scheme;
        _resourceSpecifier = url.resourceSpecifier;
        
        _host = url.host;
        _port = url.port;
        _user = url.user;
        _password = url.password;
        _path = url.path;
        _fragment = url.fragment;
        _parameterString = url.parameterString;
        _query = url.query;
        _relativePath = url.relativePath;
        
        _pathComponents = url.pathComponents;
        _lastPathComponent = url.lastPathComponent;
        _pathExtension = url.pathExtension;
        
        _hasDirectoryPath = url.hasDirectoryPath;
    }
    
    return self;
}

- (instancetype)initWithUrlString:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    if ((self = [super init])) {
        _absoluteString = url.absoluteString;
        _relativeString = url.relativeString;
        _baseURL = url.baseURL;
        _absoluteURL = url.absoluteURL;
        _scheme = url.scheme;
        _resourceSpecifier = url.resourceSpecifier;
        
        _host = url.host;
        _port = url.port;
        _user = url.user;
        _password = url.password;
        _path = url.path;
        _fragment = url.fragment;
        _parameterString = url.parameterString;
        _query = url.query;
        _relativePath = url.relativePath;
    }
    
    return self;
}

- (NSArray *)arrayWithQuery
{
    NSString *urlString = _query;//host、path、query
    NSArray *list = [urlString componentSeparatedByString:@"&"];
    return list;
}

- (NSDictionary *)parseQuery
{
    NSArray *list = [self arrayWithQuery];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (NSString *str in list) {
        NSArray *array = [str componentSeparatedByString:@"="];
        [dic setObject:array.lastObject forKey:array.firstObject];
    }
    
    return dic;
}

@end
