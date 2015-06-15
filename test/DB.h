//
//  DB.h
//  AppCaidan
//
//  Created by zzx on 13-9-9.
//  Copyright (c) 2013年 zzx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DB : NSObject {

}

+ (sqlite3 *)getDB;
+ (sqlite3 *)open:(NSString *)fileName;
+ (sqlite3 *)openFromPath:(NSString *)path;
+ (sqlite3 *)openWithPath:(NSString *)path;
+ (void)close;
+ (void)close:(sqlite3 *)dbBase;

#pragma mark - 拼接建表语句
+ (NSString *)createSqlWithKey:(NSArray *)listKey Type:(NSArray *)listType table:(NSString *)tableName;
+ (NSString *)createSqlWith:(NSDictionary *)dicData table:(NSString *)tableName;
+ (BOOL)execSql:(NSString *)sql;
+ (BOOL)CheckTableWith:(NSString *)sql table:(NSString *)tableName;
//+ (BOOL)execSql:(NSString *)sql name:(NSString *)tableName;
+ (sqlite3_stmt *)query:(NSString *)sql;
+ (BOOL)checkColumn:(NSString *)name table:(NSString *)table;

+(NSString *)getDBFileNameByHost:(NSString *)host;

+(NSString *)setInsertSql:(NSArray *)list In:(NSString *)table1 from:(NSString *)table2;

//执行插入事务语句
+ (void)execInsertTransactionSql:(NSArray *)listSQL;

+ (NSString *)getString:(sqlite3_stmt *)stmt index:(int)theIndex;
+ (int)getInt:(sqlite3_stmt *)stmt index:(int)theIndex;
+ (long)getLong:(sqlite3_stmt *)stmt index:(int)theIndex;
+ (double)getDouble:(sqlite3_stmt *)stmt index:(int)theIndex;
+ (bool)getBoolean:(sqlite3_stmt *)stmt index:(int)theIndex;
+ (NSData *)getData:(sqlite3_stmt *)stmt index:(int)theIndex;

+ (int)getAllTotalFrom:(NSString *)sql;
+(NSInteger)getTotalRecord:(NSString *)tableName;

//增加列
+ (void)addColumnWith:(NSArray *)array table:(NSString *)table;
+ (void)addColumn:(NSString *)name type:(NSString *)type table:(NSString *)table;

+(BOOL)deleteTable:(NSString *)tableName;//删除表
+(BOOL)rename:(NSString *)aTable to:(NSString *)bTable;

//根据sql语句获取所有列名
+(NSArray *)getColumnBy:(NSString *)sql from:(NSString *)tableName;
//查询所有列
#pragma mark 根据表名,列数据生成建表语句
//列对象:@{@"cid":@(0),@"name":@"column",@"type":@"integer"}
+ (NSString *)getCreateSql:(NSString *)table columns:(NSArray *)listColumns;
+ (NSArray *)GetAllColumnFrom:(NSString*)TableName;

+ (void)bindData:(NSDictionary *)dic stmt:(sqlite3_stmt *)stmt;
//检查列是否存在
+ (BOOL)CheckColumn:(NSString*)TableName ColumnName:(NSString*) ColumnName;
//检查表是否存在
+ (BOOL)CheckTable:(NSString*)TableName;
//获取所有的表名
+ (NSArray*)GetAllTable;

+ (NSArray *)getAllData;
+ (void)printAllTable;
#pragma mark 将路径path中的表插入到路径path1数据库中
+ (void)writeToFileFrom:(NSString *)path;

+ (NSString *)getInsertColumnsWith:(NSArray *)list;
+ (NSString *)getUpdateColumnsWith:(NSArray *)list;
+ (NSString *)getValueWith:(NSArray *)list;

@end

@interface NSString (NSString)

- (BOOL)isBelong:(NSString *)string;

@end
