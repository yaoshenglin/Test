//
//  EnumType.h
//  AppCaidan
//
//  Created by zzx on 13-9-12.
//  Copyright (c) 2013年 zzx. All rights reserved.
//

#import <Foundation/Foundation.h>

//用户类型: -1 未知（无效、0饭友、1饭店、2饭团 3供应商
typedef NS_ENUM(NSInteger, Enum_User) {

    User_Unknown  = -1,
    User_Friend = 0,
    User_Hotel = 1,
    User_Group = 2,
    User_Factory = 3
};

// 关注类型 -1 无关系或自己 1 关注 2 粉丝 3 互相关注
typedef NS_ENUM(NSInteger, Enum_Relation) {
    
    Relation_None = -1,
    Relation_Follow = 1,
    Relation_Fans = 2,
    Relation_Mutual = 3
};

//PrinterPaperType
typedef NS_ENUM(NSInteger, Enum_PaperType) {
    
    Printer_58 = 1,
    Printer_80 = 2,
};

//0代表男性，1代表女性，2代表保密
typedef NS_ENUM(NSInteger, Enum_Sex) {
    
    Sex_Men = 0,
    Sex_Women = 1,
    Sex_Undefined = 2
};

//标签类型 -3 系统饭团标签 -2 系统饭店标签 -1 系统饭友标签 1 饭友标签  2 饭店标签 3 饭团标签
typedef NS_ENUM(NSInteger, Enum_Tags) {
    
    Tags_SysyemGroup = -3,
    Tags_SysyemHotel = -2,
    Tags_SysyemFriend = -1,
    Tags_Friend = 1,
    Tags_Hotel = 2,
    Tags_Group = 3
};

//消息类型 1 彩旦团队 2 饭店活动 3 饭团活动 4 饭店收到订单信息
//5 饭店发送给饭友 6 饭友发送给饭友 7 饭友发送给饭店 8 饭店发送给饭店 9 饭友收到订单信息
typedef NS_ENUM(NSInteger, Enum_PushMsg) {
    
    PushMsg_Caidan_Teams = 1,
    PushMsg_Hotel_Activity = 2,
    PushMsg_Group_Activity = 3,
    PushMsg_Hotel_Receive_Order = 4,
    PushMsg_Hotel_to_Friend = 5,
    PushMsg_Friend_to_Friend = 6,
    PushMsg_Friend_to_Hotel = 7,
    PushMsg_Hotel_to_Hotel = 8,
    PushMsg_Friend_Receive_Order = 9
};

// 消息内容类型
typedef NS_ENUM(NSInteger, Enum_PushSendMsg) {
    
    PushSendMsg_Date = -1, // 时间
    PushSendMsg_Normal = 0, // 正常消息
    PushSendMsg_Image = 1, // 图片类型
    PushSendMsg_Voice = 2, // 音频类型
    PushSendMsg_LngLat = 3, // 分享经纬度
    PushSendMsg_Card = 4 // 分享名片
};


//消息查看类型 0 未查看 1 已查看
typedef NS_ENUM(NSInteger, Enum_Notice_State) {
    
    Notice_State_View = 0,
    Notice_State_Viewed = 1
};

//消息查看类型 0 微菜单 1 爱菜单
typedef NS_ENUM(NSInteger, Enum_AccountType) {
    
    AccountType_Vcaidan = 1,
    AccountType_Icaidan = 2
};

//订单下单类型(0:外卖,1:扫描,2:预订)
typedef NS_ENUM(NSInteger, Enum_OrderFromType)
{
    Ordering_Takeaway = 0,
    Ordering_ScanCode = 1,
    Ordering_Preordain = 2
};

// 订单状态 -2 已作废 -1 已取消 0 新订单 1 已确定 2 待付款 3 已付款 4 已完成
typedef NS_ENUM(NSInteger, Enum_OrderStatus) {
    
    OrderStatus_Invalid = -2,
    OrderStatus_Cancel = -1,
    OrderStatus_New = 0,
    OrderStatus_Normal = 1,
    OrderStatus_Submit = 2,
    OrderStatus_Paid = 3,
    OrderStatus_Finish = 4
};

//台房状态 0: 未设置 1:已订 2:空闲
typedef NS_ENUM(NSInteger, Enum_RoomStatus) {
    
    Room_Status_Undefined = 0,
    Room_Status_Used = 1,
    Room_Status_Unused = 2
};

//设备类型
typedef NS_ENUM(NSInteger, Enum_Device_Type) {

    Device_Type_Browser = 1, //浏览器设备
    Device_Type_PC = 2, //电脑设备
    Device_Type_Android = 3, //安卓设备
    Device_Type_IOS = 4, //IOS设备
    Device_Type_WindowPhone = 5 //Windows Phone设备
};

// 评论类型
typedef NS_ENUM(NSInteger, Enum_Comment_Type) {
    
    Comment_Friend = 0, // 饭友
    Comment_Hotel = 1// 饭店
};

// 商家验证类型
typedef NS_ENUM(NSInteger, Enum_Hotel_Type) {
    
    Hotel_Verify_Authing = -1,//审核中
    HOTEL_VERIFY_INVLID = 0, // 未验证
    HOTEL_VERIFY_HOTELV = 1, // 已验证酒店
    HOTEL_VERIFY_TAKEAWAY = 2,// 已验证快餐店
    Hotel_Verify_Fresh = 3// 已验证[生鲜]
};



