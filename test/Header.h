//
//  Header.h
//  test
//
//  Created by xy on 16/4/23.
//  Copyright © 2016年 Yinhaibo. All rights reserved.
//

#ifndef Header_h
#define Header_h


#endif /* Header_h */

#include <arpa/inet.h>
#include <netdb.h>
#include <math.h>
#include <string.h>
#include <netinet/in.h>
#include <sys/sysctl.h>
#include <mach-o/dyld.h>
#include <pthread.h>

//#import "GDataXMLNode.h"
#import "DeviceModel.h"
#import "Tools.h"
//#import "Rooms.h"
#import "Encoder.h"
#import "PrintObject.h"
#import "DeleteFile.h"
#import "EnumType.h"
#import "DB.h"
//#import "HTTPRequest.h"
#import "Ping.h"
#import "Brands.h"
#import "UrlInfo.h"
#import "Request.h"

//获取一段时间间隔
#define kStartTime CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
#define kEndTime   NSLog(@"Time: %f", CFAbsoluteTimeGetCurrent() - start)
