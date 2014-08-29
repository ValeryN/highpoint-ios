//
//  UIButton+HighPoint.h
//  HighPoint
//
//  Created by Michael on 12.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import <UIKit/UIKit.h>

//==============================================================================

@interface UIButton (HighPoint)

- (void)setHighlightedBackground:(UIColor *)highlightedBackground;

- (void) hp_tuneFontForSwitch;
- (void) hp_tuneFontForGreenButton;

- (void)hp_tuneFontForGreenDoneButton;

- (void) hp_tuneForDeleteBtnInContactList;


@end
