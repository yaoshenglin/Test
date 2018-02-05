//
//  DeviceModel.h
//  iFace
//
//  Created by APPLE on 14-9-9.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EnumTypes.h"

#pragma mark 指纹锁功能参数类型(Enum_Fingerpring_FuncType)
typedef NS_ENUM(int, Enum_Fingerpring_FuncType) {
    FuncType_APP                 = 1 << 0,//APP开锁
    FuncType_Fingerpring         = 1 << 1,//指纹开锁
    FuncType_Card                = 1 << 2,//刷卡开锁
    FuncType_Password            = 1 << 3 //密码开锁
};

#pragma mark 指纹锁功能参数设置标志(Enum_PaSetFlag)
typedef NS_ENUM(int, Enum_PaSetFlag) {
    PaSetFlag_Voice             = 1 << 0,//门锁开门语音设置
    PaSetFlag_Lock              = 1 << 1,//门锁常开功能设置
    PaSetFlag_XiePo             = 1 << 2,//门锁胁迫报警标志
    PaSetFlag_Other             = 1 << 3 //其它
};

@interface DeviceModel : NSObject

@property (assign, nonatomic) int ID; //本地记录ID
@property (assign, nonatomic) int remoteID; //服务器记录ID
@property (assign, nonatomic) int UserID; //用户ID
@property (retain, nonatomic) NSString *deviceID; //设备MAC ID（不带符号拼接的的MAC地址）
@property (retain, nonatomic) NSString *PWD;    //设备密码
@property (retain, nonatomic) NSString *imgFace; //背景图片
@property (retain, nonatomic) NSString *Name;       //设备名称（别名）
@property (retain, nonatomic) NSString *imgName;
@property (retain, nonatomic) NSData *InfraredData; //数据（存放的是红外数据编码）
@property (nonatomic) Enum_DeviceType Type;   //设备类型
@property (nonatomic) Enum_SwitchType switchType;   //开关类型

@property (nonatomic) Enum_DataMark DataMark;   //上传标记

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
