//
// Created by Eugene on 22.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "UINavigationBar+HighPoint.h"


@implementation UINavigationBar (HighPoint)
- (void) configureTranslucentNavigationBar{
    self.barTintColor = [UIColor colorWithRed:34.0f / 255.0f green:45.0f / 255.0f blue:77.0f / 255.0f alpha:0.9];
    self.translucent = YES;
}

- (void) configureOpaqueNavigationBar{
    self.barTintColor = [UIColor colorWithRed:30.f / 255.f green:29.f / 255.f blue:48.f / 255.f alpha:1];
    self.translucent = NO;
}

@end