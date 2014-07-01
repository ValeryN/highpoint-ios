//
//  UITextView+HightPoint.m
//  HighPoint
//
//  Created by Michael on 01.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "UITextView+HightPoint.h"

@implementation UITextView (HightPoint)

- (void) hp_tuneForUserPoint
{
    self.font = [UIFont fontWithName: @"FuturaPT-Book" size: 16.0];
    self.textColor = [UIColor colorWithRed: 230.0 / 255.0
                                     green: 236.0 / 255.0
                                      blue: 242.0 / 255.0
                                     alpha: 0.6];

}

@end
