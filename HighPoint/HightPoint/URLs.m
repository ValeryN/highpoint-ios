//
//  URLs.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 25.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "URLs.h"



@implementation URLs

+ (void)load{
    NSLog(@"Warning: current server ip %@", [self getServerURL]);
}

+ (NSString *) getServerURL; {
    NSString *serverUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"serverURL"];
    //serverUrl = @"192.168.0.137";
    if (serverUrl.length < 7) {
        serverUrl = [NSString stringWithFormat:@"http://%@:3002", kAPIBaseURLString];
    } else  {
        serverUrl = [NSString stringWithFormat:@"http://%@:3002", serverUrl];
    }
    
    return serverUrl;
}

+ (NSString *) getIPFromSettings {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"serverURL"];
}

+ (void) isServerUrlSetted {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"serverURL"]) {
        return;
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:kAPIBaseURLString forKey:@"serverURL"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void) setServerUrl : (NSString *) serverUrl; {
    [[NSUserDefaults standardUserDefaults] setObject:serverUrl forKey:@"serverURL"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
