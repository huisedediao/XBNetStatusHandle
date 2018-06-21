//
//  XBNetStatusHandle.h
//  h4_plus
//
//  Created by xxb on 2017/3/28.
//  Copyright © 2017年 DreamCatcher. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^WifiBlock)(void);
typedef void(^WWANBlock)(void);
typedef void(^NotAvailableBlock)(void);

@interface XBNetStatusHandle : NSObject

+ (BOOL)isIpv6;

+(void)handleWifiBlock:(WifiBlock)wifiBlock wwanBlock:(WWANBlock)wwanBlock notAvailableBlock:(NotAvailableBlock)notAvailableBlock;

+(void)handleReachabilityChangeWithWifiBlock:(WifiBlock)wifiBlock wwanBlock:(WWANBlock)wwanBlock notAvailableBlock:(NotAvailableBlock)notAvailableBlock;

@end
