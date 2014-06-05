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

- (void) hp_tuneForUseListCellName
{
    self.font = [UIFont fontWithName: @"FuturaPT-Book" size: 18.0];
}

//==============================================================================

- (void) hp_tuneForUseListCellAgeAndCity
{
    self.font = [UIFont fontWithName: @"FuturaPT-Light" size: 15.0];
}

//==============================================================================

- (void) hp_tuneForUseListCellPointText
{
    self.font = [UIFont fontWithName: @"FuturaPT-Medium" size: 15.0];
}

//==============================================================================

@end
