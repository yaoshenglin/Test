//
//  Rooms.m
//  test
//
//  Created by Yin on 14-7-6.
//  Copyright (c) 2014年 Yinhaibo. All rights reserved.
//

#import "Rooms.h"
#import "GDataXMLNode.h"
#import "Tools.h"
#import <objc/runtime.h>
#import "Header.h"

@interface Rooms (ABC)
{
    
}

@end

@interface Rooms ()
{
    NSTimer *timer;
}

@end

@implementation Rooms

- (id)init
{
    self = [super init];
    if (self) {
        //self.ID = 23;
        self.name = @"B";
        self.ID = 3;
    }
    
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        //self.ID = 23;
        self.ID = [[aDecoder decodeObjectForKey:@"ID"] intValue];
        self.age = [[aDecoder decodeObjectForKey:@"age"] intValue];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.date = [aDecoder decodeObjectForKey:@"date"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:@(_ID) forKey:@"ID"];
    [aCoder encodeObject:@(_age) forKey:@"age"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_date forKey:@"date"];
}

- (NSString *)description
{
    [super description];
    NSString *format = [NSString stringWithFormat:@"ID = %d, age = %d, name = %@, date = %@",_ID,_age,_name,_date];
    return format;
}

- (id)initWithID:(int)theID name:(NSString *)theName
{
    self = [super init];
    if (self) {
        self.ID = theID;
        self.name = theName;
    }
    
    return self;
}

- (int)ID
{
    return _ID;
}

- (void)StartRun
{
    [self performSelector:@selector(b) withObject:nil afterDelay:5];
    timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(a:) userInfo:@"A" repeats:NO];
}

- (void)a:(NSTimer *)theTimer
{
    NSLog(@"OK");
}

- (void)b
{
    if ([timer isValid]) {
        [timer invalidate];
    }
}

- (void)setNumber:(CGFloat)value
{
    if (value > 10) {
        NSException *e = [NSException
                          exceptionWithName: @"BoxOverflowException"
                          reason: @"The value is above 10"
                          userInfo: @{@"2":@"B"}];
        @throw e;
    }
    else if (value < 0) {
        NSException *e = [NSException
                          exceptionWithName: @"BoxOverflowException"
                          reason: @"The value is below 0"
                          userInfo: @{@"2":@"B"}];
        @throw e;
    }else{
        NSLog(@"当前值: %.2f",value);
    }
}

- (void)printValue:(CGFloat)value
{
    NSLog(@"结果为: %.2f",value);
}

- (NSDate *)dateFromString:(NSString *)str withDateFormater:(NSString *)formater
{
	NSString *strDate = [str stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:(formater ? formater : @"yyyy-MM-dd HH:mm:ss")];
    return [dateFormatter dateFromString:strDate];
}

- (NSString *)getDeviceVersionInfo
{
    size_t size;
    // get the length of machine name
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    // get machine name
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithFormat:@"%s", machine];
    free(machine);
    
    return platform;
}

- (NSString *)correspondVersion
{
    NSString *correspondVersion = [self getDeviceVersionInfo];
    
    if ([correspondVersion isEqualToString:@"i386"])        return@"Simulator";
    if ([correspondVersion isEqualToString:@"x86_64"])       return @"Simulator";
    
    if ([correspondVersion isEqualToString:@"iPhone1,1"])   return@"iPhone 1";
    if ([correspondVersion isEqualToString:@"iPhone1,2"])   return@"iPhone 3";
    if ([correspondVersion isEqualToString:@"iPhone2,1"])   return@"iPhone 3S";
    if ([correspondVersion isEqualToString:@"iPhone3,1"] || [correspondVersion isEqualToString:@"iPhone3,2"])   return@"iPhone 4";
    if ([correspondVersion isEqualToString:@"iPhone4,1"])   return@"iPhone 4S";
    if ([correspondVersion isEqualToString:@"iPhone5,1"] || [correspondVersion isEqualToString:@"iPhone5,2"])   return @"iPhone 5";
    if ([correspondVersion isEqualToString:@"iPhone5,3"] || [correspondVersion isEqualToString:@"iPhone5,4"])   return @"iPhone 5C";
    if ([correspondVersion isEqualToString:@"iPhone6,1"] || [correspondVersion isEqualToString:@"iPhone6,2"])   return @"iPhone 5S";
    
    if ([correspondVersion isEqualToString:@"iPod1,1"])     return@"iPod Touch 1";
    if ([correspondVersion isEqualToString:@"iPod2,1"])     return@"iPod Touch 2";
    if ([correspondVersion isEqualToString:@"iPod3,1"])     return@"iPod Touch 3";
    if ([correspondVersion isEqualToString:@"iPod4,1"])     return@"iPod Touch 4";
    if ([correspondVersion isEqualToString:@"iPod5,1"])     return@"iPod Touch 5";
    
    if ([correspondVersion isEqualToString:@"iPad1,1"])     return@"iPad 1";
    if ([correspondVersion isEqualToString:@"iPad2,1"] || [correspondVersion isEqualToString:@"iPad2,2"] || [correspondVersion isEqualToString:@"iPad2,3"] || [correspondVersion isEqualToString:@"iPad2,4"])     return@"iPad 2";
    if ([correspondVersion isEqualToString:@"iPad2,5"] || [correspondVersion isEqualToString:@"iPad2,6"] || [correspondVersion isEqualToString:@"iPad2,7"] )      return @"iPad Mini";
    if ([correspondVersion isEqualToString:@"iPad3,1"] || [correspondVersion isEqualToString:@"iPad3,2"] || [correspondVersion isEqualToString:@"iPad3,3"] || [correspondVersion isEqualToString:@"iPad3,4"] || [correspondVersion isEqualToString:@"iPad3,5"] || [correspondVersion isEqualToString:@"iPad3,6"])      return @"iPad 3";
    
    return correspondVersion;
}

#pragma mark 日期转字符
+ (NSString *)dateToString:(NSDate *)date withDateFormater:(NSString *)formater
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:(formater ? formater : @"yyyy-MM-dd HH:mm:ss")];
    return [dateFormatter stringFromDate:date];
}

+ (NSData *)ValidCRCWithHost:(NSData *)data
{
    /// <summary>
    /// 验证校验码是否正确
    /// </summary>
    /// <param name="data"></param>
    if (![data isKindOfClass:[NSData class]] || data.length < 10)
        return nil;
    
    
    NSInteger length = data.length;
    Byte *Buf = (Byte *)[data bytes];
    //固件升级包开头结尾标志(FEEF...FEEF)
    if (Buf[0] != 0xFE || Buf[1] != 0xEF || Buf[length-2] != 0xFE || Buf[length-1] != 0xEF) {
        //如果任何一个对应错误，则返回空
        return nil;
    }
    
    data = [data subdataWithRanges:NSMakeRange(2, length-4)];
    @try {
        NSData *infoArea = [data subdataWithRanges:NSMakeRange(0, 4)];
        long type = [[infoArea subdataWithRange:NSMakeRange(0, 1)] parseInt:16];
        long fileVer = [[infoArea subdataWithRanges:NSMakeRange(1, 1)] parseInt:16];
        float viewVer = [[infoArea subdataWithRanges:NSMakeRange(2, 2)] parseInt:16]/100.0f;
        NSLog(@"固件类型:%ld,固件型号:iFace SP[%ld],固件版本号:%.2f",type,fileVer,viewVer);
    }
    @catch (NSException *exception) {
        ;
    }
    
    BOOL result = [Tools ValidCRCWithHost:data];
    if (!result) {
        return nil;
    }
    data = [data subdataWithRanges:NSMakeRange(4, length-6)];
    return data;
}

NSStringEncoding getEncode()
{
    return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
}

+ (NSString *)queryWeather
{
    //NSString *urlString = @"http://www.zto.cn/GuestService/SiteQuery";
    NSString *stringCity = @"广州";
    NSString *urlString = [NSString stringWithFormat:@"http://webservice.webxml.com.cn/WebServices/WeatherWS.asmx/getWeather?theCityCode=%@&theUserID=",[stringCity substringToIndex:2]];
    //urlString = @"http://ww4.sinaimg.cn/mw690/878a8376jw1eeejk9k8oij20k00ictch.jpg";
    //urlString = @"http://sapi2.ldsg.lodogame.com:8088/webApi/login.do?token=3c40f410d6b993ba18d8a26569d71fcc&serverId=a9&timestamp=1427711471635&qn=0&sign=57fd0eb29ef6e51c2653d1eb962cb002&mac=02:00:00:00:00:00&idfa=4A869E4B-E592-4F54-B8B0-0156FAD916F8&partnerId=2002&fr=&version=3.1.4.4";
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return urlString;
}

+ (NSString *)queryExpress
{
    NSString *orderID = @"210752104040";
    NSString *urlString = @"http://wx.kuaidi100.com/queryDetail.php?com=huitongkuaidi&nu=";
    urlString = [urlString stringByAppendingString:orderID];
    
    return urlString;
}

+ (void)startRequest
{
    //@"http://www.bjtime.cn"
    //@"http://open.baidu.com/special/time/"
    //@"http://yrip.co"
    //@"http://ifconfig.me/ip"
    //@"https://cgi1.apnic.net/cgi-bin/my-ip.php"
    
    NSString *urlString = [self.class queryWeather];
    
    [self requestWithUrl:urlString];
}

+ (NSArray *)requestWithUrl:(NSString *)urlString
{
    NSDate *date = [NSDate date];
    NSError *error = nil;
    //建立请求对象
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
    //设置请求路径
    request.URL = [NSURL URLWithString:urlString];
    //请求方式
    //request.HTTPMethod = @"POST";
    NSURLResponse *respone = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&respone error:&error];
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
    
    if ([urlString hasSuffix:@".jpg"] || [urlString hasSuffix:@".png"]) {
        if (data) {
            NSString *last = [urlString lastPathComponent];
            NSString *path = @"/Users/xy/Desktop/Chaches";
            path = [path stringByAppendingPathComponent:last];
            [data writeToFile:path atomically:YES];
            NSLog(@"图片保存成功");
        }else{
            NSLog(@"图片下载失败");
        }
        return nil;
    }
    
    CFStringRef theString = (__bridge CFStringRef)respone.textEncodingName;
    CFStringEncoding enc = CFStringConvertIANACharSetNameToEncoding(theString);
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding (enc);
    NSString *result = [[NSString alloc] initWithData:data encoding: encoding];
    
    NSArray *list = [result componentsSeparatedByString:@"<code>"];
    if (list.count>1) {
        result = list[1];
        list = [result componentsSeparatedByString:@"</code>"];
        result = [list firstObject];
    }
    //NSLog(@"%@",result);
    if (result.length > 0) {
        NSString *path = @"~/Desktop";
        path = [path stringByExpandingTildeInPath];
        NSArray *listPath = [path componentsSeparatedByString:@"/Desktop"];
        if (listPath.count > 1) {
            path = listPath.firstObject;
            path = [path stringByAppendingPathComponent:@"Public/xml文件合集/"];
        }
        path = [path stringByAppendingPathComponent:[urlString lastPathComponent]];
        path = [path stringByAppendingString:@".xml"];
        [result writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSLog(@"write : %@",error.localizedDescription);
        }
    }
    
    
    NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:date];
    
    NSLog(@"time : %f s",time);
    
    NSArray *listValue = [Rooms ParseXmlWithString:result];
    return listValue;
}

+ (void)startRequest:(NSMutableURLRequest *)request method:(NSString *)methodName delegate:(id)delegate
{
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *respone,
                                                                                     NSData *data,
                                                                                     NSError *error)
     {
         [queue cancelAllOperations];
         NSString *resault = nil;
         if ([data length]>0 && error==nil) {
             
             CFStringRef theString = (__bridge CFStringRef)respone.textEncodingName;
             CFStringEncoding enc = CFStringConvertIANACharSetNameToEncoding(theString);
             NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding (enc);
             resault = [[NSString alloc] initWithData:data encoding: encoding];
             
             
             if ([resault hasPrefix:@"\""] && [resault hasSuffix:@"\""]) {
                 resault = [resault substringWithRange:NSMakeRange(1, resault.length-2)];
             }
             NSData *data = [resault dataUsingEncoding:NSUTF8StringEncoding];
             NSDictionary *josonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
             
             NSLog(@"%@",request);
             NSLog(@"%@",josonDic);
             
         }else if ([data length] == 0 && error == nil){
             
             resault = @"Nothing was downloaded.";
             
             //NSString *msg = @"图片上传失败";
             
         }
         
         else if (error != nil){
             
             resault = [NSString stringWithFormat:@"NSURLErrorDomain Code=%ld,reason = %@",error.code, error.localizedDescription];
             
             NSString *msg = nil;
             if ([error.localizedDescription isEqualToString:@"Could not connect to the server."]) {
                 msg = @"连接服务器失败,请检查网络";
             }
             else if ([error.localizedDescription hasPrefix:@"Request failed"]) {
                 msg = @"请求失败";
             }else if ([error.localizedDescription hasPrefix:@"The request timed out"]) {
                 msg = @"请求超时";
             }else if ([error.localizedDescription hasPrefix:@"A connection failure occurred"]) {
                 msg = @"网络连接失败";
             }
             else{
                 msg = error.localizedDescription;
             }
             
             if (msg.length<=0) {
                 msg = @"请求失败";
             }
             //NSLog(@\"Error happened = %@\", error);
             
         }
         
         //NSLog(@"%@",resault);
     }];
}

+ (NSArray *)ParseXmlWithString:(NSString *)stringL
{
    NSError *error=nil;
    GDataXMLDocument *pXMLdocument = [[GDataXMLDocument alloc] initWithHTMLString:stringL error:&error];
    if (error!=NULL) {
        NSLog(@"%@",error.localizedDescription);
    }
    
    NSMutableArray *listValue = [NSMutableArray array];
    
    if (stringL.length <= 0) {
        //msg = @"请求失败";
    }else{
        //定义一个保存查找结果的对象，从根元素开始保存
        GDataXMLElement *pRootElement = [pXMLdocument rootElement];
        NSArray *arrayStu = [pRootElement elementsForName:@"body"];//找出标签名字为'body'的所有元素，保存到数组中
        GDataXMLNode *node = [arrayStu firstObject];
        
        NSMutableArray *listResult = [NSMutableArray array];
        [[self class] ParseData:node list:listResult];
        
        for (NSString *str in listResult) {
            NSString *result = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            result = [result stringByReplacingOccurrencesOfString:@"  " withString:@""];
            
            if ([result hasPrefix:@"document.getElementById('ip').innerHTML"]) {
                NSArray *list = [result componentsSeparatedByString:@"<code>"];
                result = list.count > 0 ? [list lastObject] : @"";
                result = [result stringByReplacingOccurrencesOfString:@"'" withString:@""];
            }
            
            if (result.length > 0) {
                [listValue addObject:result];
            }
            //NSLog(@"%@",result);
        }
    }
    
    return [NSArray arrayWithArray:listValue];
}

+ (void)ParseData:(GDataXMLNode *)node list:(NSMutableArray *)list
{
    if (node.childCount>0) {
        //NSLog(@"localName=%@",node.localName);
        for (int i=0; i<node.childCount; i++) {
            GDataXMLNode *sub_node=[node childAtIndex:i];
            [self ParseData:sub_node list:list];
        }
    }
    else {
        if ([node isKindOfClass:[GDataXMLNode class]]) {
            //NSLog(@"localName=%@",node.superclass);
        }
        
        [list addObject:node.stringValue];
    }
}

+ (NSArray *)ParseDataFromIFace
{
    NSString *path = @"/Users/xy/Public/xml文件合集/help.xml";
    NSString *result = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *list = [Rooms ParseXmlWithString:result];
    NSMutableArray *listValue = [NSMutableArray array];
    for (NSString *str in list) {
        NSString *value = [str replaceString:@" 处的服务" withString:@""];
        value = [value replaceString:@" 处的操作" withString:@""];
        if ([value hasPrefix:@"http://192.168.11.9"]) {
            NSArray *listCom = [value componentSeparatedByString:@"/"];
            value = listCom.lastObject;
            if (![value isEqualToString:@"api_v2"]) {
                [listValue addObject:value];
                NSLog(@"%@",value);
            }
        }
    }
    
    list = [NSArray arrayWithArray:listValue];
    for (NSString *value in list) {
        NSInteger loc = [listValue indexOfObject:value];
        if (loc >= 0) {
            [listValue removeObjectAtIndex:loc];
        }
        
        if ([listValue containsObject:value]) {
            NSLog(@"存在相同的值,%@",value);
        }
    }
    
    return list;
}

+ (void)PostJson
{
    __block NSMutableDictionary *resultsDictionary;
    /*
     * 这里 __block 修饰符必须要 因为这个变量要放在 block 中使用
     */
    NSDictionary *body = @{@"deviceType":@(4)};//假设要上传的 JSON 数据结构为 {"title":"first title","blog_id":"1"}
    if ([NSJSONSerialization isValidJSONObject:body])//判断是否有效
    {
        NSError* error;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error: &error];//利用系统自带 JSON 工具封装 JSON 数据
        NSURL* url = [NSURL URLWithString:@"http://192.168.11.169:8088/api/GetLastVersion"];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
        [request setHTTPMethod:@"POST"];//设置为 POST
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-length"];
        [request setHTTPBody:jsonData];//把刚才封装的 JSON 数据塞进去
        __block NSError *error1 = [[NSError alloc] init];
        
        NSURLResponse* response;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        CFStringRef theString = (__bridge CFStringRef)response.textEncodingName;
        CFStringEncoding enc = CFStringConvertIANACharSetNameToEncoding(theString);
        NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding (enc);
        NSString *stringL = [[NSString alloc] initWithData:data encoding: encoding];
        
        if ([stringL hasPrefix:@"\""] && [stringL hasSuffix:@"\""]) {
            stringL = [stringL substringWithRange:NSMakeRange(1, stringL.length-2)];
        }
        
        data = [stringL dataUsingEncoding:NSUTF8StringEncoding];
        resultsDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error1];
        NSLog(@"%@",resultsDictionary);
        
        NSLog(@"-----------------------");
        NSLog(@"%@",response);
        NSLog(@"%ld",[(NSHTTPURLResponse *)response statusCode]);
        NSLog(@"%@",[(NSHTTPURLResponse *)response allHeaderFields]);
        
        /*
         *发起异步访问网络操作 并用 block 操作回调函数
         */
        [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse* response,NSData* data,NSError* error)
         {
             if ([data length]>0 && error == nil) {
                 CFStringRef theString = (__bridge CFStringRef)response.textEncodingName;
                 CFStringEncoding enc = CFStringConvertIANACharSetNameToEncoding(theString);
                 NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding (enc);
                 NSString *stringL = [[NSString alloc] initWithData:data encoding: encoding];
                 
                 if ([stringL hasPrefix:@"\""] && [stringL hasSuffix:@"\""]) {
                     stringL = [stringL substringWithRange:NSMakeRange(1, stringL.length-2)];
                 }
                 
                 NSData *data = [stringL dataUsingEncoding:NSUTF8StringEncoding];
                 resultsDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error1];
                 NSLog(@"%@",resultsDictionary);
                 
             }else if ([data length]==0 && error ==nil){
                 NSLog(@" 下载 data 为空");
             }
             else if( error!=nil){
                 NSLog(@" error is %@",error);
                 
             }
         }];
    }
}

+ (NSDate *)dateWith:(NSString *)hourStr week:(Week)weekDay
{
    NSArray *list = @[];
    for (int i=0; i<7; i++) {
        Week week = 1<<i;
        if (weekDay & week) {
            list = [list arrayByAddingObject:@(i+1)];
        }
    }
    NSTimeInterval space = NSTimeIntervalSince1970;
    NSDate *reuslt;
    for (NSString *value in list) {
        NSString *string = [[NSDate dateWithFormat:@"yyyy-MM "] AppendString:hourStr];
        string = [string AppendFormat:@" %@",value];
        NSDate *date = [string dateWithFormat:@"yyyy-MM HH:mm EE"];
        if ([value isKindOfClass:[NSNumber class]]) {
            date = [string dateWithFormat:@"yyyy-MM HH:mm c"];
        }
        for (int i=0; ; i++) {
            if ([date compare:[NSDate date]] < 0) {
                date = [date dateByAddingTimeInterval:3600*24*7];
            }else{
                break;
            }
        }
        
        NSTimeInterval current = [date timeIntervalSinceDate:[NSDate date]];
        if (current < space) {
            space = current;
            reuslt = date;
        }
    }
    
    return reuslt;
}

+ (void)addProperty:(NSString *)propertyName
{
    objc_property_attribute_t type = { "T", "@\"NSString\"" };
    objc_property_attribute_t ownership = { "C", "" }; // C = copy
    objc_property_attribute_t backingivar  = { "V", "name" };
    objc_property_attribute_t attrs[] = { type, ownership, backingivar };
    class_addProperty([Rooms class], propertyName.UTF8String, attrs, 3);
    class_addMethod([Rooms class], NSSelectorFromString(propertyName), (IMP)ageGetter, "@@:");
    NSString *selStr = [NSString stringWithFormat:@"set%@:",propertyName];
    selStr = @"setAge:";
    class_addMethod([Rooms class], NSSelectorFromString(selStr), (IMP)ageSetter, "v@:@");
}

NSString *ageGetter(id self, SEL _cmd) {
    NSString *var = NSStringFromSelector(_cmd);
    Ivar ivar = class_getInstanceVariable([Rooms class], var.UTF8String);
    return object_getIvar(self, ivar);
}

void ageSetter(id self, SEL _cmd, NSString *newName) {
    NSString *var = [NSStringFromSelector(_cmd) stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""];
    NSString *head = [var substringWithRange:NSMakeRange(0, 1)];
    head = [head lowercaseString];
    var = [var stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:head];
    var = [var stringByReplacingCharactersInRange:NSMakeRange(var.length-1, 1) withString:@""];
    Ivar ivar = class_getInstanceVariable([Rooms class], var.UTF8String);
    id oldName = object_getIvar(self, ivar);
    if (oldName != newName) object_setIvar(self, ivar, [newName copy]);
}

@end
