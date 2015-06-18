//
//  SsidUtility.m
//  TimerNext
//
//  Created by Duane Homick on 2015-05-08.
//  Copyright (c) 2015 Duane Homick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SsidUtility.h"

@implementation SsidUtility

+ (id)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer NSArray *)CNCopySupportedInterfaces();
    NSDictionary *info;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) { break; }
    }
    return info;
}


@end