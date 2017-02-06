//
//  DB.m
//  AppCaidan
//
//  Created by zzx on 13-9-9.
//  Copyright (c) 2013年 zzx. All rights reserved.
//

#import "DB.h"
#import "Tools.h"

@implementation DB

static sqlite3 *db;

+ (sqlite3 *)getDB
{
    return db;
}

+(NSString *)getDBFileNameByHost:(NSString *)host
{
    NSString *DBFile = @"iFace.db";
    if ([host isEqualToString:@"v.test.caidan.com"]) {
        DBFile = @"iFace(测试外网).db";
    }
    else if ([host hasPrefix:@"192.168"]) {
        DBFile = @"iFace(内网).db";
    }
    
    return DBFile;
}

//建表
+ (sqlite3 *)open:(NSString *)fileName
{
    if (!db) {
        NSString *path = @"~/Documents/Caches/";
        path = [path stringByAppendingPathComponent:fileName];
        NSString *database_path = [path stringByExpandingTildeInPath];
        if (sqlite3_open([database_path UTF8String], &db) != SQLITE_OK) {
            
            NSLog(@"数据库打开失败");
            return nil;
        }
        
        [Tools addSkipBackupAttributeToItemAtFilePath:database_path];
    }
    return db;
}

+ (sqlite3 *)openFromPath:(NSString *)path
{
    if (db) {
        sqlite3_close(db);
    }
    
    if (sqlite3_open([path UTF8String], &db) != SQLITE_OK) {
        
        NSLog(@"数据库打开失败");
        return nil;
    }
    return db;
}

+ (sqlite3 *)openWithPath:(NSString *)path
{
    sqlite3 *dbBase = nil;
    if (sqlite3_open([path UTF8String], &dbBase) != SQLITE_OK) {
        
        NSLog(@"数据库打开失败");
        return nil;
    }
    return dbBase;
}

+ (void)close
{
    if (db) {
        int result = sqlite3_close(db);
        if (result == SQLITE_OK) {
            NSLog(@"close iFace DB");
        }
        else if (result == 5) {
            result = sqlite3_busy_timeout(db, 1000);
            result = sqlite3_close(db);
        }
    }
}

+ (void)close:(sqlite3 *)dbBase
{
    if (dbBase) {
        int result = sqlite3_close(dbBase);
        if (result == SQLITE_OK) {
            NSLog(@"close iFace DB");
        }
        else if (result == 5) {
            result = sqlite3_busy_timeout(dbBase, 1000);
            result = sqlite3_close(dbBase);
        }
    }
}

#pragma mark - 拼接建表语句
+ (NSString *)createSqlWithKey:(NSArray *)listKey Type:(NSArray *)listType table:(NSString *)tableName
{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"create table if not exists %@ (",tableName];
    for (int i=0; i<listKey.count; i++) {
        NSString *key = listKey[i];
        NSString *type = listType[i];
        NSString *value = nil;
        if (![key isEqualToString:listKey.lastObject]) {
            value = [NSString stringWithFormat:@"%@ %@,",key,type];
        }else{
            value = [NSString stringWithFormat:@"%@ %@",key,type];
        }
        
        [sql appendString:value];
    }
    
    [sql appendString:@")"];
    
    return sql.description;
}

+ (NSString *)createSqlWith:(NSDictionary *)dicData table:(NSString *)tableName
{
    NSArray *listKey = dicData[@"array"];//由于dicData.allKeys的顺序可能与放进去时的顺序不同,故在此用array来获取正确顺序字段的数组
    NSMutableString *sql = [NSMutableString stringWithFormat:@"create table if not exists %@ (",tableName];
    for (NSString *key in listKey) {
        NSString *type = dicData[key];
        NSString *value = nil;
        if (![key isEqualToString:listKey.lastObject]) {
            value = [NSString stringWithFormat:@"%@ %@,",key,type];
        }else{
            value = [NSString stringWithFormat:@"%@ %@",key,type];
        }
        
        [sql appendString:value];
    }
    
    [sql appendString:@")"];
    
    return sql.description;
}

+ (BOOL)execSql:(NSString *)sql name:(NSString *)tableName
{
    char *err;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        NSLog(@"数据库操作失败:%s,\n%@",err,sql);
        return NO;
    }
    return YES;
}

+ (BOOL)execSql:(NSString *)sql
{
    [DB open:@"测试数据库.db"];
    char *err;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        NSLog(@"数据库操作失败:%s,\n%@",err,sql);
        return NO;
    }
    return YES;
}

+ (BOOL)CheckTableWith:(NSString *)sql table:(NSString *)tableName
{
    NSString *newName = [tableName stringByAppendingString:@"1"];
    NSArray *listAll = [DB getColumnBy:sql from:tableName];
    NSArray *listColumn = [DB GetAllColumnFrom:tableName];
//    //数据库表中的键值集合
//    NSMutableArray *listDB = [NSMutableArray array];
//    for (NSDictionary *dicColumn in listColumn) {
//        [listDB addObject:dicColumn[@"name"]];
//    }
    
    if (listColumn.count > listAll.count) {
        [DB deleteTable:tableName];
        [DB execSql:sql];
        return NO;
    }
    
    BOOL isAdd = NO;
    for (NSDictionary *dic in listAll) {
        if (![listColumn containsObject:dic]) {
            NSString *name = dic[@"name"];
            NSString *type = dic[@"type"];
            [DB addColumn:name type:type table:tableName];
            isAdd = YES;
            NSLog(@"key : %@",name);
        }
    }
    
    if (isAdd) {
        
//        NSLog(@"需要增加");
//        return NO;
        
        [DB rename:tableName to:newName];
        if ([DB execSql:sql]) {
            sql = [DB setInsertSql:listAll In:tableName from:newName];
            if ([DB execSql:sql]) {
                [DB deleteTable:newName];
            }else{
                [DB deleteTable:tableName];
                [DB rename:newName to:tableName];
            }
        }
        
        return NO;
    }
    
    return YES;
}

+ (sqlite3_stmt *)query:(NSString *)sql
{
    sqlite3_stmt *stmt;
    const char *pzTail;
    
    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, &pzTail);
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库操作失败,errorCode:%d,%s", result,pzTail);
        return nil;
    }
    
    return stmt;
}

+(BOOL)checkColumn:(NSString *)name table:(NSString *)table
{
    NSString *sql = [NSString stringWithFormat:@"select %@ from %@",name,table];
    
    sqlite3_stmt *stmt;
    
    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, nil);
    
    sqlite3_finalize(stmt);
    
    if (result != SQLITE_OK) {
        return NO;
    }
    return YES;
}

+(BOOL)contain:(NSString *)aString with:(NSString *)bString
{
    NSAssert([aString isKindOfClass:[NSString class]], @"aString is not string");
    NSAssert([bString isKindOfClass:[NSString class]], @"bString is not string");
    
    NSRange range = [aString rangeOfString:bString];
    
    if (range.location != NSNotFound) {
        return YES;
    }
    
    return NO;
}

+(NSString *)setInsertSql:(NSArray *)list In:(NSString *)table1 from:(NSString *)table2
{
    NSString *sql = [NSString stringWithFormat:@"insert into %@ select ",table1];
    
    for (NSDictionary *dic in list) {
        NSString *name = dic[@"name"];
        if (![dic isEqual:list.lastObject]) {
            sql = [sql stringByAppendingFormat:@"%@,",name];
        }else{
            sql = [sql stringByAppendingString:name];
        }
    }
    
    sql = [sql stringByAppendingFormat:@" from %@",table2];
    
    return sql;
}

//执行插入事务语句
+ (void)execInsertTransactionSql:(NSArray *)listSQL
{
    //使用事务，提交插入sql语句
    @try{
        char *errorMsg;
        if (sqlite3_exec(db, "BEGIN", NULL, NULL, &errorMsg)==SQLITE_OK)
        {
            //NSLog(@"启动事务成功");
            sqlite3_free(errorMsg);
            sqlite3_stmt *stmt;
            for (int i = 0; i<listSQL.count; i++)
            {
                if (sqlite3_prepare_v2(db,[[listSQL objectAtIndex:i] UTF8String], -1, &stmt,NULL)==SQLITE_OK)
                {
                    if (sqlite3_step(stmt)!=SQLITE_DONE) sqlite3_finalize(stmt);
                }
            }
            if (sqlite3_exec(db, "COMMIT", NULL, NULL, &errorMsg)==SQLITE_OK)   NSLog(@"提交事务成功");
            sqlite3_free(errorMsg);
        }else {
            NSLog(@"%s",errorMsg);
            sqlite3_free(errorMsg);
        }
    }
    @catch(NSException *e)
    {
        char *errorMsg;
        if (sqlite3_exec(db, "ROLLBACK", NULL, NULL, &errorMsg)==SQLITE_OK)
        {
            //NSLog(@"回滚事务成功");
        }else{
            NSLog(@"回滚事务失败");
        }
        sqlite3_free(errorMsg);
    }
    @finally{}
}

#pragma mark - ========拿取数据=====================
+ (NSString *)getString:(sqlite3_stmt *)stmt index:(int)theIndex
{
    char *val = (char*)sqlite3_column_text(stmt, theIndex);
    if (val==NULL) {
        return NULL;
    }
    NSString *result = [[NSString alloc]initWithUTF8String:val];
    return result;
}

#pragma mark 拿取int值
+ (int)getInt:(sqlite3_stmt *)stmt index:(int)theIndex
{
    int result = sqlite3_column_int(stmt, theIndex);
    return result;
}

#pragma mark 拿取long值
+ (long)getLong:(sqlite3_stmt *)stmt index:(int)theIndex
{
    long result = (long)sqlite3_column_int64(stmt, theIndex);
    return result;
}

#pragma mark 拿取double值
+ (double)getDouble:(sqlite3_stmt *)stmt index:(int)theIndex
{
    double result = sqlite3_column_double(stmt, theIndex);
    return result;
}

#pragma mark 拿取BOOL值
+ (bool)getBoolean:(sqlite3_stmt *)stmt index:(int)theIndex
{
    NSString *str = [DB getString:stmt index:theIndex];
    BOOL result = [[str uppercaseString] isEqualToString:@"TRUE"] || [[str uppercaseString] isEqualToString:@"YES"] || [[str uppercaseString] isEqualToString:@"1"];
    return result;
}

#pragma mark 拿取data值
+ (NSData *)getData:(sqlite3_stmt *)stmt index:(int)theIndex
{
    NSUInteger length = sqlite3_column_bytes(stmt, theIndex);
    const void *value = (sqlite3_column_blob(stmt, theIndex));
    if (value) {
        NSData *result = [NSData dataWithBytes:value length:length];
        return result;
    }
    
    return nil;
}

#pragma mark - =======获取数据总数===============
+(NSInteger)getTotalRecord:(NSString *)tableName
{
    NSString *sql = [NSString stringWithFormat:@"select count(*) from %@",tableName];
    NSInteger count = [DB getAllTotalFrom:sql];
    return count;
}

+ (int)getAllTotalFrom:(NSString *)sql
{
    int count = 0;
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        
        if (sqlite3_step(stmt)) {
            count = sqlite3_column_int(stmt, 0);
        }
    }else{
        NSLog(@"数据库查询数据失败,errorCode:%d,%@", result,sql);
    }
    
    sqlite3_finalize(stmt);//释放资源
    return count;
}

#pragma mark - =======增加列(单列)===============
+ (void)addColumn:(NSString *)name type:(NSString *)type table:(NSString *)table
{
    NSString *sql = [NSString stringWithFormat:@"select %@ from %@",name,table];
    
    if (![DB checkColumn:name table:table]) {
        sql = [NSString stringWithFormat:@"alter table %@ add column %@ %@",table,name,type];
        if (![self execSql:sql name:table]) {
            NSLog(@"增加列'%@'失败",name);
        }
    }
}

#pragma mark - =======增加列(多列)===============
+ (void)addColumnWith:(NSArray *)array table:(NSString *)table
{
    for (NSDictionary *dic in array) {
        NSString *name = dic.allKeys.firstObject;
        NSString *type = dic.allValues.firstObject;
        if (![DB checkColumn:name table:table]) {
            NSString *sql = [NSString stringWithFormat:@"alter table %@ add column %@ %@",table,name,type];
            if (![DB execSql:sql]) {
                NSLog(@"增加列'%@'失败",name);
            }
        }
    }
}

#pragma mark - =======删除表===============
+(BOOL)deleteTable:(NSString *)tableName
{
    NSString *str = [NSString stringWithFormat:@"drop table %@",tableName];
    sqlite3_stmt *stmt=nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    if (result != SQLITE_OK) {
        NSLog(@"删除数据库操作失败");
        return NO;
    }
    sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    return YES;
}

#pragma mark - =======重命名===============
+(BOOL)rename:(NSString *)aTable to:(NSString *)bTable
{
    NSString *sql = [NSString stringWithFormat:@"alter table %@ rename to %@",aTable,bTable];
    char *err;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        NSLog(@"数据库操作失败:%s,\n%@",err,sql);
        return NO;
    }
    
    return YES;
}

+(NSArray *)getColumnBy:(NSString *)sql from:(NSString *)tableName
{
    NSString *value = sql;
    NSString *Separated = [tableName stringByAppendingString:@" ("];
    NSArray *list = [value componentsSeparatedByString:Separated];
    value = list[1];
    
    while ([value hasSuffix:@")"]) {
        value = [value substringToIndex:value.length-1];
    }
    
    while ([value hasPrefix:@" "]) {
        value = [value substringFromIndex:1];
    }
    
    //去掉可能存在的多余的空格
    NSRange range = [value rangeOfString:@"  "];
    while (range.location != NSNotFound) {
        value = replaceString(value, @"  ", @" ");
        range = [value rangeOfString:@"  "];
    }
    value = replaceString(value, @", ", @",");
    value = replaceString(value, @" ,", @",");
    
    list = [value componentsSeparatedByString:@","];
    
    NSMutableArray *result = [NSMutableArray array];
    for (int i=0; i<list.count; i++) {
        NSString *string = list[i];
        NSArray *listValue = [string componentsSeparatedByString:@" "];
        NSString *key = listValue[0];
        if (listValue.count > 2 && [listValue[0] isEqualToString:@"ID"]) {
            string = replaceString(string, [key stringByAppendingString:@" "], @"");
        }else{
            string = listValue[1];
        }
        
        NSDictionary *dic = @{@"cid":@(i),
                              @"name":key,
                              @"type":string};
        [result addObject:dic];
    }
    
    return result;
}

#pragma mark 根据表名,列数据生成建表语句
//列对象:@{@"cid":@(0),@"name":@"column",@"type":@"integer"}
+ (NSString *)getCreateSql:(NSString *)table columns:(NSArray *)listColumns
{
    NSMutableArray *listN = [NSMutableArray array];
    NSMutableDictionary *dicSQL = [NSMutableDictionary dictionary];
    for (int i=0; i<listColumns.count; i++) {
        NSDictionary *dic = listColumns[i];
        [listN addObject:dic[@"name"]];
        [dicSQL setObject:dic[@"type"] forKey:dic[@"name"]];
    }
    [dicSQL setObject:listN forKey:@"array"];
    NSString *sql = [DB createSqlWith:dicSQL table:table];
    return sql;
}

+ (void)bindData:(NSDictionary *)dic stmt:(sqlite3_stmt *)stmt
{
    int cid = [dic[@"cid"] intValue] + 1;
    NSString *name = dic[@"name"];
    NSString *type = dic[@"type"];
    name = @"name_value";
    if ([type isBelong:@"integer"] || [type isBelong:@"integer primary key"]) {
        int value = [dic[name] intValue];
        sqlite3_bind_int(stmt, cid, value);
    }
    else if ([type isBelong:@"double"]) {
        int value = [dic[name] doubleValue];
        sqlite3_bind_double(stmt, cid, value);
    }
    else if ([type isBelong:@"bool"]) {
        BOOL value = [dic[name] boolValue];
        sqlite3_bind_int(stmt, cid, value);
    }
    else if ([type isBelong:@"text"]) {
        NSString *value = dic[name];
        sqlite3_bind_text(stmt, cid, [value UTF8String], -1, nil);
    }
    else if ([type isBelong:@"blob"]) {
        NSData *data = dic[name];
        sqlite3_bind_blob(stmt, cid, [data bytes], (int)[data length], NULL);
    }
}

#pragma mark - =======查询表所有字段====================
+ (NSArray *)GetAllColumnFrom:(NSString*)TableName
{
    NSMutableArray *result = [NSMutableArray array];
    NSString *getColumn = [NSString stringWithFormat:@"PRAGMA table_info(%@)",TableName];
    sqlite3_stmt *stmt = [self query:getColumn];
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        int cid = [DB getInt:stmt index:0];
        NSString *columnName  = [DB getString:stmt index:1];
        NSString *columnType = [DB getString:stmt index:2];
        BOOL isPK = [DB getBoolean:stmt index:5];
        if (isPK) {
            columnType = [columnType AppendString:@" primary key"];
        }
        
        NSDictionary *dic = @{@"cid":@(cid),
                              @"name":columnName,
                              @"type":columnType};
        [result addObject:dic];
    }
    
    return result;
}

//检查表是否存在该字段
+ (BOOL)CheckColumn:(NSString*)TableName ColumnName:(NSString*) ColumnName
{
    NSArray *ArrColumn =  [self GetAllColumnFrom:TableName];
    for (NSDictionary *dic in ArrColumn) {
        if ([dic[@"name"] isEqualToString:ColumnName]) {
            return YES;
        }
    }
    
    return NO;
}

+ (BOOL)CheckTable:(NSString*)TableName
{
    NSArray *listTable = [[self class] GetAllTable];
    if ([listTable containsObject:TableName]) {
        return YES;
    }else{
        return NO;
    }
    
    //******************************************
//    NSString *getTableInfo = [NSString stringWithFormat:@"select count(*) from sqlite_master where type='table' and name='%@';",TableName] ;
//    char *errMsg = nil;
//    if (sqlite3_exec(db,[getTableInfo UTF8String],NULL,NULL,&errMsg) == SQLITE_OK)
//    {
//        NSLog(@"err : %s",errMsg);
//        return NO;
//    }
//    
//    return YES;
}

+ (NSArray *)GetAllTable
{
    NSMutableArray *arrTable = [NSMutableArray array];
    NSString *getTableInfo = @"select * from sqlite_master where type='table' order by name;";
    sqlite3_stmt *stmt = [DB query:getTableInfo];
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        NSString *TableName  = [DB getString:stmt index:1];
        [arrTable addObject:TableName];
    }
    
    sqlite3_finalize(stmt);
    
    return arrTable;
}

+ (NSArray *)getAllData
{
    NSString *sql = [NSString stringWithFormat:@"select * from WeatherCode"];
    sqlite3_stmt *stmt = [DB query:sql];
    
    NSMutableArray *list = [NSMutableArray array];
    if (stmt) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            NSString *key = [DB getString:stmt index:1];
            NSString *value = [DB getString:stmt index:2];
            NSArray *listValue = @[key,value];
            
            [list addObject:listValue];
        }
    }
    
    sqlite3_finalize(stmt);//释放资源
    
    return list;
}

+ (NSString *)getInsertColumnsWith:(NSArray *)list
{
    NSString *sql = @"";
    for (int i=0; i<list.count; i++) {
        NSDictionary *dic = list[i];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            NSString *name = dic[@"name"];
            sql = [sql AppendFormat:@"%@,",name];
        }
        else if ([dic isKindOfClass:[NSString class]]) {
            NSString *name = list[i];
            sql = [sql AppendFormat:@"%@,",name];
        }
    }
    
    if ([sql hasSuffix:@","]) {
        sql = [sql substringToIndex:sql.length-1];
    }
    
    return sql;
}

+ (NSString *)getUpdateColumnsWith:(NSArray *)list
{
    NSString *sql = @"";
    for (int i=0; i<list.count; i++) {
        NSDictionary *dic = list[i];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            NSString *name = dic[@"name"];
            sql = [sql AppendFormat:@"%@=?,",name];
        }
        else if ([dic isKindOfClass:[NSString class]]) {
            NSString *name = list[i];
            sql = [sql AppendFormat:@"%@=?,",name];
        }
    }
    
    if ([sql hasSuffix:@","]) {
        sql = [sql substringToIndex:sql.length-1];
    }
    
    return sql;
}

+ (NSString *)getValueWith:(NSArray *)list
{
    NSString *sql = @"";
    for (int i=0; i<list.count; i++) {
        sql = [sql AppendFormat:@"?,"];
    }
    
    if ([sql hasSuffix:@","]) {
        sql = [sql substringToIndex:sql.length-1];
    }
    
    return sql;
}

+ (void)printAllTable
{
    [DB open:@""];
    NSArray *listTable = [DB GetAllTable];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (NSString *table in listTable) {
        if ([table isEqualToString:@"Tags"]) {
            listTable = listTable;
        }
        NSArray *listColumn = [DB GetAllColumnFrom:table];
        NSString *sql = @"select * from ";
        sql = [sql AppendString:table];
        sqlite3_stmt *stmt = [DB query:sql];
        
        NSMutableArray *list = [NSMutableArray array];
        if (stmt) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                NSMutableDictionary *dicData = [NSMutableDictionary dictionary];
                for (NSDictionary *dic in listColumn) {
                    
                    int cid = [dic[@"cid"] intValue];
                    NSString *name = dic[@"name"];
                    NSString *type = dic[@"type"];
                    if ([type isBelong:@"integer"]) {
                        [dicData setObject:@([DB getInt:stmt index:cid]) forKey:name];
                    }
                    else if ([type isBelong:@"double"]) {
                        [dicData setObject:@([DB getDouble:stmt index:cid]) forKey:name];
                    }
                    else if ([type isBelong:@"bool"]) {
                        [dicData setObject:@([DB getBoolean:stmt index:cid]) forKey:name];
                    }
                    else if ([type isBelong:@"text"]) {
                        [dicData setObject:[DB getString:stmt index:cid] forKey:name];
                    }
                    else if ([type isBelong:@"blob"]) {
                        [dicData setObject:[DB getString:stmt index:cid] forKey:name];
                    }
                }
                
                [list addObject:dicData];
            }
        }
        
        sqlite3_finalize(stmt);//释放资源
        
//        NSLog(@"%@,%d,%@",table,(int)list.count,list);
        
//        [[NSUserDefaults standardUserDefaults] setObject:list forKey:table];
        [dictionary setObject:list forKey:table];
    }
    
    NSString *path = @"/Users/xy/Documents/Caches/空调.plist";
    [dictionary writeToFile:path atomically:YES];
}

#pragma mark 将路径path中的表插入到路径path1数据库中
+ (void)writeToFileFrom:(NSString *)path
{
    sqlite3 *dbBase = [DB openFromPath:path];
    NSMutableArray *listSQL = [NSMutableArray array];
    NSMutableDictionary *dicDatas = [NSMutableDictionary dictionary];
    if (dbBase) {
        NSArray *listTable = [DB GetAllTable];
        for (NSString *table in listTable) {
            if ([table isEqualToString:@"sqlite_sequence"]) {
                continue;
            }
            NSArray *listColumns = [DB GetAllColumnFrom:table];
            NSString *sql = [DB getCreateSql:table columns:listColumns];
            [listSQL addObject:sql];
            sql = [NSString format:@"select * from %@",table];
            sqlite3_stmt *stmt = [DB query:sql];
            
            NSMutableArray *list = [NSMutableArray array];
            if (stmt) {
                while (sqlite3_step(stmt) == SQLITE_ROW) {
                    NSMutableDictionary *dicData = [NSMutableDictionary dictionary];
                    for (NSDictionary *dic in listColumns) {
                        
                        int cid = [dic[@"cid"] intValue];
                        NSString *type = dic[@"type"];
                        NSString *name = dic[@"name"];
                        if ([type isBelong:@"integer"] || [type isBelong:@"integer primary key"]) {
                            int value = [DB getInt:stmt index:cid];
                            [dicData setObject:@(value) forKey:name];
                        }
                        else if ([type isBelong:@"double"]) {
                            double value = [DB getDouble:stmt index:cid];
                            [dicData setObject:@(value) forKey:name];
                        }
                        else if ([type isBelong:@"bool"]) {
                            BOOL value = [DB getBoolean:stmt index:cid];
                            [dicData setObject:@(value) forKey:name];
                        }
                        else if ([type isBelong:@"text"]) {
                            NSString *value = [DB getString:stmt index:cid];
                            value = value ?: @"";
                            [dicData setObject:value forKey:name];
                        }
                        else if ([type isBelong:@"blob"]) {
                            NSData *data = [DB getData:stmt index:cid];
                            data = data ?: [@"0x00" dataByHexString];
                            [dicData setObject:data forKey:name];
                        }
                    }
                    
                    [list addObject:dicData];
                }
            }
            
            sqlite3_finalize(stmt);//释放资源
            
            [dicDatas setObject:list forKey:table];
        }
    }
    
    path = @"/Users/xy/Documents/Caches/china_address.txt";
    NSData *data = [dicDatas archivedData];
    [data writeToFile:path atomically:YES];
}

@end

@implementation NSString (NSString)

- (BOOL)isBelong:(NSString *)string
{
    int result1 = [self compare:string options:NSCaseInsensitiveSearch];
    if (result1 == NSOrderedSame) {
        return YES;
    }
    
    return NO;
}

@end
