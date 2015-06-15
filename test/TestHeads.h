//
//  Header.h
//  test
//
//  Created by Yin on 14-9-9.
//  Copyright (c) 2014年 Yinhaibo. All rights reserved.
//

#ifndef test_Header_h
#define test_Header_h

typedef NS_OPTIONS(NSInteger, Test) {
    Test0 = 0,      //0
    TestA = 1 << 0, //1 1 1
    TestB = 1 << 1, //2 2 10 转换成 10进制 2
    TestC = 1 << 2, //4 3 100 转换成 10进制 4
    TestD = 1 << 3, //8 4 1000 转换成 10进制 8
    TestE = 1 << 4  //16 5 10000 转换成 10进制 16
};

#endif
