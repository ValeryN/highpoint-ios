//
//  HPAppearanceManager.m
//  HighPoint
//
//  Created by Eugene on 31/10/14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPAppearanceManager.h"

@implementation HPAppearanceManager
+ (void) loadAllAppearance {
    [self loadNavigantionBarAppearance];
}

+ (void) loadNavigantionBarAppearance{
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0/255.f green:0/255.f blue:24.f/255.f alpha:1]];
}
@end
