//
//  UIView+HighPoint.h
//  HighPoint
//
//  Created by Michael on 18.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (HighPoint)

+ (UIView *)viewWithNibName:(NSString *)nibName;

- (void) hp_roundViewWithRadius: (CGFloat) radius;

@end
