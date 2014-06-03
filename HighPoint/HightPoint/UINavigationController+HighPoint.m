//
//  UINavigationController+HighPoint.m
//  HighPoint
//
//  Created by Michael on 02.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "UINavigationController+HighPoint.h"

//==============================================================================

#define ANIMATION_SPEED 0.5

//==============================================================================

@implementation UINavigationController (HighPoint)

//==============================================================================

- (void) hp_presentViewController: (UIViewController*) vc
{
    if (vc == nil)
        return;

    CATransition* transition = [self createTransition];
    [self.view.layer addAnimation: transition forKey: nil];
    [self pushViewController: vc animated: NO];
}

//==============================================================================

- (void) hp_popViewController
{
    CATransition* transition = [self createTransition];
    transition.subtype = kCATransitionFromBottom;
    [self.view.layer addAnimation: transition forKey: nil];
    [self popViewControllerAnimated: NO];
}

//==============================================================================

- (CATransition*) createTransition
{
    CATransition *transition = [CATransition animation];
    transition.duration = ANIMATION_SPEED;
    transition.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    
    return transition;
}

//==============================================================================

- (void) hp_configureNavigationBar
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        [self.navigationBar setBarTintColor:[UIColor colorWithRed:34.0/255.0 green:45.0/255.0 blue:77.0/255.0 alpha:0.9]];
    }
    else
    {
        [[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithRed:34.0/255.0 green:45.0/255.0 blue:77.0/255.0 alpha:0.9]];
        [self.navigationBar setTintColor:[UIColor colorWithRed:34.0/255.0 green:45.0/255.0 blue:77.0/255.0 alpha:0.9]];
    }
}

@end
