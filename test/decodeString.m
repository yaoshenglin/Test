//
//  decodeString.m
//  test
//
//  Created by Yinhaibo on 14-3-12.
//  Copyright (c) 2014年 Yinhaibo. All rights reserved.
//

#import "decodeString.h"
#import "StringEncryption.h"

@implementation decodeString

+(BOOL)isInt:(NSString *)string
{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

+(NSArray *)decodeStringFrom:(NSString *)string
{
    NSString *msg = @"http://caidan.com/App/4VdkXOQsvQqPBHv9M!IrVw==";
    NSArray *list =[msg componentsSeparatedByString:@"caidan.com/App/"];
    NSString *scanSID,*scanPID;
    int scanHotelID=0,scanRoomID=0,scanFriendID=0;
    if (list.count == 2) {
        
        NSString *content = [list objectAtIndex:1];
        
        content = [content stringByReplacingOccurrencesOfString:@"~" withString:@"+"];
        content = [content stringByReplacingOccurrencesOfString:@"|" withString:@"/"];
        
        content = [StringEncryption decryptString:content];
        NSLog(@"content=%@",content);
        NSArray *listID = [content componentsSeparatedByString:@"|"];
        if ([listID count] == 4 && [self isInt:[listID objectAtIndex:2]] && [self isInt:[listID objectAtIndex:3]]) {
            
            scanSID = [listID objectAtIndex:0];
            scanPID = [listID objectAtIndex:1];
            scanHotelID = [[listID objectAtIndex:2] intValue];
            scanRoomID = [[listID objectAtIndex:3] intValue];
            
            //[self performSegueWithIdentifier:@"goHotel" sender:self];
        }
        else if([listID count] == 2 && [self isInt:[listID objectAtIndex:1]]) {
            
            scanFriendID = [[listID objectAtIndex:1] intValue];
            //[self performSegueWithIdentifier:@"goFriend" sender:self];
        }
    }
    else {
        
        //[self performSegueWithIdentifier:@"goScanResult" sender:self];
    }
    
    NSArray *arrResult=[NSArray arrayWithObjects:scanSID,scanPID,[NSNumber numberWithInt:scanHotelID],[NSNumber numberWithInt:scanRoomID],[NSNumber numberWithInt:scanFriendID], nil];
    return arrResult;
}

@end
