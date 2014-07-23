//
//  UITextField+HighPoint.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 23.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "UITextField+HighPoint.h"

@implementation UITextField (HighPoint)


- (void) hp_tuneForSearchTextFieldInContactList :(NSString*) placeholderText
{
    self.font = [UIFont fontWithName: @"FuturaPT-Light" size: 16.0];
    UIColor *textColor = [UIColor colorWithRed: 230.0 / 255.0
                                         green: 236.0 / 255.0
                                          blue: 242.0 / 255.0
                                         alpha: 1.0];
    self.textColor = textColor;
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholderText attributes:@{NSForegroundColorAttributeName: textColor}];
}

@end
