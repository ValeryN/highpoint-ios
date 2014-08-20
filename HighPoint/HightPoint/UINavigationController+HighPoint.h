//
//  UINavigationController+HighPoint.h
//  HighPoint
//
//  Created by Michael on 02.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface UINavigationController (HighPoint)

+ (void)hp_configureNavigationBar;

- (void) hp_presentViewController: (UIViewController*) vc;
- (void) hp_popViewController;

@end
