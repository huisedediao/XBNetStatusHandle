//
//  XBNetStatusHandle.m
//  h4_plus
//
//  Created by xxb on 2017/3/28.
//  Copyright © 2017年 DreamCatcher. All rights reserved.
//  添加 SystemConfiguration.framework

#import "XBNetStatusHandle.h"
#import <AFNetworking.h>
#import "Reachability.h"


@implementation XBNetStatusHandle

+(void)handleWifiBlock:(WifiBlock)wifiBlock wwanBlock:(WWANBlock)wwanBlock notAvailableBlock:(NotAvailableBlock)notAvailableBlock
{
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            if (notAvailableBlock)
            {
                notAvailableBlock();
            }
            break;
            
        case ReachableViaWiFi:
            if (wifiBlock)
            {
                wifiBlock();
            }
            break;
            
        case ReachableViaWWAN:
            if (wwanBlock)
            {
                wwanBlock();
            }
            break;
            
        default:
            break;
    }
}

+(void)handleReachabilityChangeWithWifiBlock:(WifiBlock)wifiBlock wwanBlock:(WWANBlock)wwanBlock notAvailableBlock:(NotAvailableBlock)notAvailableBlock
{
    AFNetworkReachabilityManager *manage = [AFNetworkReachabilityManager sharedManager];
    [manage setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                if (wifiBlock)
                {
                    wifiBlock();
                }
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                if (wwanBlock)
                {
                    wwanBlock();
                }
            }
                break;
                
            default:
            {
                if (notAvailableBlock)
                {
                    notAvailableBlock();
                }
            }
                break;
        }
    }];
}

@end
