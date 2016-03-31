//
//  Tools.m
//  AppCaidan
//
//  Created by Yin on 14-3-30.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import "Tools.h"
#include <sys/xattr.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <netdb.h>
#import "StringEncryption.h"

@implementation Tools

+(Tools *)init
{
    Tools *tool = [[Tools alloc] init];
    return tool;
}

+(NSString *)convertNullString:(NSString *)aString
{
    if (aString==NULL) {
        return @"";
    }else{
        return aString;
    }
}

+ (BOOL)ValidCRCWithHost:(NSData *)data
{
    /// <summary>
    /// 验证校验码是否正确
    /// </summary>
    /// <param name="data"></param>
    if (!data)
        return false;
    
    Byte crc1 = 0x00;
    Byte crc2 = 0x00;
    Byte *Buf = (Byte *)[data bytes];
    NSInteger length = data.length;
    for (int i = 0; i < length - 2; i++)
    {
        crc1 += Buf[i];
        crc2 ^= Buf[i];
    }
    
    BOOL result = crc1 == Buf[length - 2] && crc2 == Buf[length - 1];
    return result;
}

#pragma ***********************************************************************************************
#pragma mark 拿取文件路径
+(NSString *)dataFilePath:(NSString *)fileName {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    if ([fileName hasSuffix:@".txt"]) {
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"documents"];
    }
    if ([fileName hasSuffix:@".png"]||[fileName hasSuffix:@".jpg"]||[fileName hasSuffix:@".gif"]) {
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"images"];
    }
    [Tools PathExistsAtPath:documentsDirectory];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    return filePath;
}

+ (void)PathExistsAtPath:(NSString *)Path
{
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:Path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:Path withIntermediateDirectories:YES attributes:Nil error:&error];
        if (error) {
            NSLog(@"路径创建失败:%@",error.localizedDescription);
        }
    }
}

#pragma mark 设置备份模式
+ (BOOL)addSkipBackupAttributeToItemAtFilePath:(NSString *)filePath {
    
    const char* charFilePath = [filePath fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(charFilePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}

+(id)readFileWithPath:(NSString *)Path
{
    //NSString *Path = @"/Users/Yin-Mac/Documents/任务/外卖单.txt";//外卖单.
    NSData *data = [[NSMutableData alloc] initWithContentsOfFile:Path];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSString *key = @"我的程序";
    //key = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    id obj = [unarchiver decodeObjectForKey:key];
    [unarchiver finishDecoding];
    
    return obj;
}

+ (NSString *)getFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2)
{
    if (!format) {
        return nil;
    }
    
    va_list arglist;
    va_start(arglist, format);
     NSString *outStr = [[NSString alloc] initWithFormat:format arguments:arglist];
    va_end(arglist);
    
    return outStr;
}

NSString *mergedString(NSString *aString,NSString *bString)
{
    if (!aString && !bString) {
        return nil;
    }
    
    aString = aString ?: @"";
    bString = bString ?: @"";
    
    NSString *result = [NSString stringWithFormat:@"%@%@",aString,bString];
    return result;
}

NSString *pooledString(NSString *aString,NSString *bString,NSString *midString)
{
    if (!aString && !bString) {
        return nil;
    }
    
    aString = aString ?: @"";
    bString = bString ?: @"";
    midString = midString ?: @"";
    
    NSString *result = [NSString stringWithFormat:@"%@%@%@",aString,midString,bString];
    return result;
}

#pragma mark 获取系统时间
+(NSString *)getDateWithFormat:(NSString *)format
{
    NSDateFormatter *data_time = [[NSDateFormatter alloc]init];
    [data_time setDateFormat:format];//@"yyyy-MM-dd HH:mm:ss"
    return [data_time stringFromDate:[NSDate date]];
}

#pragma mark 字符转日期
+(NSDate *)dateFromString:(NSString *)str withDateFormater:(NSString *)formater
{
	NSString *strDate = [str stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:(formater ? formater : @"yyyy-MM-dd HH:mm:ss")];
    return [dateFormatter dateFromString:strDate];
}

#pragma mark 日期比较
+(BOOL)compareDate:(NSDate *)aDate and:(NSDate *)bDate
{
    NSDate * now = [NSDate date];
    NSTimeInterval aBetween = [aDate timeIntervalSinceDate:now];
    NSTimeInterval bBetween = [bDate timeIntervalSinceDate:now];
    
    if (aBetween > bBetween) {
        return YES;
    }
    
    return NO;
}

id getUserData(NSString *key)
{
    if (!key) return nil;
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return obj;
}

void setUserData(id obj,NSString *key)
{
    if (!key) return;
    if (obj) {
        [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark 获得纯数字
+(NSString *)ConvertPureNum:(NSString *)num
{
    if (![num isKindOfClass:[NSString class]]) {
        return NULL;
    }
    NSArray *listNum = [NSArray arrayWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
    for (int i=0; i<num.length; i++) {
        NSString *s = [num substringWithRange:NSMakeRange(i, 1)];
        if (![listNum containsObject:s]) {
            num = [num stringByReplacingOccurrencesOfString:s withString:@" "];
        }
    }
    
    num = [num stringByReplacingOccurrencesOfString:@" " withString:@""];
    return num;
}

+(BOOL)checkCardIDWith:(NSString *)CardID
{
    CardID = [CardID stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (CardID.length < 19) {
        return NO;
    }
    
    NSInteger length = CardID.length;
    if (CardID.length == 19) {
        CardID = [Tools ConvertPureNum:CardID];
        if (length == CardID.length) {
            
            int a = 0,b=0;
            
            for (NSInteger i=length-1; i>=0; i=i-2) {
                NSString *s = [CardID substringWithRange:NSMakeRange(i, 1)];
                int value = s.intValue;
                a = value + a;
            }
            
            for (NSInteger i=length-2; i>=0; i=i-2) {
                NSString *s = [CardID substringWithRange:NSMakeRange(i, 1)];
                int value = s.intValue;
                
                if (value > 4) {
                    value = value*2 - 9;
                }else{
                    value = value * 2;
                }
                
                b = value + b;
            }
            
            if ((a+b)%10 == 0) {
                return YES;
            }else{
                return NO;
            }
        }else{
            return NO;
        }
    }
    
    return NO;
}

+ (NSString *)hexStringFromString:(NSString *)string
{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

// 十六进制转换为普通字符串的。
+ (NSString *)stringFromHexString:(NSString *)hexString
{
    //
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    NSLog(@"------字符串=======%@",unicodeString);
    return unicodeString; 
}

+ (int)hexFromString:(NSString *)string
{
    if (string.length <= 0) {
        return 0;
    }
    
    int result = 0;
    int x = 16;
    for (int i=0; i<string.length; i++) {
        NSString *s = [string substringWithRange:NSMakeRange(i, 1)];
        result = [self getIntFromString:s]*powl(x, string.length-i-1)+result;
    }
    
    
    NSLog(@"%C",(unichar)result);
    return result;
}

#pragma mark 移除前后空格
+ (NSString *)trim:(NSString *)str
{
    if (!str) {
        return @"";
    }
    
    if (![str isKindOfClass:[NSString class]]) {
        return @"";
    }
    
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

#pragma mark 是否为空字符
+ (BOOL)isNullOrEmpty:(NSString *)str
{
    if (!str) {
        return YES;
    }
    
    if([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] <= 0)
        return YES;
    
    NSString *s = [Tools trim:str];
    if ([s isEqualToString:@"null"] || [s isEqualToString:@"(null)"] || [s isEqualToString:@"<null>"] || [s isEqualToString:@"NULL"] || [s isEqualToString:@"(NULL)"] || [s isEqualToString:@"<NULL>"]) {
        return YES;
    }
    
    return NO;
}

+ (NSDictionary *)localIPAddress
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    struct ifaddrs *addrs;
    if (getifaddrs(&addrs)==0) {
        const struct ifaddrs *cursor = addrs;
        while (cursor != NULL) {
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                //NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                //if ([name isEqualToString:@"en0"]) // Wi-Fi adapter
                {
                    NSString *localIP = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
                    NSString *SSID = [NSString stringWithUTF8String:cursor->ifa_name];
                    [dic setObject:localIP forKey:SSID];
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    
    return dic;
}

#pragma mark - =======去掉数字和小数点之外的所有字符================
+(NSString *)ConvertNum:(NSString *)num
{
    if (![num isKindOfClass:[NSString class]]) {
        return NULL;
    }
    NSArray *listNum = [NSArray arrayWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @".", nil];
    for (int i=0; i<num.length; i++) {
        NSString *s = [num substringWithRange:NSMakeRange(i, 1)];
        if (![listNum containsObject:s]) {
            num = [num stringByReplacingOccurrencesOfString:s withString:@" "];
        }
    }
    
    num = [num stringByReplacingOccurrencesOfString:@" " withString:@""];
    return num;
}

+(NSString *)printDic:(NSDictionary *)dic
{
    if (dic) {
        NSMutableString *value = [NSMutableString string];
        NSArray *listKey = [dic allKeys];
        listKey = [listKey sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
            NSComparisonResult result = [obj1 compare:obj2];
            return result;//NSOrderedDescending
        }];
        for (NSString *key in listKey) {
            if ([key isEqual:[listKey firstObject]]) {
                [value appendFormat:@"%@:%@",key,[dic objectForKey:key]];
            }else{
                [value appendFormat:@",%@:%@",key,[dic objectForKey:key]];
            }
        }
        
        return value;
    }
    
    return NULL;
}

+ (NSString *)getDoubleWith:(CGFloat)value
{
    NSString *result = [NSString stringWithFormat:@"%f",value];
    if (value == 0) {
        result = @"0";
    }else{
        while ([result hasSuffix:@"0"]) {
            result = [result substringToIndex:result.length-1];
        }
        
        CGFloat b = result.floatValue;
        if (b == 0) {
            result = @"0";
        }
    }
    
    if ([result hasSuffix:@"."]) {
        result = [result substringToIndex:result.length-1];
    }
    
    return result;
}

+(BOOL)otherOperation:(NSString *)FilePath suffixName:(NSString *)oldName toSuffixName:(NSString *)newName
{
    BOOL isDir;
    
    //判断文件是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:FilePath isDirectory:&isDir])
    {
        //判断是否是为目录
        if (isDir)
        {
            BOOL result = NO;
            //获取当前目录下的所有文件
            NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: FilePath error:nil];
            for (NSString *fileName in directoryContents) {
                //拼成一个完整路径
                NSString *selectedPath = [FilePath stringByAppendingPathComponent: fileName];
                result = [self otherOperation:selectedPath suffixName:oldName toSuffixName:newName];
            }
            
            return result;
        }
        else
        {
            //文件
            NSString *fileName = [FilePath lastPathComponent];
            NSString *fileDir = [FilePath stringByDeletingLastPathComponent];
            if ([fileName hasSuffix:oldName]) {
                fileName = [fileName stringByReplacingOccurrencesOfString:oldName withString:newName];
                NSString *newFilePath = [fileDir stringByAppendingPathComponent:fileName];
                NSError *error = nil;
                [[NSFileManager defaultManager] moveItemAtPath:FilePath toPath:newFilePath error:&error];
                if (error) {
                    NSLog(@"Unable to move file: %@", [error localizedDescription]);
                    return NO;
                }
                
                return YES;
            }
        }
    }
    
    return NO;
}

+ (NSString *)ParseWith:(NSString *)content encoding:(NSStringEncoding)encoding
{
    NSString *result = [content stringByReplacingPercentEscapesUsingEncoding:encoding];
    return result;
}

+ (NSString *)a
{
    NSString *string = @"<p>讨厌的节点<br/></p>";
    
    /*此处将不想要的字符全部放进characterSet1中，不需另外加逗号或空格之类的，除非字符串中有你想要去除的空格，此处< p /等都是单独存在，不作为整个字符*/
    
    NSCharacterSet *characterSet1 = [NSCharacterSet characterSetWithCharactersInString:@"<p/brh>"];
    
    // 将string1按characterSet1中的元素分割成数组
    
    NSArray *list = [string componentsSeparatedByCharactersInSet:characterSet1];
    
    for(NSString *string1 in list)
    {
        if ([string1 length]>0) {
            
            // 此处string即为中文字符串
            
            NSLog(@"string = %@",string1);
        }
    }
    
    return list.firstObject;
}

+ (NSDictionary *)readCustomPath
{
    NSError *error = nil;
    NSString *Path = @"/Users/Yin-Mac/Documents/Caches/DBFile.txt";
    NSString *content = [NSString stringWithContentsOfFile:Path encoding:NSUTF8StringEncoding error:&error];
    NSDictionary *dic = [content convertToDic];//dic[@"iFace"]
    return dic;
}

+ (void)alterPicData
{
    NSString *pic = @"http://pic34.nipic.com/20131106/9903781_085713979000_2.jpg";
    NSError *error = nil;
    NSString *path = @"/Users/Yin-Mac/Desktop/tmp/智能家居/QQ登录信息.txt";
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"json字符串转化失败,%@",error.localizedDescription);
    }
    NSDictionary *jsonDic = [content convertToDic];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:jsonDic];
    [dic setObject:pic forKey:@"figureurl_qq_2"];
    content = [dic convertToString];
    [content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"文件写入失败,%@",error.localizedDescription);
    }
}

+(BOOL) VerifyData:(NSData *)buffer
{
    if (buffer == nil)
        return NO;
    
    Byte crc1 = 0x00;
    Byte crc2 = 0x00;
    NSInteger length = buffer.length;
    
    Byte *value = (Byte*)[buffer bytes];
    
    for (int i=0; i<length; i++) {
        crc1 += value[i];
        crc2 ^= value[i];
    }
    
    Byte reCrc1 = value[length-2];
    Byte reCrc2 = value[length-1];
    
    return (crc1 == reCrc1) && (crc2 == reCrc2);
}

#pragma mark - --------解密字符串
+ (NSString *)decryptString:(NSString *)str
{
    return [StringEncryption decryptString:str];
}

+ (NSString *)decryptGBKString:(NSString *)str
{
    return [self decryptString:str encoding:GBEncoding];
}

+ (NSString *)decryptString:(NSString *)str encoding:(NSStringEncoding)encoding
{
    return [StringEncryption decryptString:str encoding:encoding];
}

+ (NSDictionary *)decryptFrom:(NSString *)str
{
    NSString *Separate = @"/App/";
    NSArray *list = [str componentsSeparatedByString:Separate];
    if ([list count] == 2) {
        NSString *str = [list objectAtIndex:1];
        
        str = [str stringByReplacingOccurrencesOfString:@"~" withString:@"+"];
        str = [str stringByReplacingOccurrencesOfString:@"!" withString:@"/"];
        str = [str stringByReplacingOccurrencesOfString:@"|" withString:@"/"];
        NSString *content = [Tools decryptString:str];
        if (content.length > 0) {
            return @{@"state":@(1),@"value":content};
        }
    }
    
    return @{@"state":@(0),@"value":str};
}

#pragma mark 加密字符串
+ (NSString *)encryptString:(NSString *)str
{
    return [StringEncryption encryptString:str];
}

+ (NSString *)encryptFrom:(NSString *)str
{
    NSString *string = [Tools encryptString:str];
    NSString *Separate = @"/App/";
    string = [NSString format:@"%@%@%@",k_host,Separate,string];
    
    return string;
}

+ (NSString *)encryptMacHost:(NSString *)host
{
    NSString *result = [NSString format:@"device:host;id:%@;ver:1.0",host];
    result = [Tools encryptFrom:result];
    return result;
}

+ (NSString *)encryptPlugID:(NSString *)deviceID
{
    NSString *result = [NSString format:@"device:plug;id:%@;ver:1.0",deviceID];
    result = [Tools encryptFrom:result];
    return result;
}

+ (NSString *)encryptSwitchID:(NSString *)deviceID
{
    NSString *result = [NSString format:@"device:switch;id:%@;ver:1.0",deviceID];
    result = [Tools encryptFrom:result];
    return result;
}

//重命名文件
+(BOOL)RenameAtPath:(NSString *)FilePath newName:(NSString *)newName
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
//    if (![fileMgr isExecutableFileAtPath:FilePath]) {
//        return NO;
//    }
    
    NSString *directoryPath = [FilePath stringByDeletingLastPathComponent];
    NSString *newFilePath = [directoryPath stringByAppendingPathComponent:newName];
    //判断是否移动
    NSError *error = nil;
    [fileMgr moveItemAtPath:FilePath toPath:newFilePath error:&error];
    if (error) {
        NSLog(@"Unable to move file: %@", [error localizedDescription]);
        return NO;
    }
    
    return YES;
}

//根据扩展名替换
+(BOOL)RenameAtPath:(NSString *)FilePath suffixName:(NSString *)oldName toSuffixName:(NSString *)newName
{
    BOOL isDir;
    
    //判断文件是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:FilePath isDirectory:&isDir])
    {
        //判断是否是为目录
        if (isDir)
        {
            BOOL result = NO;
            //获取当前目录下的所有文件
            NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: FilePath error:nil];
            for (NSString *fileName in directoryContents) {
                //拼成一个完整路径
                NSString *selectedPath = [FilePath stringByAppendingPathComponent: fileName];
                result = [self RenameAtPath:selectedPath suffixName:oldName toSuffixName:newName];
            }
            
            return result;
        }
        else
        {
            //文件
            NSString *fileName = [FilePath lastPathComponent];
            NSString *fileDir = [FilePath stringByDeletingLastPathComponent];
            if ([fileName hasSuffix:oldName]) {
                fileName = [fileName stringByReplacingOccurrencesOfString:oldName withString:newName];
                NSString *newFilePath = [fileDir stringByAppendingPathComponent:fileName];
                NSError *error = nil;
                [[NSFileManager defaultManager] moveItemAtPath:FilePath toPath:newFilePath error:&error];
                if (error) {
                    NSLog(@"Unable to move file: %@", [error localizedDescription]);
                    return NO;
                }
                
                return YES;
            }
        }
    }
    
    return NO;
}

+ (BOOL)evaluateWith:(id)object format:(NSString *)regex
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValid = [predicate evaluateWithObject:object];
    return isValid;
}

+ (void)OPTIONS
{
    //而且
    Test c = 31;
    
    NSLog(@"%ld", c);
    
    //是否包含
    if (c & TestC) {
        NSLog(@"OK %ld", c);
    }else{
        NSLog(@"NO %ld", c);
    }
    
    if (c & TestA) {
        NSLog(@"OK");
    }
    
    c = c ^ TestA;
    
    NSLog(@"%ld\n", c );
    
    c  =~ 0;
    NSLog(@"%ld\n", c );
    
    NSLog(@"%@",[Tools getRandomWithLength:6]);
}

CGFloat *colorWithHex(NSString *stringToConvert)
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    CGFloat *cs = (CGFloat *)malloc(sizeof(CGFloat));
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        cs[0] = 1.0;
        cs[1] = cs[2] = 0.0;
        return cs;
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) {
        cs[0] = 1.0;
        cs[1] = cs[2] = 0.0;
        return cs;
    }
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    CGFloat t = 255.0f;
    cs[0] = r/t;
    cs[1] = g/t;
    cs[2] = b/t;
    return cs;
}

BOOL otherOperation(NSString *FilePath,NSString *oldName,NSString *newName)
{
    BOOL isDir;
    
    //判断文件是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:FilePath isDirectory:&isDir])
    {
        //判断是否是为目录
        if (isDir)
        {
            BOOL result = NO;
            //获取当前目录下的所有文件
            NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: FilePath error:nil];
            for (NSString *fileName in directoryContents) {
                //拼成一个完整路径
                NSString *selectedPath = [FilePath stringByAppendingPathComponent: fileName];
                result = otherOperation(selectedPath, oldName, newName);
            }
            
            return result;
        }
        else
        {
            //文件
            NSString *fileName = [FilePath lastPathComponent];
            NSString *fileDir = [FilePath stringByDeletingLastPathComponent];
            if ([fileName hasSuffix:oldName] && ![fileName hasSuffix:newName]) {
                fileName = [fileName stringByReplacingOccurrencesOfString:oldName withString:newName];
                NSString *newFilePath = [fileDir stringByAppendingPathComponent:fileName];
                NSError *error = nil;
                [[NSFileManager defaultManager] moveItemAtPath:FilePath toPath:newFilePath error:&error];
                if (error) {
                    NSLog(@"Unable to move file: %@", [error localizedDescription]);
                    return NO;
                }
                
                return YES;
            }
        }
    }
    
    return NO;
}

+(int)getIntFromString:(NSString *)string
{
    if (string.length <= 0) {
        return 0;
    }
    
    int result = 0;
    
    if ([string isEqualToString:@"a"] || [string isEqualToString:@"A"]) {
        result = 10;
    }
    else if ([string isEqualToString:@"b"] || [string isEqualToString:@"B"]) {
        result = 11;
    }
    else if ([string isEqualToString:@"c"] || [string isEqualToString:@"C"]) {
        result = 12;
    }
    else if ([string isEqualToString:@"d"] || [string isEqualToString:@"D"]) {
        result = 13;
    }
    else if ([string isEqualToString:@"e"] || [string isEqualToString:@"E"]) {
        result = 14;
    }
    else if ([string isEqualToString:@"f"] || [string isEqualToString:@"F"]) {
        result = 15;
    }
    else {
        result = [string intValue];
    }
    
    return result;
}

#pragma mark 生成长度为length的随机字符串
+(NSString *)getRandomWithLength:(int)length
{
    
    NSString *result = @"";
    NSString *mStr = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    for (int i = 0; i <length; i ++) {
        int ran = arc4random() % mStr.length;
        NSString *charStr = [mStr substringWithRange:NSMakeRange(ran, 1)];
        result = [result stringByAppendingString:charStr];
    }
    return result;
}

NSString *replaceString(NSString *string,NSString *oldString,NSString *newString)
{
    NSString *result = [string stringByReplacingOccurrencesOfString:oldString withString:newString];
    return result;
}

+(NSString *)stringWith:(NSDictionary *)dic key:(NSString *)key
{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return NULL;
    }
    if (![[dic objectForKey:key] isKindOfClass:[NSString class]]) {
        return @"";
    }
    
    return [dic objectForKey:key];
}

NSString* getPartString(NSString *string,NSString *aString,NSString *bString)
{
    if (![string isKindOfClass:[NSString class]] || !string || string.length == 0) {
        return NULL;
    }
    
    NSString *result = nil;
    NSArray *list = [string componentsSeparatedByString:aString];
    
    if (list.count > 1) {
        for (int i=1; i<list.count; i++) {
            result = [list objectAtIndex:i];
            
            list = [result componentsSeparatedByString:bString];
            if (list.count > 0) {
                result = [list firstObject];
                
                break;
            }
        }
        
        return result;
    }
    
    return NULL;
}

+ (NSString *)getFilePath:(NSString *)dirPath fileName:(NSString *)fileName
{
    BOOL isDir;
    //判断是否是为目录
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDir])
    {
        if (isDir) {
            //获取当前目录下的所有文件
            NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: dirPath error:nil];
            for (NSString *file in directoryContents) {
                //拼成一个完整路径
                NSString *selectedPath = [dirPath stringByAppendingPathComponent: file];
                NSString *result = [[self class] getFilePath:selectedPath fileName:fileName];
                if (result) {
                    return result;
                }
            }
        }else{
            //文件
            NSString *name = [dirPath lastPathComponent];
            if ([name isEqualToString:fileName]) {
                return dirPath;
            }
        }
    }
    
    return nil;
}

+ (NSArray *)getAllFileNameByPath:(NSString *)path
{
    BOOL isDir;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        if (isDir) {
            NSError *error = nil;
            NSArray *directoryContents = [fileManager contentsOfDirectoryAtPath: path error:&error];
            return directoryContents;
        }else{
            NSLog(@"该路径为一个非目录文件");
            return nil;
        }
    }
    
    return nil;
}

+ (NSDictionary *)getFileAttributesByPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:nil];
        return fileAttributes;
    }
    return nil;
}

+ (NSStringEncoding)getGBKEncoding
{
    NSStringEncoding GBK = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    return GBK;
}

//门禁发送数据中7E、7F部分进行转译
+ (NSData *)translationData:(NSData *)data1
{
    NSMutableData *data = [NSMutableData data];
    data.data = data1;
    NSData *rangeData = [NSData dataWithBytes:"\x7f" length:1];
    for (int i=0; i<data.length; i++) {
        NSData *tempData = [data subdataWithRange:NSMakeRange(i, 1)];
        NSString *nextDataStr = nil;
        if (i != data.length-1) {
            NSData *nextData = [data subdataWithRange:NSMakeRange(i+1, 1)];
            nextDataStr = [nextData hexString];
        }
        if ([tempData isEqualToData:rangeData] && ![nextDataStr isEqualToString:@"02"]) {
            NSString *tempStr = [data hexString];
            tempStr = [tempStr stringByReplacingCharactersInRange:NSMakeRange(i*2, 2) withString:@"7F02"];
            data.data = [tempStr dataByHexString];
            i++;
        }
    }
    
    rangeData = [NSData dataWithBytes:"\x7e" length:1];
    NSRange range = [data rangeOfData:rangeData options:NSDataSearchBackwards range:NSMakeRange(0, data.length)];
    while (range.location != NSNotFound) {
        NSString *dataStr = [data hexString];
        NSRange replaceRange = NSMakeRange(range.location*2, 2);
        dataStr = [dataStr stringByReplacingCharactersInRange:replaceRange withString:@"7F01"];
        data.data = [dataStr dataByHexString];
        
        range = [data rangeOfData:rangeData options:NSDataSearchBackwards range:NSMakeRange(0, data.length)];
    }
    
    return data;
}

+ (BOOL)checkObjFrom:(NSString *)path to:(NSString *)path1
{
    NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    string = replaceString(string, @"\n", @"");
    string = replaceString(string, @"\t", @"");
    string = replaceString(string, @"\"", @"");
    NSArray *listAll = [string componentSeparatedByString:@","];
    NSArray *list1 = @[];
    for (NSString *str in listAll) {
        NSArray *listPart = [str componentSeparatedByString:@":"];
        list1 = [list1 arrayByAddingObject:listPart.firstObject];
    }
    
    string = [NSString stringWithContentsOfFile:path1 encoding:NSUTF8StringEncoding error:nil];
    string = replaceString(string, @"\n", @"");
    string = replaceString(string, @"\"", @"");
    string = replaceString(string, @" ", @"");
    listAll = [string componentSeparatedByString:@";"];
    NSArray *list2 = @[];
    for (NSString *str in listAll) {
        NSArray *listPart = [str componentSeparatedByString:@"="];
        list2 = [list2 arrayByAddingObject:listPart.firstObject];
    }
    
    BOOL result = YES;
    if (list1.count != list2.count) {
        return NO;
    }
    
    for (NSString *str in list1) {
        if (![list2 containsObject:str]) {
            result = NO;
            NSLog(@"不相同 : %@",str);
            break;
        }
    }
    
    return result;
}

#import <objc/runtime.h>
- (NSString *)nameWithInstance:(id)instance
{
    unsigned int numIvars = 0;
    NSString *key=nil;
    Ivar * ivars = class_copyIvarList([self class], &numIvars);
    for (int i=0; i< numIvars; i++) {
        Ivar thisIvar = ivars[i];
        key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
        NSString *value = object_getIvar(self, thisIvar);
        NSLog(@"key = %@,value = %@",key,value);
    }
    for(int i = 0; i < numIvars; i++) {
        Ivar thisIvar = ivars[i];
        const char *type = ivar_getTypeEncoding(thisIvar);
        NSString *stringType =  [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
        if (![stringType hasPrefix:@"@"]) {
            continue;
        }
        if ((object_getIvar(self, thisIvar) == instance)) {
            key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
            break;
        }
    }
    free(ivars);
    return key;
    
}

//解析域名
+ (char *)parseDomain:(NSString *)domain
{
    if (!domain || ![domain isKindOfClass:[NSString class]]) return nil;
    NSString *domainLow = [domain lowercaseString];
    if ([domainLow hasPrefix:@"http://"]) {
        domain = [domain substringFromIndex:7];
    }
    else if ([domainLow hasPrefix:@"https://"]) {
        domain = [domain substringFromIndex:8];
    }
    struct in_addr addr;
    char *IP = (char *)[domain UTF8String];
    if (inet_addr(IP) != INADDR_NONE) {
        //如果是IP地址
        return IP;
    }
    struct hostent *pHost = gethostbyname(IP);
    if (pHost) {
        memcpy(&addr, pHost->h_addr_list[0], pHost->h_length);
        IP = inet_ntoa(addr);
    }else{
        int result = h_errno;
        NSString *errMsg = @"域名解析失败";
        if (result == HOST_NOT_FOUND) {
            errMsg = @"找不到指定的主机";
        }
        else if (result == NO_ADDRESS) {
            errMsg = @"该主机有名称却无IP地址";
        }
        else if (result == NO_RECOVERY) {
            errMsg = @"域名服务器有错误发生";
        }
        else if (result == TRY_AGAIN) {
            errMsg = @"请再调用一次";
        }
        
        NSLog(@"%@",errMsg);
        return nil;
    }
    
    return IP;
}

+ (NSString *)parserDomain:(NSString *)domain
{
    char *IP = [self parseDomain:domain];
    if (IP) {
        return [NSString stringWithUTF8String:IP];
    }
    return nil;
}

+ (NSArray *)getAllEncoding
{
    NSArray *list = @[@(NSASCIIStringEncoding),@(NSNEXTSTEPStringEncoding),@(NSJapaneseEUCStringEncoding),@(NSUTF8StringEncoding),@(NSISOLatin1StringEncoding),@(NSSymbolStringEncoding),@(NSNonLossyASCIIStringEncoding),@(NSShiftJISStringEncoding),@(NSISOLatin2StringEncoding),@(NSUnicodeStringEncoding),@(NSWindowsCP1251StringEncoding),@(NSWindowsCP1252StringEncoding),@(NSWindowsCP1253StringEncoding),@(NSWindowsCP1254StringEncoding),@(NSWindowsCP1250StringEncoding),@(NSISO2022JPStringEncoding),@(NSMacOSRomanStringEncoding),@(NSUTF16StringEncoding),@(NSUTF16BigEndianStringEncoding),@(NSUTF16LittleEndianStringEncoding),@(NSUTF32StringEncoding),@(NSUTF32BigEndianStringEncoding),@(NSUTF32LittleEndianStringEncoding)];
    return list;
}

+ (NSData*)replaceCRCForInfrared:(NSData *)buffer
{
    if (!buffer) {
        return nil;
    }
    NSMutableData *result = [[NSMutableData alloc] init];
    [result appendData:buffer];
    
    Byte crc1 = 0x00;
    Byte crc2 = 0x00;
    Byte *value = (Byte *)[buffer bytes];
    
    for (int i=0; i<buffer.length; i++) {
        crc1 += value[i] & 0xFF;
        crc2 ^= value[i] & 0xFF;
    }
    
    Byte crc[] = {crc1, crc2};
    [result appendBytes:crc length:sizeof(crc)];
    
    return result;
    
}

@end

#pragma mark - ---------NSString---------------------
@implementation NSString (NSObject)
+ (NSString *)jsonStringWithString:(NSString *) string
{
    NSString *result = [NSString stringWithFormat:@"\"%@\"",
                        [[string stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"] stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""]
                        ];
    return result;
}

+ (NSString *)jsonStringWithArray:(NSArray *)array
{
    NSMutableString *reString = [NSMutableString string];
    [reString appendString:@"["];
    NSMutableArray *values = [NSMutableArray array];
    for (id valueObj in array) {
        NSString *value = [[self class] jsonStringWithObject:valueObj];
        if (value) {
            [values addObject:[NSString stringWithFormat:@"%@",value]];
        }
    }
    [reString appendFormat:@"%@",[values componentsJoinedByString:@","]];
    [reString appendString:@"]"];
    return reString;
}

+ (NSString *)jsonStringWithDictionary:(NSDictionary *)dictionary
{
    NSArray *keys = [dictionary allKeys];
    NSMutableString *reString = [NSMutableString string];
    [reString appendString:@"{"];
    NSMutableArray *keyValues = [NSMutableArray array];
    for (int i=0; i<[keys count]; i++) {
        NSString *name = [keys objectAtIndex:i];
        id valueObj = [dictionary objectForKey:name];
        NSString *value = [[self class] jsonStringWithObject:valueObj];
        if (value) {
            [keyValues addObject:[NSString stringWithFormat:@"\"%@\":%@",name,value]];
        }
    }
    [reString appendFormat:@"%@",[keyValues componentsJoinedByString:@","]];
    [reString appendString:@"}"];
    return reString;
}

+ (NSString *)jsonStringWithObject:(id) object
{
    NSString *value = nil;
    if (!object) {
        return value;
    }
    if ([object isKindOfClass:[NSString class]]) {
        value = [[self class] jsonStringWithString:object];
    }else if([object isKindOfClass:[NSDictionary class]]){
        value = [[self class] jsonStringWithDictionary:object];
    }else if([object isKindOfClass:[NSArray class]]){
        value = [[self class] jsonStringWithArray:object];
    }
    return value;
}

- (NSString *) phonetic
{
    NSMutableString *source = [self mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformStripDiacritics, NO);
    return source;
}

- (NSString *)replaceString:(NSString *)target withString:(NSString *)replacement
{
    NSString *result = [self stringByReplacingOccurrencesOfString:target withString:replacement];
    return result;
}

+ (NSString *)format:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2)
{
    if (!format)
        return nil;
    
    va_list arglist;
    va_start(arglist, format);
    NSString *outStr = [[NSString alloc] initWithFormat:format arguments:arglist];
    va_end(arglist);
    
    return outStr;
}

- (NSString *)AppendFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2)
{
    va_list arglist;
    va_start(arglist, format);
    NSString *outStr = [[NSString alloc] initWithFormat:format arguments:arglist];
    va_end(arglist);
    
    outStr = [self stringByAppendingString:outStr];
    
    return outStr;
}

#pragma mark 十六进制字符转data
- (NSData *)dataByHexString
{
    NSString *str = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    char const *myBuffer = str.UTF8String;
    NSInteger charCount = strlen(myBuffer);
    if (charCount %2 != 0) {
        return nil;
    }
    NSInteger byteCount = charCount/2;
    uint8_t *bytes = malloc(byteCount);
    for (int i=0; i<byteCount; i++) {
        unsigned int value;
        sscanf(myBuffer + i*2, "%2x",&value);
        bytes[i] = value;
    }
    NSData *data = [NSData dataWithBytes:bytes length:byteCount];
    return data;
}

- (NSString *)AppendString:(NSString *)aString
{
    return [self stringByAppendingString:aString];
}

- (NSString *)objectAtIndex:(NSInteger)index
{
    if (self.length > index) {
        NSString *result = [self substringWithRange:NSMakeRange(index, 1)];
        return result;
    }
    return nil;
}

- (NSDictionary *)convertToDic
{
    NSError *error = nil;
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        NSLog(@"字符串转换成字典失败,error : %@",error.localizedDescription);
    }
    
    return jsonDic;
}

+ (NSString *)stringWith:(NSString *)string
{
    if (string == nil) {
        return @"";
    }
    
    return string;
}

- (NSArray *)componentSeparatedByString:(NSString *)key
{
    NSString *string = self;
    if (key.length <= 0) {
        return [string componentsSeparatedByString:key];
    }
    
    if ([string hasPrefix:key]) {
        NSInteger len = key.length;
        string = [string substringFromIndex:len];
    }
    
    if ([string hasSuffix:key]) {
        NSInteger len = key.length;
        string = [string substringToIndex:string.length-len];
    }
    
    return [string componentsSeparatedByString:key];
}

//移除前缀
- (NSString *)removePrefix:(NSString *)aString
{
    if ([self hasPrefix:aString]) {
        return [self substringFromIndex:aString.length];
    }
    
    return self;
}

//移除后缀
- (NSString *)removeSuffix:(NSString *)aString
{
    if ([self hasSuffix:aString]) {
        return [self substringToIndex:self.length-aString.length];
    }
    
    return self;
}

- (NSDate *)dateWithFormat:(NSString *)format
{
    if (!format) {
        format = @"yyyy-MM-dd HH:mm:ss";
    }
    NSString *strDate = [self stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:(format ? format : @"yyyy-MM-dd HH:mm:ss")];
    NSDate *date = [dateFormatter dateFromString:strDate];
    return date;
}

//获取第一个字符
- (NSString *)firstString
{
    if (self.length > 1) {
        NSString *result = [self substringToIndex:1];
        return result;
    }
    
    return self;
}

- (int)countTheStr
{
    NSString *strtemp = self;
    int strlength = 0 ;
    char *p = (char *)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    NSInteger length = [strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding];
    for (int i= 0 ; i<length ;i++) {
        
        if (*p) {
            
            p ++ ;
            strlength ++ ;
            
        }
        else {
            p ++ ;
        }
    }
    
    return strlength;
}

- (NSString *)getCStringWithLen:(int)len
{
    NSMutableString *string = [NSMutableString string];
    for (int i=0; i<self.length; i++) {
        NSString *s = [self substringWithRange:NSMakeRange(i, 1)];
        int currentLen = string.countTheStr + s.countTheStr;
        if (currentLen <= len) {
            [string appendString:s];
        }else{
            break;
        }
    }
    
    return string;
}

- (BOOL)evaluateWithFormat:(NSString *)regex
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValid = [predicate evaluateWithObject:self];
    return isValid;
}

- (long)parseInt:(int)type
{
    long value = strtol([self UTF8String],nil,type);
    return value;
}

//写入文件结尾
- (void)writeToEndOfFileAtPath:(NSString *)path headContent:(WriteBlock)block
{
    BOOL isExit = [[NSFileManager defaultManager] fileExistsAtPath:path];
    
    if (!isExit) {
        
        NSLog(@"文件不存在");
        NSString *s = block();
        [s writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
    }
    
    NSFileHandle  *outFile;
    NSData *buffer;
    
    outFile = [NSFileHandle fileHandleForWritingAtPath:path];
    
    if(outFile == nil)
    {
        NSLog(@"Open of file for writing failed");
    }
    
    //找到并定位到outFile的末尾位置(在此后追加文件)
    [outFile seekToEndOfFile];
    
    //读取inFile并且将其内容写到outFile中
    NSString *bs = [NSString stringWithFormat:@"%@\n",self];
    buffer = [bs dataUsingEncoding:NSUTF8StringEncoding];
    
    [outFile writeData:buffer];
    
    //关闭读写文件
    [outFile closeFile];
}

@end

#pragma mark - --------NSArray----------------------
@implementation NSArray (NSObject)

- (id)getObjByKey:(NSString *)key value:(id)value
{
    for (id obj in self) {
        if(value == [obj valueForKey:key])
        {
            return obj;
        }
    }
    
    return nil;
}

- (NSArray *)replaceObject:(NSUInteger)index with:(id)anObject
{
    NSMutableArray *list = [NSMutableArray arrayWithArray:self];
    if (self.count > index) {
        [list replaceObjectAtIndex:index withObject:anObject];
    }
    return list;
}

//获取数组中不包含array的部分
- (NSArray *)compareFrom:(NSArray *)array
{
    NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",self];
    NSArray * filter = [array filteredArrayUsingPredicate:filterPredicate];
    return filter;
}

@end

#pragma mark - --------NSData----------------------
@implementation NSData (NSObject)

- (NSData *)subdataWithRanges:(NSRange)range
{
    if (range.length > UINT_MAX) {
        return nil;
    }
    else if (NSMaxRange(range) <= self.length) {
        return [self subdataWithRange:range];
    }
    else if (self.length < range.location) {
        return nil;
    }
    
    NSInteger length = self.length - range.location;
    range.length = length;
    return [self subdataWithRange:range];
}

- (long)parseInt:(int)type
{
    NSString *str = [self hexString];
    long value = [str parseInt:type];
    return value;
}

- (NSString *)convertToString
{
    NSString *result = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
    return result;
}

- (NSString *)stringUsingEncoding:(NSStringEncoding)encoding
{
    NSString *result = [[NSString alloc] initWithData:self encoding:encoding];
    return result;
}

- (NSString *)dataBytes2HexStr
{
    if (!self) {
        return nil;
    }
    Byte *bytes = (Byte*)[self bytes];
    NSString *hexStr = @"";
    for(int i=0;i<[self length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%X",bytes[i]&0xff];///16进制数
        if([newHexStr length] == 1)
            hexStr=[NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr=[NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    
    return hexStr;
}

#pragma mark 十六进制data转字符
- (NSString *)hexString
{
    NSString *dataStr = self.description;
    dataStr = [dataStr substringFromIndex:1];
    dataStr = [dataStr substringToIndex:dataStr.length-1];
    dataStr = [dataStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    dataStr = [dataStr uppercaseString];
    return dataStr;
}

#pragma mark 数据分割
- (NSData *)dataWithStart:(NSInteger)start end:(NSInteger)end
{
    if (!self) {
        return nil;
    }
    NSInteger count = self.length - start - end;
    NSData *data = [self subdataWithRange:NSMakeRange(start, count)];
    
    return data;
}

- (NSString *)stringUsingEncode:(NSStringEncoding)encode
{
    NSString *result = [[NSString alloc] initWithData:self encoding: encode];
    return result;
}

- (NSString *)stringWithRange:(NSRange)range
{
    NSData *data = [self subdataWithRange:range];
    
    NSString *result = [data dataBytes2HexStr];
    
    return result;
}

- (id)unarchiveData
{
    id obj = [NSKeyedUnarchiver unarchiveObjectWithData:self];
    return obj;
}

- (NSArray *)transformToDecimal
{
    NSArray *list = [NSArray array];
    for (int i=0; i<self.length; i++) {
        NSData *data = [self subdataWithRange:NSMakeRange(i, 1)];
        NSString *lenString = [data dataBytes2HexStr];
        char *errMsg;
        long len = strtoul([lenString UTF8String],&errMsg,16);
        list = [list arrayByAddingObject:@(len)];
    }
    
    return list;
}

@end

#pragma mark - --------NSDictionary----------------------
@implementation NSDictionary (NSObject)

- (NSDictionary *)dictionaryWithDictionary:(NSDictionary *)dict
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self];
    [dic addEntriesFromDictionary:dict];
    
    NSDictionary *result = [NSDictionary dictionaryWithDictionary:dic];
    
    return result;
}

- (NSDictionary *)AppendDictionary:(NSDictionary *)dict
{
    return [self dictionaryWithDictionary:dict];
}

- (NSString *)convertToString
{
    NSError *error = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"NSDictionary转NSString出错,%@",error.localizedDescription);
    }
    
    NSString *result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    result = [result stringByReplacingOccurrencesOfString:@"\n" withString:@""];

    return result;
}

@end

#pragma mark - --------NSDate------------------------
@implementation NSDate (NSObject)
+ (NSString *)dateWithFormat:(NSString *)format
{
    NSDateFormatter *data_time = [[NSDateFormatter alloc] init];
    [data_time setDateFormat:format];//@"yyyy-MM-dd HH:mm:ss"
    return [data_time stringFromDate:[NSDate date]];
}

- (NSString *)dateWithFormat:(NSString *)format
{
    NSDateFormatter *data_time = [[NSDateFormatter alloc] init];
    [data_time setDateFormat:format];//@"yyyy-MM-dd HH:mm:ss"
    return [data_time stringFromDate:self];
}

@end

#pragma mark NSObject
@implementation NSObject (NSObject)

- (NSData *)archivedData
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    return data;
}

@end
