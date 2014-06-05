//
//  UILabel+HighPoint.m
//  HighPoint
//
//  Created by Michael on 04.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "UILabel+HighPoint.h"

//==============================================================================

@implementation UILabel (HighPoint)

//==============================================================================

- (void) hp_tuneForUserListCellName
{
    self.font = [UIFont fontWithName: @"FuturaPT-Book" size: 18.0];
}

//==============================================================================

- (void) hp_tuneForUserListCellAgeAndCity
{
    self.font = [UIFont fontWithName: @"FuturaPT-Light" size: 15.0];
}

//==============================================================================

- (void) hp_tuneForUserListCellPointText
{
    self.font = [UIFont fontWithName: @"FuturaPT-Medium" size: 15.0];
}

//==============================================================================

- (void) hp_tuneForUserListCellAnonymous
{
    self.font = [UIFont fontWithName: @"FuturaPT-Medium" size: 15.0];
}

//==============================================================================

- (void) hp_tuneForSwitchIsOn
{
    self.font = [UIFont fontWithName: @"FuturaPT-Light" size: 18.0];
    self.textColor = [UIColor colorWithRed: 30.0 / 255.0
                                     green: 29.0 / 255.0
                                      blue: 48.0 / 255.0
                                     alpha: 1.0];
}

//==============================================================================

- (void) hp_tuneForSwitchIsOff
{
    self.font = [UIFont fontWithName: @"FuturaPT-Light" size: 18.0];
    self.textColor = [UIColor colorWithRed: 80.0 / 255.0
                                     green: 226.0 / 255.0
                                      blue: 193.0 / 255.0
                                     alpha: 0.4];
}

//==============================================================================

@end
