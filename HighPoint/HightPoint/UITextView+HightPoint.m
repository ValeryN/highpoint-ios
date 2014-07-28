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






#pragma mark - chat view

- (void) hp_tuneForTextViewPlaceholderText {
    self.textColor = [UIColor colorWithRed: 199.0 / 255.0
                                         green: 199.0 / 255.0
                                          blue: 204.0 / 255.0
                                         alpha: 1];
    self.font = [UIFont fontWithName: @"FuturaPT-Book" size: 16.0];

}

- (void) hp_tuneForTextViewMsgText {
    self.textColor = [UIColor colorWithRed: 230.0 / 255.0
                                     green: 236.0 / 255.0
                                      blue: 242.0 / 255.0
                                     alpha: 1.0];
    self.font = [UIFont fontWithName: @"FuturaPT-Book" size: 16.0];
    
}

@end
