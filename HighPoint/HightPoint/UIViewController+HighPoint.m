//
//  UIViewController+HighPoint.m
//  HighPoint
//
//  Created by Michael on 18.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "UIViewController+HighPoint.h"

//==============================================================================

@implementation UIViewController (HighPoint)

//==============================================================================

- (void) hp_setNavigationItemPropertiesFromOtherItem: (UINavigationItem*) navItem
{
    // WORKAROUND: we can't link UINavigationItem to UIViewController from IB, and navigationItem property in UIViewController is readonly
    self.navigationItem.title = navItem.title;
    self.navigationItem.prompt = navItem.prompt;
    self.navigationItem.hidesBackButton = navItem.hidesBackButton;
    if (navItem.backBarButtonItem != nil) 
    {
        self.navigationItem.backBarButtonItem = navItem.backBarButtonItem;
    }
    if (navItem.leftBarButtonItem != nil)
    {
        self.navigationItem.leftBarButtonItem = navItem.leftBarButtonItem;
    }
    if (navItem.rightBarButtonItem != nil)
    {
        self.navigationItem.rightBarButtonItem = navItem.rightBarButtonItem;
    }
    if (navItem.titleView != nil)
    {
        self.navigationItem.titleView = navItem.titleView;
    }
}

//==============================================================================

@end
