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

+ (Tools *)init
{
    Tools *tool = [[Tools alloc] init];
    return tool;
}

+ (NSString *)convertNullString:(NSString *)aString
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
+ (NSString *)dataFilePath:(NSString *)fileName {
	
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

+ (id)readFileWithPath:(NSString *)Path
{
    //NSString *Path = @"/Users/xy/Documents/任务/外卖单.txt";//外卖单.
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
+ (NSString *)getDateWithFormat:(NSString *)format
{
    NSDateFormatter *data_time = [[NSDateFormatter alloc]init];
    [data_time setDateFormat:format];//@"yyyy-MM-dd HH:mm:ss"
    return [data_time stringFromDate:[NSDate date]];
}

#pragma mark 字符转日期
+ (NSDate *)dateFromString:(NSString *)str withDateFormater:(NSString *)formater
{
	NSString *strDate = [str stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:(formater ? formater : @"yyyy-MM-dd HH:mm:ss")];
    return [dateFormatter dateFromString:strDate];
}

#pragma mark 日期比较
+ (BOOL)compareDate:(NSDate *)aDate and:(NSDate *)bDate
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

+ (Byte)byteWithInt:(int)time
{
    char *p_time = (char *)&time;
    
    char str_time[4] = {0};
    
    for(int i= 0 ;i < 4 ;i++)
        
    {
        
        str_time[i] = *p_time;
        
        p_time ++;
        
    }
    
    Byte byte = (Byte)str_time;
    return byte;
}

#pragma mark 获得纯数字
+ (NSString *)ConvertPureNum:(NSString *)num
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

+ (BOOL)checkCardIDWith:(NSString *)CardID
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

void CharLog(NSString *format, ...)
{
    va_list arglist;
    va_start(arglist, format);
    NSString *outStr = [[NSString alloc] initWithFormat:format arguments:arglist];
    va_end(arglist);
    
    outStr = [NSString stringWithString:outStr];
#if DEBUG
    printf("%s",outStr.UTF8String);
#endif
}

+ (NSString *)ConvertCGRect:(NSString *)rectStr
{
    CGRect rect = NSRectFromString(rectStr);
    NSString *result = [NSString stringWithFormat:@"CGRectMake(%.f,%.f,%.f,%.f)",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height];
    return result;
}

#pragma mark - =======去掉数字和小数点之外的所有字符================
+ (NSString *)ConvertNum:(NSString *)num
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

+ (NSString *)printDic:(NSDictionary *)dic
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

+ (BOOL)containsChinese:(NSString *)content
{
    BOOL result = NO;//
    for(int i=0; i< [content length];i++){
        int a = [content characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff) {
            result = YES;
            break;
        }
    }
    
    return result;
}

+ (BOOL)otherOperation:(NSString *)FilePath suffixName:(NSString *)oldName toSuffixName:(NSString *)newName
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

+ (NSString *)getUsersPath
{
    NSString *path = NSHomeDirectory();
    NSArray *listPath = [path componentSeparatedByString:@"/Library"];
    if (listPath.count > 0) {
        path = listPath.firstObject;
        //path = [path stringByAppendingPathComponent:@"Desktop/tmp/智能家居/QQ登录信息.txt"];
    }
    
    return path;
}

+ (NSDictionary *)readCustomPath
{
    NSError *error = nil;
    NSString *Path = [Tools getUsersPath];
    Path = [Path stringByAppendingPathComponent:@"Documents/Caches/DBFile.txt"];
    NSString *content = [NSString stringWithContentsOfFile:Path encoding:NSUTF8StringEncoding error:&error];
    NSDictionary *dic = [content convertToDic];//dic[@"iFace"]
    return dic;
}

+ (void)alterPicData
{
    NSString *pic = @"http://pic34.nipic.com/20131106/9903781_085713979000_2.jpg";
    NSError *error = nil;
    NSString *path = @"/Users/xy/Desktop/tmp/智能家居/QQ登录信息.txt";
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

+ (BOOL) VerifyData:(NSData *)buffer
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

+ (NSArray *)getAllPropertiesWithClass:(Class)class
{
    u_int count;
    objc_property_t *properties  =class_copyPropertyList(class, &count);
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++)
    {
        const char* propertyName =property_getName(properties[i]);
        [propertiesArray addObject: [NSString stringWithUTF8String: propertyName]];
    }
    free(properties);
    return propertiesArray;
}

+ (NSString *)identifierWith:(int)index withFormat:(NSString *)format, ...
{
    NSString *identifier = [NSString stringWithFormat:@"%d",index];
    if (format) {
        va_list arglist;
        va_start(arglist, format);
        NSString *outStr = [[NSString alloc] initWithFormat:format arguments:arglist];
        va_end(arglist);
        
        if (outStr) {
            identifier = [identifier stringByAppendingString:outStr];
        }
    }
    
    return identifier;
}

+ (NSDictionary *)readContentWithPath:(NSString *)path
{
    NSMutableDictionary *dicValue = [NSMutableDictionary dictionary];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    [dicValue setObject:dic[@"rootObject"]?:@"" forKey:@"rootObject"];
    NSMutableDictionary *dicContent = [NSMutableDictionary dictionary];
    dicContent.dictionary = dic[@"objects"];
    for (NSString *key in dicContent) {
        NSDictionary *value = dicContent[key];
        NSArray *listKeys = value.allKeys;
        if ([listKeys containsObject:@"buildSettings"] && [value[@"name"] isEqualToString:@"Release"]) {
            value = dicContent[key];
            NSDictionary *dicSettings = value[@"buildSettings"];
            if ([dicSettings[@"INFOPLIST_FILE"] hasSuffix:@"Info.plist"]) {
                NSString *setKey = [NSString stringWithFormat:@"CODE_SIGN_IDENTITY(%@)",key];
                [dicValue setObject:dicSettings[@"CODE_SIGN_IDENTITY"]?:@"" forKey:setKey];
                value = dicSettings[@"PROVISIONING_PROFILE"];
                if (value) {
                    setKey = [NSString stringWithFormat:@"PROVISIONING_PROFILE(%@)",key];
                    [dicValue setObject:value forKey:setKey];
                }
            }
        }
    }
    
    return dicValue;
}

+ (NSDictionary *)readMobileprovisionFromProjectPath:(NSString *)path
{
    NSDictionary *dic = [Tools readContentWithPath:path];
    //NSLog(@"%@",dic[@"rootObject"]);
    NSString *fileName = [NSString stringWithFormat:@"%@.mobileprovision",dic[@"PROVISIONING_PROFILE(181360B219B9C97F00A82AC3)"]];
    
    NSDictionary *dicValue = [Tools readMobileprovisionFromName:fileName];
    return dicValue;
}

+ (NSDictionary *)readMobileprovisionFromName:(NSString *)fileName
{
    fileName = [NSString stringWithFormat:@"%@.mobileprovision",fileName];
    NSString *profilesPath = @"/Users/xy/Library/MobileDevice/Provisioning Profiles";
    profilesPath = [profilesPath stringByAppendingPathComponent:fileName];
    NSData *data = [NSData dataWithContentsOfFile:profilesPath];
    NSString *currentPath = [NSString stringWithFormat:@"/Users/xy/Documents/Caches/provision.mobileprovision"];
    [data writeToFile:currentPath atomically:YES];
    NSString *path2 = @"/Users/xy/Documents/Caches/project1.plist";
    NSString *script = [NSString stringWithFormat:@"security cms -D -i %@ > %@",currentPath,path2];
    [Tools executeShellWithScript:script];
    NSDictionary *dicValue = [NSDictionary dictionaryWithContentsOfFile:path2];
    return dicValue;
}

#pragma mark 执行shell命令
+ (NSString *)executeShellWithScript:(NSString *)script
{
    NSDictionary *errorInfo = [NSDictionary dictionary];
    script = [NSString stringWithFormat:@"do shell script \"%@\"",script];
    NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
    NSAppleEventDescriptor *des = [appleScript executeAndReturnError:&errorInfo];
    NSString *stringValue = des.stringValue;
    return stringValue;
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

//为文件增加一个扩展属性
+ (BOOL)addExtendedAttributeWithPath:(NSString *)path key:(NSString *)key value:(NSString *)stringValue
{
    NSData *value = [stringValue dataUsingEncoding:NSUTF8StringEncoding];
    ssize_t writelen = setxattr([path fileSystemRepresentation],
                                [key UTF8String],
                                [value bytes],
                                [value length],
                                0,
                                0);
    return writelen==0?YES:NO;
}

+ (BOOL)addExtendedAttributeWithPath:(NSString *)path attributes:(NSDictionary *)attributes
{
    if (attributes.count <= 0) {
        return NO;
    }
    
    BOOL result = YES;
    for (NSString *key in attributes) {
        id value = attributes[key];
        if (![self addExtendedAttributeWithPath:path key:key value:value]) {
            result = NO;//有一个失败，则为NO
        }
    }
    
    return result;
}

//读取文件扩展属性
+ (NSString *)readExtendedAttributeWithPath:(NSString *)path key:(NSString *)key
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:nil];
        NSDictionary *fileExtendedAttributes = fileAttributes[@"NSFileExtendedAttributes"];
        NSData *data = [fileExtendedAttributes objectForKey:key];
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return result;
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

+ (NSDictionary *)getJsonDataFromFile
{
    NSError *error = nil;
    NSString *path = @"/Users/xy/Documents/CrashInfo/json数据.txt";
    NSString *value = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        NSLog(@"%@",error.localizedDescription);
        return nil;
    }
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
    return json;
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

+ (NSArray *)compareFileFromPath:(NSString *)path1 toPath:(NSString *)path2
{
    //查找路径2中不存在的文件
    NSMutableArray *list = [NSMutableArray array];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *listFile1 = [fileManager contentsOfDirectoryAtPath:path1 error:nil];
    NSArray *listFile2 = [fileManager contentsOfDirectoryAtPath:path2 error:nil];
    
    for (NSString *fileName in listFile1) {
        if (![listFile2 containsObject:fileName]) {
            [list addObject:fileName];
            //NSLog(@"%@",fileName);
        }
    }
    
    return [NSArray arrayWithArray:list];
}

+ (BOOL)writeDataToPath:(NSString *)path content:(NSString *)content
{
    NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:path];
    if(outFile == nil)
    {
        NSLog(@"Open of file for writing failed");
        return NO;
    }
    //找到并定位到outFile的末尾位置(在此后追加文件)
    [outFile seekToEndOfFile];
    
    //写入数据
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    [outFile writeData:data];
    
    data = [@"\n" dataUsingEncoding:NSUTF8StringEncoding];
    [outFile writeData:data];
    
    //关闭读写文件
    [outFile closeFile];
    
    return YES;
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

+ (NSArray *)encodeList
{
    NSArray *list = @[@(NSASCIIStringEncoding),		/* 0..127 only */
                      @(NSNEXTSTEPStringEncoding),
                      @(NSJapaneseEUCStringEncoding),
                      @(NSUTF8StringEncoding),
                      @(NSISOLatin1StringEncoding),
                      @(NSSymbolStringEncoding),
                      @(NSNonLossyASCIIStringEncoding),
                      @(NSShiftJISStringEncoding),          /* kCFStringEncodingDOSJapanese */
                      @(NSISOLatin2StringEncoding),
                      @(NSUnicodeStringEncoding),
                      @(NSWindowsCP1251StringEncoding),    /* Cyrillic; same as AdobeStandardCyrillic */
                      @(NSWindowsCP1252StringEncoding),    /* WinLatin1 */
                      @(NSWindowsCP1253StringEncoding),    /* Greek */
                      @(NSWindowsCP1254StringEncoding),    /* Turkish */
                      @(NSWindowsCP1250StringEncoding),    /* WinLatin2 */
                      @(NSISO2022JPStringEncoding ),        /* ISO 2022 Japanese encoding for e-mail */
                      @(NSMacOSRomanStringEncoding),
                      
                      @(NSUTF16StringEncoding),      /* An alias for NSUnicodeStringEncoding */
                      
                      @(NSUTF16BigEndianStringEncoding),          /* NSUTF16StringEncoding encoding with explicit endianness specified */
                      @(NSUTF16LittleEndianStringEncoding),       /* NSUTF16StringEncoding encoding with explicit endianness specified */
                      
                      @(NSUTF32StringEncoding),
                      @(NSUTF32BigEndianStringEncoding),          /* NSUTF32StringEncoding encoding with explicit endianness specified */
                      @(NSUTF32LittleEndianStringEncoding)        /* NSUTF32StringEncoding encoding with explicit endianness specified */
                      ];
    
    return list;
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

- (NSString *)replaceStrings:(NSArray *)targets withString:(NSString *)replacement
{
    NSString *result = self;
    for (NSString *target in targets) {
        result = [result stringByReplacingOccurrencesOfString:target withString:replacement];
    }
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

+ (NSString *)formatWithFloat:(CGFloat)num length:(int)l
{
    if (l <= 0) {
        return nil;
    }
    
    int n = 1;
    NSString *content = [NSString format:@"%%-%d.%df",l-n,n];
    while (1) {
        if (num > pow(10, l-n)) {
            n--;
            break;
        }
        n++;
    }
    
    content = [NSString format:@"%%-%d.%df",l-n,n];
    NSString *result = [NSString format:content,num];
    
    return result;
}

#pragma mark 十六进制字符转data
- (NSData *)dataByHexString
{
    NSString *str = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    char const *myBuffer = str.UTF8String;//bytes
    NSInteger charCount = strlen(myBuffer);//length*2
    if (charCount %2 != 0) {
        return nil;
    }
    NSInteger byteCount = charCount/2;//length
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
    if (![self containsString:@"{"] || ![self containsString:@"}"]) {
        NSLog(@"非JSON字符串，%@",self);
        return nil;
    }
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

- (NSString *)stringUsingASCIIEncoding
{
    const char *cString = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSString *desc = [NSString stringWithCString:cString encoding:NSNonLossyASCIIStringEncoding];
    return desc;
}

#pragma mark 使用MD5加密
- (NSString *)encryptUsingMD5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    // This is the md5 call
    CC_MD5(cStr, (int)strlen(cStr), result); // CommonCrypto/CommonDigest.h
    NSString *value = [NSString stringWithFormat:
                       @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                       result[0], result[1], result[2], result[3],
                       result[4], result[5], result[6], result[7],
                       result[8], result[9], result[10], result[11],
                       result[12], result[13], result[14], result[15]
                       ];
    
    return value;
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

//移除key及其前面部分
- (NSString *)deletePrefix:(NSString *)key
{
    NSArray *list = [self componentSeparatedByString:key];
    NSString *value = list.lastObject;
    return value;
}

//移除key及其后面部分
- (NSString *)deleteSuffix:(NSString *)key
{
    NSArray *list = [self componentSeparatedByString:key];
    NSString *value = list.firstObject;
    return value;
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

- (NSString *)stringForFormat
{
    NSString *tempStr1 = [self stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    NSString *str = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL error:&error];
    if (error) {
        NSLog(@"format : %@",error.localizedDescription);
    }
    
    return str;
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

- (NSArray *)regularExpressionWithPattern:(NSString *)regulaStr
{
    NSMutableArray *array = [NSMutableArray array];
    NSError *error = nil;
    //格式
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    if (error == nil)
    {
        //解析
        NSMatchingOptions options = NSMatchingReportProgress;
        NSArray *listResult = [regex matchesInString:self options:options range:NSMakeRange(0, [self length])];
        for (NSTextCheckingResult *result in listResult) {
            NSMutableDictionary *dicValue = [NSMutableDictionary dictionary];
            NSUInteger numberOfRanges = result.numberOfRanges;
            NSLog(@"%@",[self substringWithRange:result.range]);
            for (int i=0; i<numberOfRanges; i++) {
                NSRange range = [result rangeAtIndex:i];
                NSString *value = [self substringWithRange:range];
                NSString *key = [NSString format:@"%d",i];
                [dicValue setObject:value forKey:key];
            }
            
            [array addObject:dicValue];
        }
    }
    
    return [NSArray arrayWithArray:array];
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

// 截取字符串方法封装
// 截取字符串方法封装
- (NSString *)subStringFrom:(NSString *)startString to:(NSString *)endString
{
    if (!startString) {
        return nil;
    }
    NSRange startRange = [self rangeOfString:startString];
    
    if (startRange.location == NSNotFound) {
        return nil;
    }
    
    NSInteger startIndex = startRange.location+startRange.length;
    NSString *value = [self substringFromIndex:startIndex];
    
    if (!endString) {
        return value;
    }
    
    NSRange endRange = [value rangeOfString:endString];
    
    if (endRange.location == NSNotFound) {
        return nil;
    }
    
    value = [value substringToIndex:endRange.location];
    
//    startString = startString ?: @"";
//    endString = endString ?: @"";
//    
//    NSArray *list = [self componentsSeparatedByString:startString];
//    if (list.count < 2) {
//        return nil;
//    }
//    
//    NSString *value = [list objectAtIndex:1];
//    list = [value componentsSeparatedByString:endString];
//    if (list.count == 0) {
//        return nil;
//    }
//    
//    value = list.firstObject;
    
    return value;
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

- (BOOL)containsDictionary
{
    BOOL isExist = NO;
    for (id obj in self) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            isExist = YES;
            break;
        }
        else if ([obj isKindOfClass:[NSArray class]]) {
            isExist = [self containsDictionary];
        }
    }
    
    return isExist;
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

- (NSString *)stringUsingASCIIEncoding
{
    NSString *desc = self.description;
    desc = [desc stringUsingASCIIEncoding];
    return desc;
}

- (NSString *)stringForFormat
{
    NSString *str = [self.description stringForFormat];
    
    return str;
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
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:format];//@"yyyy-MM-dd HH:mm:ss"
    //dateFormat.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    return [dateFormat stringFromDate:self];
}

@end

#pragma mark NSObject
@implementation NSObject (NSObject)

- (NSData *)archivedData
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    return data;
}

#pragma mark - 通过对象获取全部属性
- (NSArray *)getObjectPropertyList
{
    NSArray *list = nil;
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([self class], &propsCount);
    list = propsCount>0 ? @[] : nil;
    for(int i = 0;i < propsCount; i++)
    {
        objc_property_t prop = props[i];
        
        const char *name = property_getName(prop);
        NSString *propName = [NSString stringWithUTF8String:name];
        list = [list arrayByAddingObject:propName];
    }
    
    return list;
}

- (NSArray *)getObjectIvarList
{
    NSArray *list = nil;
    unsigned int propsCount;
    Ivar *ivar = class_copyIvarList([self class], &propsCount);
    list = propsCount>0 ? @[] : nil;
    for(int i = 0;i < propsCount; i++) {
        Ivar var = ivar[i];
        const char *name = ivar_getName(var);
        NSString *propName = [NSString stringWithUTF8String:name];
        list = [list arrayByAddingObject:propName];
    }
    
    return list;
}

#pragma mark - 通过对象返回一个NSDictionary，键是属性名称，值是属性值。
- (NSDictionary *)getObjectData
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([self class], &propsCount);
    for(int i = 0;i < propsCount; i++)
    {
        objc_property_t prop = props[i];
        
        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
        id value = [self valueForKey:propName];
        if(value == nil)
        {
            value = [NSNull null];
        }
        else
        {
            value = [value getObjectInternal];
        }
        [dic setObject:value forKey:propName];
    }
    return dic;
}

- (id)getObjectInternal
{
    if([self isKindOfClass:[NSString class]]
       || [self isKindOfClass:[NSNumber class]]
       || [self isKindOfClass:[NSNull class]])
    {
        return self;
    }
    
    if([self isKindOfClass:[NSArray class]])
    {
        NSArray *objarr = (NSArray *)self;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        for(int i = 0;i < objarr.count; i++)
        {
            [arr setObject:[[objarr objectAtIndex:i] getObjectInternal] atIndexedSubscript:i];
        }
        return arr;
    }
    
    if([self isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *objdic = (NSDictionary *)self;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        for(NSString *key in objdic.allKeys)
        {
            [dic setObject:[[objdic objectForKey:key] getObjectInternal] forKey:key];
        }
        return dic;
    }
    return [self getObjectData];
}

- (NSString *)customDescription
{
    if ([self isKindOfClass:[NSDictionary class]]) {
        return [(NSDictionary *)self stringForFormat];
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([self class], &propsCount);
    for(int i = 0;i < propsCount; i++)
    {
        objc_property_t prop = props[i];
        
        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
        id value = [self valueForKey:propName];
        if(value == nil)
        {
            value = [NSNull null];
        }
        
        [dic setObject:value forKey:propName];
    }
    NSString *content = [dic stringForFormat];
    return content;
}

- (id)copyObject
{
    id obj = [[self.class alloc] init];
    NSArray *listPro = [self getObjectIvarList];
    for (NSString *key in listPro) {
        id value = [self valueForKey:key];
        [obj setValue:value forKey:key];
    }
    
    return obj;
}

- (id)weakObject
{
    __weak typeof(self) weakSelf = self;
    return weakSelf;
}

@end
