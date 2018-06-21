//
//  XBNetStatusHandle.m
//  h4_plus
//
//  Created by xxb on 2017/3/28.
//  Copyright © 2017年 DreamCatcher. All rights reserved.
//  添加 SystemConfiguration.framework

#import "XBNetStatusHandle.h"
//#import <AFNetworking.h>
#import "Reachability.h"

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>


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
//    AFNetworkReachabilityManager *manage = [AFNetworkReachabilityManager sharedManager];
//    [manage setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//        switch (status) {
//            case AFNetworkReachabilityStatusReachableViaWiFi:
//            {
//                if (wifiBlock)
//                {
//                    wifiBlock();
//                }
//            }
//                break;
//            case AFNetworkReachabilityStatusReachableViaWWAN:
//            {
//                if (wwanBlock)
//                {
//                    wwanBlock();
//                }
//            }
//                break;
//
//            default:
//            {
//                if (notAvailableBlock)
//                {
//                    notAvailableBlock();
//                }
//            }
//                break;
//        }
//    }];
}

+ (BOOL)isIpv6
{
    NSArray *searchArray =
    @[ IOS_VPN @"/" IP_ADDR_IPv6,
       IOS_VPN @"/" IP_ADDR_IPv4,
       IOS_WIFI @"/" IP_ADDR_IPv6,
       IOS_WIFI @"/" IP_ADDR_IPv4,
       IOS_CELLULAR @"/" IP_ADDR_IPv6,
       IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    NSLog(@"addresses: %@", addresses);
    
    __block BOOL isIpv6 = NO;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         
         NSLog(@"---%@---%@---",key, addresses[key] );
         
         if ([key rangeOfString:@"ipv6"].length > 0  && ![[NSString stringWithFormat:@"%@",addresses[key]] hasPrefix:@"(null)"] ) {
             
             if ( ![addresses[key] hasPrefix:@"fe80"]) {
                 isIpv6 = YES;
             }
         }
         
     } ];
    
    return isIpv6;
}


+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                        
                        NSLog(@"ipv4 %@",name);
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                        NSLog(@"ipv6 %@",name);
                        
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

@end
