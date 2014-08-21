//
//  URLs.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 25.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "URLs.h"



@implementation URLs


+ (NSString *) getServerURL; {
    NSString *serverUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"serverURL"];
    if (serverUrl.length < 7) {
        serverUrl = [NSString stringWithFormat:@"http://%@:3002", kAPIBaseURLString];
    } else  {
        serverUrl = [NSString stringWithFormat:@"http://%@:3002", serverUrl];
    }
    NSLog(@"IP --- > %@", serverUrl);
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
        NSLog(@"test ip setted");
    }
}

+ (void) setServerUrl : (NSString *) serverUrl; {
    [[NSUserDefaults standardUserDefaults] setObject:serverUrl forKey:@"serverURL"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"serverURL setted = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"serverURL"]);
}


@end
