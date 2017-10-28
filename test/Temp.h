//
//  Temp.h
//  test
//
//  Created by xy on 2016/11/3.
//  Copyright © 2016年 Yinhaibo. All rights reserved.
//

#define ORTP_INLINE            inline
#ifdef __GNUC__
#define CHECK_FORMAT_ARGS(m,n) __attribute__((format(printf,m,n)))
#else
#define CHECK_FORMAT_ARGS(m,n)
#endif

#import <Foundation/Foundation.h>
#include <asl.h>
#import <os/log.h>


@interface IRCodes : NSObject

@property (nonatomic, retain) NSString *DbUrl;
@property (nonatomic, retain) NSString *DbVerCode;
@property (nonatomic, retain) NSString *Info;
@property (nonatomic, retain) NSString *UpFileCodeList;
@property (nonatomic, retain) NSString *UpFileDateList;

@end

@interface Temp : NSObject

@property (nonatomic, assign) CGFloat day;
@property (nonatomic, retain) NSNumber *eve;
@property (nonatomic, retain) NSNumber *max;
@property (nonatomic, retain) NSNumber *min;
@property (nonatomic, retain) NSNumber *morn;
@property (nonatomic, retain) IRCodes *iRCodes;
@property (nonatomic, retain) NSDictionary *Hardware;

void ortp_message(int lev, const char *fmt,...);

@end
