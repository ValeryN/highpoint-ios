//
//  UserTokenUtils.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 02.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "UserTokenUtils.h"

@implementation UserTokenUtils


//TODO: save token to keychain?

+ (void) setUserToken : (NSString *) token {
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"token setted = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"token"]);
}

+ (NSString *) getUserToken {
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    return token.length > 0 ? token : nil;
}


@end
