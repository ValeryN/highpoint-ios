//
//  URLs.h
//  HighPoint
//
//  Created by Andrey Anisimov on 04.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#ifndef HighPoint_URLs_h
#define HighPoint_URLs_h

static NSString * const kAPIBaseURLString = @"146.185.141.21";//146.185.141.21 192.168.0.42

#endif

@interface URLs : NSObject

+ (NSString *) getServerURL;
+ (void) isServerUrlSetted;
+ (void) setServerUrl : (NSString *) serverUrl;
+ (NSString *) getIPFromSettings;

@end