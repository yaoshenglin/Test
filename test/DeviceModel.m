//
//  DeviceModel.m
//  iFace
//
//  Created by APPLE on 14-9-9.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import "DeviceModel.h"
#import "DB.h"

#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

@implementation DeviceModel

+ (NSArray *)getAllKeys
{
    NSArray *listKey = @[@"ID",@"remoteID",@"deviceID",@"Name",@"InfraredData",@"imgFace",@"Type",@"switchType",@"DataMark"];
    return listKey;
}

+ (void)createTable
{
    //NSArray *listType = @[@"integer primary key",@"bool",@"bool",@"bool",@"text",@"text",@"integer"];
    NSDictionary *dicData = @{@"array":[self getAllKeys],
                              @"ID":@"integer primary key",
                              @"remoteID":@"integer",
                              @"deviceID":@"text",
                              @"Name":@"text",
                              @"InfraredData":@"blob",
                              @"imgFace":@"text",
                              @"Type":@"integer",
                              @"switchType":@"integer",
                              @"DataMark":@"integer"};
    NSString *sql = [DB createSqlWith:dicData table:@"MyDevice"];
    
    [DB execSql:sql];
    
    [DB CheckTableWith:sql table:@"MyDevice"];
}

#pragma mark *************************************
#pragma mark 根据sql拿取数据
+ (NSArray *)selectBySql:(NSString *)sql
{
    sqlite3_stmt *stmt = [DB query:sql];
    
    NSMutableArray *list = [NSMutableArray array];
    if (stmt) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            DeviceModel *entity = [[DeviceModel alloc] init];
            
            entity.ID = [DB getInt:stmt index:0];
            entity.remoteID = [DB getInt:stmt index:1];
            entity.deviceID = [DB getString:stmt index:2];
            entity.Name = [DB getString:stmt index:3];
            entity.InfraredData = [DB getData:stmt index:4];
            entity.imgFace = [DB getString:stmt index:5];
            
            entity.Type = [DB getInt:stmt index:6];
            entity.switchType = [DB getInt:stmt index:7];
            entity.DataMark = [DB getInt:stmt index:8];
            
            [list addObject:entity];
        }
    }
    
    sqlite3_finalize(stmt);//释放资源
    
    return list;
}

#pragma mark 新增
//+ (void)insert:(DeviceModel *)entity
//{
//    if (!entity)
//        return;
//    
//    NSString *dataString = [entity.InfraredData dataBytes2HexStr];
//    NSString *sql = [NSString stringWithFormat:@"insert into MyDevice ("
//                     "ID, Name, InfraredData, "
//                     "Type, switchType"
//                     ") values ("
//                     "'%@', '%@', '%@', "
//                     "%d, %d"
//                     ")",
//                     entity.deviceID,entity.Name,dataString,
//                     (int)entity.Type,(int)entity.switchType];
//    
//    [DB execSql:sql];
//}

+ (void)insertData:(DeviceModel *)entity
{
    if (!entity)
        return;
    
    NSString *sql = [NSString stringWithFormat:@"insert into MyDevice ("
                     "ID, Name, imgFace, InfraredData"
                     ") values (?, ?, ?, ?)"];
    
    sqlite3_stmt *stmt = [DB query:sql];
    if (stmt) {
        sqlite3_bind_int(stmt, 1, entity.ID);
        sqlite3_bind_text(stmt, 2, [entity.Name UTF8String], -1, nil);
        sqlite3_bind_text(stmt, 3, [entity.imgFace UTF8String], -1, nil);
        sqlite3_bind_blob(stmt, 4, [entity.InfraredData bytes], (int)[entity.InfraredData length], NULL);
        //sqlite3_bind_int(stmt, 4, entity.Type);
        //sqlite3_bind_int(stmt, 5, entity.switchType);
        
        int result = sqlite3_step(stmt);
        if(result==SQLITE_ERROR)//执行update动作
        {
            NSLog(@"update error");
        }
    }
    
    sqlite3_finalize(stmt);
}

#pragma mark 获取全部信息
+ (NSArray *)getAll
{
    NSString *sql = [NSString stringWithFormat:@"select * from MyDevice"];
    NSArray *list = [DeviceModel selectBySql:sql];
    return list;
}

#pragma mark 根据设备类型拿取信息
+ (NSArray *)getListBy:(int)type
{
    NSString *sql = [NSString stringWithFormat:@"select * from MyDevice where Type=%d",(int)type];
    NSArray *list = [DeviceModel selectBySql:sql];
    return list;
}

#pragma mark 拿取设备类型信息
+ (NSArray *)getListDevice
{
    NSString *sql = [NSString stringWithFormat:@"select * from MyDevice where switchType != 4"];
    NSArray *list = [DeviceModel selectBySql:sql];
    return list;
}

#pragma mark 拿取场景类型信息
+ (NSArray *)getListScene
{
    NSString *sql = [NSString stringWithFormat:@"select * from MyDevice where switchType = 4"];
    NSArray *list = [DeviceModel selectBySql:sql];
    return list;
}

#pragma mark 更新数据
+ (void)update:(DeviceModel *)entity
{
    if (!entity) return;
    
//    NSString *sql = [NSString stringWithFormat:@"update MyDevice set "
//                     "ID=%d, "
//                     "Name='%@', InfraredData='%s'"
//                     " where ID = %d",
//                     entity.ID,
//                     entity.Name,[entity.InfraredData bytes],
//                     entity.ID];
    
    //[DB execSql:sql];
    
//    NSString *sql = @"update MyDevice set ID=?,Name=?,InfraredData=? where id=?";
    NSString *sql = [NSString stringWithFormat:@"update MyDevice set Name=?,imgFace=?,InfraredData=? where id=%d",entity.ID];
    sqlite3_stmt *stmt = [DB query:sql];
    if (stmt) {
//        sqlite3_bind_int(stmt, 1, entity.ID);
        sqlite3_bind_text(stmt, 1, [entity.Name UTF8String], -1, nil);
        sqlite3_bind_text(stmt, 2, [entity.imgFace UTF8String], -1, nil);
        sqlite3_bind_blob(stmt, 3, [entity.InfraredData bytes], (int)[entity.InfraredData length], NULL);
        //sqlite3_bind_int(stmt, 4, entity.Type);
        //sqlite3_bind_int(stmt, 5, entity.switchType);
        int result = sqlite3_step(stmt);
        if(result==SQLITE_ERROR)//执行update动作
        {
            NSLog(@"update error");
        }
    }
    
    sqlite3_finalize(stmt);
}

#pragma mark 删除数据
+ (void)delete:(DeviceModel *)entity
{
    if (!entity) return;
    
    NSString *sql = [NSString stringWithFormat:@"delete from MyDevice where ID = %d", entity.ID];
    
    [DB execSql:sql];
}

+ (void)deleteAll
{
    NSString *sql = @"delete from MyDevice";
    
    [DB execSql:sql];
}

#pragma mark - -------其它---------------------
+ (DeviceModel *)initWithID:(int)ID name:(NSString *)name data:(NSData *)data
{
    DeviceModel *model = [[DeviceModel alloc] init];
    
    model.ID = ID;
    model.Name = name;
    model.InfraredData = data;
    
    return model;
}

- (NSString *)checkSmart:(BOOL)isSmart
{
    NSString *string = isSmart ? @"智能任务:已开启（回家/离家）" : @"智能任务:已关闭（回家/离家）";
    return string;
}

+ (void)connectToSwitch
{
    int sfd;
    char buf[1024];
    long n;
    struct sockaddr_in serv_addr;
    const char *addr = "112.125.95.30";
    UInt16 port = 8001;
    
    //const char *hostMac = "44334CCE072C";
    //const char *slaveMac = "00000001";
    //socklen_t len;
    
    sfd = socket(AF_INET, SOCK_DGRAM, 0);
    
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(port);
    inet_pton(AF_INET, addr, &serv_addr.sin_addr.s_addr);
    
    int a = 1;
    
    while(1) {
        if (a == 1) {
            NSLog(@"请输入:");
            scanf("%s",buf);//A644334CCE072C000000006A78, A144334CCE072C0000000166 7E, A044334CCE072C00000001657F
            NSData *data = nil;
            if (strcmp(buf, "1")==0) {
                //开
                Byte byte[] = {0xA1,0x44,0x33,0x4C,0xCE,0x07,0x2C,0x00,0x00,0x00,0x01,0x66,0x7E};
                
                data = [NSData dataWithBytes:byte length:sizeof(byte)];
                
                NSLog(@"开关开");
            }
            else if (strcmp(buf, "0")==0) {
                //关
                Byte byte[] = {0xA0,0x44,0x33,0x4C,0xCE,0x07,0x2C,0x00,0x00,0x00,0x01,0x65,0x7F};
                data = [NSData dataWithBytes:byte length:sizeof(byte)];
                
                NSLog(@"开关关");
            }else{
                break;
            }
            
            if(fgets(buf, 1024, stdin) == NULL)
                break;
            size_t len = strlen([data bytes]);
            len = sizeof(data);
            len = 13;
            sendto(sfd, [data bytes], len, 0, (struct sockaddr *)&serv_addr, sizeof(serv_addr));
            NSLog(@"send");
        }
        
        a = 2;
        char *msg = malloc(sizeof(char)*1024);
        n = recvfrom(sfd, msg, 1024, 0, NULL, NULL);
        NSData *data = [NSData dataWithBytes:msg length:strlen(msg)];
        
        Byte *data_bytes = (Byte*)[data bytes];
        Byte data_byte = data_bytes[0];
        
        if (data_byte == 0xE0) {
            NSLog(@"关闭从机返回");
        }
        else if (data_byte == 0xE1) {
            NSLog(@"开启从机返回");
        }else{
            NSLog(@"%ld,%@\n",n,data);
        }
        
        //关: e044334c ce072c00 00000185 3e
        //开: e144334c ce072c00 00000187 3f
    }
    
    close(sfd);
    NSLog(@"关闭连接");
}

@end
