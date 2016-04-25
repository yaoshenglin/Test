//
//  UrlInfo.h
//  test
//
//  Created by xy on 16/4/23.
//  Copyright © 2016年 Yinhaibo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UrlInfo : NSObject

@property (retain, nonatomic) NSString *absoluteString;
@property (retain, nonatomic) NSString *relativeString; // The relative portion of a URL.  If baseURL is nil, or if the receiver is itself absolute, this is the same as absoluteString
@property (retain, nonatomic) NSURL *baseURL; // may be nil.
@property (retain, nonatomic) NSURL *absoluteURL; // if the receiver is itself absolute, this will return self.

/* Any URL is composed of these two basic pieces.  The full URL would be the concatenation of [myURL scheme], ':', [myURL resourceSpecifier]
 */
@property (retain, nonatomic) NSString *scheme;
@property (retain, nonatomic) NSString *resourceSpecifier;

/* If the URL conforms to rfc 1808 (the most common form of URL), the following accessors will return the various components; otherwise they return nil.  The litmus test for conformance is as recommended in RFC 1808 - whether the first two characters of resourceSpecifier is @"//".  In all cases, they return the component's value after resolving the receiver against its base URL.
 */
@property (retain, nonatomic) NSString *host;
@property (retain, nonatomic) NSNumber *port;
@property (retain, nonatomic) NSString *user;
@property (retain, nonatomic) NSString *password;
@property (retain, nonatomic) NSString *path;
@property (retain, nonatomic) NSString *fragment;
@property (retain, nonatomic) NSString *parameterString;
@property (retain, nonatomic) NSString *query;
@property (retain, nonatomic) NSString *relativePath; // The same as path if baseURL is nil

/* Determines if a given URL string's path represents a directory (i.e. the path component in the URL string ends with a '/' character). This does not check the resource the URL refers to.
 */
@property (readonly) BOOL hasDirectoryPath NS_AVAILABLE(10_11, 9_0);

- (instancetype)initWithUrl:(NSURL *)url;
- (instancetype)initWithUrlString:(NSString *)urlString;

- (NSArray *)arrayWithQuery;
- (NSDictionary *)parseQuery;

@end
