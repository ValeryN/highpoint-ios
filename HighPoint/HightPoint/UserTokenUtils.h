//
//  UserTokenUtils.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 02.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserTokenUtils : NSObject

+ (void) setUserToken : (NSString *) token;
+ (NSString *) getUserToken;

@end
