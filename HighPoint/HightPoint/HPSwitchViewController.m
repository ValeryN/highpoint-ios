//
//  HPSwitchViewController.m
//  HightPoint
//
//  Created by Andrey Anisimov on 08.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "HPSwitchViewController.h"
#import "Constants.h"
#import "Utils.h"
#import "UILabel+HighPoint.h"

//==============================================================================

#define SWITCH_ANIMATION_SPEED 0.2
#define SIDE_BORDER_SIZE 15

//==============================================================================

@implementation HPSwitchViewController

//==============================================================================

- (void) viewDidLoad
{
    [self initObjects];
}

//==============================================================================

- (void) initObjects
{
    UIImage *image = [UIImage imageNamed: @"Rectangle"];
    UIImage *resizableImage = [image resizableImageWithCapInsets: UIEdgeInsetsMake(0, 30, image.size.height, 30)];
    _backgroundView.image = resizableImage;

    [self.leftLabel hp_tuneForSwitchIsOn];
    [self.leftLabelInactive hp_tuneForSwitchIsOff];

    [self.rightLabel hp_tuneForSwitchIsOn];
    [self.rightLabelInactive hp_tuneForSwitchIsOff];
}

//==============================================================================

- (void) positionSwitcher: (CGRect) rect
{
    self.view.frame = rect;
    rect.origin.x = 0;
    rect.origin.y = 0;
    _backgroundView.frame = rect;
}

//==============================================================================

#pragma mark - Gestures -

//==============================================================================

- (IBAction) tapGesture:(UITapGestureRecognizer *)recognizer
{
    self.switchState = !self.switchState;
    if(self.switchState)
        [self moveSwitchToRight];
    else
        [self moveSwitchToLeft];
}

//==============================================================================

- (IBAction) swipeRightGesture:(UISwipeGestureRecognizer *)recognizer
{
    if ((!self.switchState) && (recognizer.direction == UISwipeGestureRecognizerDirectionRight))
    {
        [self moveSwitchToRight];
        self.switchState = !self.switchState;
    }
}

//==============================================================================

- (IBAction) swipeLeftGesture:(UISwipeGestureRecognizer *)recognizer
{
    if ((self.switchState) && (recognizer.direction == UISwipeGestureRecognizerDirectionLeft))
    {
        [self moveSwitchToLeft];
        self.switchState = !self.switchState;
    }
}

//==============================================================================

- (void) moveSwitchToRight
{
    CGRect newFrame = [self switchOnLabel: _rightLabel];
    [UIView animateWithDuration: SWITCH_ANIMATION_SPEED
                     animations: ^{
                                     self.switchView.frame = newFrame;
                                     self.leftLabel.alpha = 0;
                                     self.leftLabelInactive.alpha = 1;
                                     self.rightLabel.alpha = 1;
                                     self.rightLabelInactive.alpha = 0;
                      }
                     completion: ^(BOOL finished)
                                {
                                 }];
    if (_delegate == nil)
        return;
    [_delegate switchedToRight];

}

//==============================================================================

- (void) moveSwitchToLeft
{
    CGRect newFrame = [self switchOnLabel: _leftLabel];
    [UIView animateWithDuration: SWITCH_ANIMATION_SPEED
                     animations: ^{
                                    self.switchView.frame = newFrame;
                         self.leftLabel.alpha = 1;
                         self.leftLabelInactive.alpha = 0;
                         self.rightLabel.alpha = 0;
                         self.rightLabelInactive.alpha = 1;
                                }
                     completion: ^(BOOL finished)
                                {
                                 }];

    if (_delegate == nil)
        return;
    [_delegate switchedToLeft];
}

//==============================================================================

- (CGRect) switchOnLabel: (UILabel*) label
{
    CGRect rect = CGRectMake(label.frame.origin.x - SIDE_BORDER_SIZE,
                             _switchView.frame.origin.y,
                             SIDE_BORDER_SIZE * 2 + label.frame.size.width,
                             _switchView.frame.size.height);
    return rect;
}

//==============================================================================

@end
