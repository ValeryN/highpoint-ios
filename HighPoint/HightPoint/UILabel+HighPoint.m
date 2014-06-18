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
    self.font = [UIFont fontWithName: @"FuturaPT-Light" size: 15.0];
    self.textColor = [UIColor colorWithRed: 230.0 / 255.0
                                     green: 236.0 / 255.0
                                      blue: 242.0 / 255.0
                                     alpha: 0.6];
}

//==============================================================================

- (void) hp_tuneForUserCardName
{
    self.font = [UIFont fontWithName: @"YesevaOne" size: 24.0f];
}

//==============================================================================

- (void) hp_tuneForUserCardDetails
{
    self.font = [UIFont fontWithName: @"FuturaPT-Light" size:16.0f];
}

//==============================================================================

@end
