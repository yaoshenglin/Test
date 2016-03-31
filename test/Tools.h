//
//  Tools.h
//  AppCaidan
//
//  Created by Yin on 14-3-30.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#define varString(var) [NSString stringWithFormat:@"%s",#var]

#import <Foundation/Foundation.h>
#import "TestHeads.h"

typedef NSString * (^WriteBlock)();
typedef CF_ENUM(NSStringEncoding, CFStringBuilt) {
    GBEncoding = 0x80000632 /* kTextEncodingUnicodeDefault + kUnicodeUTF32LEFormat */
};

@interface Tools : NSObject
{
    @public
    NSString *name;
}

+(Tools *)init;

+(NSString *)convertNullString:(NSString *)aString;

+ (BOOL)ValidCRCWithHost:(NSData *)data;

#pragma mark 拿取文件路径
+(NSString *)dataFilePath:(NSString *)fileName;

CGFloat *colorWithHex(NSString *stringToConvert);

#pragma mark 设置备份模式
+ (BOOL)addSkipBackupAttributeToItemAtFilePath:(NSString *)filePath;

+(NSString *)ParseWith:(NSString *)content encoding:(NSStringEncoding)encoding;

+ (NSDictionary *)readCustomPath;//读取自定义路径文件

+ (void)alterPicData;

+ (BOOL)VerifyData:(NSData *)buffer;

#pragma mark - --------解密字符串
+ (NSString *)decryptString:(NSString *)str;
+ (NSString *)decryptGBKString:(NSString *)str;
+ (NSString *)decryptString:(NSString *)str encoding:(NSStringEncoding)encoding;
+ (NSDictionary *)decryptFrom:(NSString *)str;
#pragma mark 加密字符串
+ (NSString *)encryptString:(NSString *)str;
+ (NSString *)encryptFrom:(NSString *)str;

+ (NSString *)encryptMacHost:(NSString *)host;//加密成主机二维码
+ (NSString *)encryptPlugID:(NSString *)deviceID;//加密成插座二维码
+ (NSString *)encryptSwitchID:(NSString *)deviceID;//加密成开关二维码

//重命名文件
+(BOOL)RenameAtPath:(NSString *)FilePath newName:(NSString *)newName;
//根据扩展名替换
+(BOOL)RenameAtPath:(NSString *)FilePath suffixName:(NSString *)oldName toSuffixName:(NSString *)newName;

+ (BOOL)evaluateWith:(id)object format:(NSString *)regex;

+(BOOL)otherOperation:(NSString *)FilePath suffixName:(NSString *)oldName toSuffixName:(NSString *)newName;

+(id)readFileWithPath:(NSString *)Path;

BOOL otherOperation(NSString *FilePath,NSString *oldName,NSString *newName);

+ (NSString *)getFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
NSString *mergedString(NSString *aString,NSString *bString);

+(NSString *)getDateWithFormat:(NSString *)format;
#pragma mark 字符转日期
+(NSDate *)dateFromString:(NSString *)str withDateFormater:(NSString *)formater;

#pragma mark 日期比较
+(BOOL)compareDate:(NSDate *)aDate and:(NSDate *)bDate;

id getUserData(NSString *key);
void setUserData(id obj,NSString *key);

#pragma mark 获得纯数字
+(NSString *)ConvertPureNum:(NSString *)num;

+(BOOL)checkCardIDWith:(NSString *)CardID;

+ (NSString *)hexStringFromString:(NSString *)string;

#pragma mark - =======去掉数字和小数点之外的所有字符================
+(NSString *)ConvertNum:(NSString *)num;

// 十六进制转换为普通字符串的。
+ (NSString *)stringFromHexString:(NSString *)hexString;

+ (int)hexFromString:(NSString *)string;

#pragma mark 是否为空字符
+ (BOOL)isNullOrEmpty:(NSString *)str;

+ (NSDictionary *)localIPAddress;

+(NSString *)printDic:(NSDictionary *)dic;

+ (NSString *)getDoubleWith:(CGFloat)value;

+ (void)OPTIONS;

#pragma mark 生成长度为length的随机字符串
+(NSString *)getRandomWithLength:(int)length;

NSString *replaceString(NSString *string,NSString *oldString,NSString *newString);

+(NSString *)stringWith:(NSDictionary *)dic key:(NSString *)key;

NSString* getPartString(NSString *string,NSString *aString,NSString *bString);

+ (NSString *)getFilePath:(NSString *)dirPath fileName:(NSString *)fileName;
+ (NSArray *)getAllFileNameByPath:(NSString *)path;
+ (NSDictionary *)getFileAttributesByPath:(NSString *)path;

+ (NSStringEncoding)getGBKEncoding;

//门禁发送数据中7E、7F部分进行转译
+ (NSData *)translationData:(NSData *)data1;

+ (BOOL)checkObjFrom:(NSString *)path to:(NSString *)path1;

- (NSString *)nameWithInstance:(id)instance;
//解析域名
+ (char *)parseDomain:(NSString *)domain;
+ (NSString *)parserDomain:(NSString *)domain;

+ (NSArray *)getAllEncoding;
+ (NSData*)replaceCRCForInfrared:(NSData *)buffer;

@end


#pragma mark - ------------------------------
#pragma mark NSDictionary
@interface NSString (NSObject)

+ (NSString *)jsonStringWithString:(NSString *) string;
+ (NSString *)jsonStringWithArray:(NSArray *)array;
+ (NSString *)jsonStringWithDictionary:(NSDictionary *)dictionary;
+ (NSString *)jsonStringWithObject:(id) object;
- (NSString *) phonetic;
- (NSString *)replaceString:(NSString *)target withString:(NSString *)replacement;
+ (NSString *)format:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (NSString *)AppendFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (NSData *)dataByHexString;//十六进制字符转data

- (NSString *)AppendString:(NSString *)aString;
- (NSString *)objectAtIndex:(NSInteger)index;

- (NSDictionary *)convertToDic;
+ (NSString *)stringWith:(NSString *)string;

- (NSArray *)componentSeparatedByString:(NSString *)key;

//移除前缀
- (NSString *)removePrefix:(NSString *)aString;

//移除后缀
- (NSString *)removeSuffix:(NSString *)aString;

- (NSDate *)dateWithFormat:(NSString *)format;

//获取第一个字符
- (NSString *)firstString;

- (int)countTheStr;//计算字符串长度
- (NSString *)getCStringWithLen:(int)len;

- (BOOL)evaluateWithFormat:(NSString *)regex;

//写入文件结尾
- (void)writeToEndOfFileAtPath:(NSString *)path headContent:(WriteBlock)block;

@end

#pragma mark NSArray
@interface NSArray (NSObject)

- (id)getObjByKey:(NSString *)key value:(id)value;
- (NSArray *)replaceObject:(NSUInteger)index with:(id)anObject;
//获取数组中不包含array的部分
- (NSArray *)compareFrom:(NSArray *)array;

@end

#pragma mark NSData
@interface NSData (NSObject)

- (NSData *)subdataWithRanges:(NSRange)range;
- (long)parseInt:(int)type;

- (NSString *)convertToString;
- (NSString *)stringUsingEncoding:(NSStringEncoding)encoding;

#pragma mark 十六进制data转字符
- (NSString *)hexString;
- (NSString *)dataBytes2HexStr;

#pragma mark 数据分割
- (NSData *)dataWithStart:(NSInteger)start end:(NSInteger)end;

- (NSString *)stringUsingEncode:(NSStringEncoding)encode;
- (NSString *)stringWithRange:(NSRange)range;

- (id)unarchiveData;

- (NSArray *)transformToDecimal;//每个字符转化成十进制

@end

#pragma mark NSDictionary
@interface NSDictionary (NSObject)

- (NSDictionary *)dictionaryWithDictionary:(NSDictionary *)dict;
- (NSString *)convertToString;

@end

#pragma mark - --------UIColor------------------------
@interface NSDate (NSObject)
+ (NSString *)dateWithFormat:(NSString *)format;
- (NSString *)dateWithFormat:(NSString *)format;

@end

#pragma mark NSObject
@interface NSObject (NSObject)

- (NSData *)archivedData;

@end

@protocol ToolDelegate <NSObject>

@end
