//
//  UIButton+HighPoint.m
//  HighPoint
//
//  Created by Michael on 12.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//



#import "UIButton+HighPoint.h"


@implementation UIButton (HighPoint)


- (void) setHighlightedBackground:(UIColor*)highlightedBackground {
    UIColor* defaultBackgroundColor = self.backgroundColor;
    @weakify(self);
    [RACObserve(self, highlighted) subscribeNext:^(NSNumber * highlighted) {
        @strongify(self);
        if(highlighted.boolValue){
            self.backgroundColor = highlightedBackground;
        }
        else{
            self.backgroundColor = defaultBackgroundColor;
        }
    }];
}

- (UIColor *) highlightedBackground
{
    return [UIColor clearColor];
}

- (void) hp_tuneFontForSwitch
{
    self.titleLabel.font = [UIFont fontWithName: @"FuturaPT-Book" size: 18.0];
}


- (void) hp_tuneFontForGreenButton
{
    self.titleLabel.font = [UIFont fontWithName: @"FuturaPT-Book" size: 18.0];
    self.titleLabel.textColor = [UIColor colorWithRed: 0.0f / 255.0f green: 203.0f / 255.0f blue:254.0f / 255.0f alpha: 1.0f];
}

- (void) hp_tuneFontForGreenDoneButton
{
    self.titleLabel.font = [UIFont fontWithName: @"FuturaPT-Book" size: 18.0];
    self.titleLabel.textColor = [UIColor colorWithRed: 80.0f / 255.0f green: 226.0f / 255.0f blue:193.0f / 255.0f alpha: 1.0f];
}

- (void) hp_tuneForDeleteBtnInContactList
{
    self.titleLabel.font = [UIFont fontWithName: @"FuturaPT-Book" size: 18.0];
    self.titleLabel.textColor = [UIColor colorWithRed: 230.0 / 255.0
                                     green: 236.0 / 255.0
                                      blue: 242.0 / 255.0
                                     alpha: 1.0];
}

@end
