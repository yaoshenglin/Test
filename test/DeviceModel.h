//
//  DeviceModel.h
//  iFace
//
//  Created by APPLE on 14-9-9.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceModel : NSObject

@property (assign, nonatomic) int ID; //记录ID
//@property (retain, nonatomic) NSString *deviceID; //设备MAC ID（不带符号拼接的的MAC地址）
//@property (retain, nonatomic) NSString *imgHead; //背景图片
@property (retain, nonatomic) NSString *Name;       //设备名称（别名）
@property (retain, nonatomic) NSString *imgFace;
@property (retain, nonatomic) NSData *InfraredData; //数据（存放的是红外数据编码）
//@property (nonatomic) int Type;   //设备类型
//@property (nonatomic) int switchType;   //开关类型

+ (void)createTable;
#pragma mark 根据sql拿取数据
+ (NSArray *)selectBySql:(NSString *)sql;
#pragma mark 新增
//+ (void)insert:(DeviceModel *)entity;
+ (void)insertData:(DeviceModel *)entity;
#pragma mark 根据全部信息
+ (NSArray *)getAll;
#pragma mark 拿取设备类型信息
+ (NSArray *)getListDevice;
#pragma mark 拿取场景类型信息
+ (NSArray *)getListScene;
#pragma mark 更新数据
+ (void)update:(DeviceModel *)entity;
#pragma mark 删除数据
+ (void)delete:(DeviceModel *)entity;
+ (void)deleteAll;

+ (DeviceModel *)initWithID:(int)ID name:(NSString *)name data:(NSData *)data;
- (NSString *)checkSmart:(BOOL)isSmart;

+ (void)connectToSwitch;

@end
