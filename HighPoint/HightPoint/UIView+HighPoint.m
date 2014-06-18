//
//  UIView+HighPoint.m
//  HighPoint
//
//  Created by Michael on 18.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "UIView+HighPoint.h"

@implementation UIView (HighPoint)

- (void) hp_roundViewWithRadius: (CGFloat) radius
{
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}

@end