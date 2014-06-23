//
//  UIButton+HighPoint.m
//  HighPoint
//
//  Created by Michael on 12.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "UIButton+HighPoint.h"

//==============================================================================

@implementation UIButton (HighPoint)

//==============================================================================

- (void) hp_tuneFontForSwitch
{
    self.titleLabel.font = [UIFont fontWithName: @"FuturaPT-Light" size: 18.0];
}

//==============================================================================

- (void) hp_tuneFontForGreenButton
{
    self.titleLabel.font = [UIFont fontWithName: @"FuturaPT-Light" size: 18.0];
    self.titleLabel.textColor = [UIColor colorWithRed: 80.0f / 255.0f green: 226.0f / 255.0f blue:193.0f / 255.0f alpha: 1.0f];
}

//==============================================================================

@end
