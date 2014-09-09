//
//  UIViewController+HighPoint.h
//  HighPoint
//
//  Created by Michael on 18.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import <UIKit/UIKit.h>

//==============================================================================

@interface UIViewController (HighPoint)

- (void) hp_setNavigationItemPropertiesFromOtherItem: (UINavigationItem*) navItem;

- (UIBarButtonItem *)createBarButtonItemWithImage:(UIImage *)image highlighedImage:(UIImage *)highlighedImage action:(SEL)action;
@end
