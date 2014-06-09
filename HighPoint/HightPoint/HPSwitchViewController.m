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

#define SWITCH_ANIMATION_SPEED 0.4

//==============================================================================

@implementation HPSwitchViewController

//==============================================================================

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName: nibNameOrNil bundle:nibBundleOrNil];
    
    if (self == nil)
        return nil;
    
    [self initObjects];

    return self;
}

//==============================================================================

- (void) initObjects
{
    UIImage *image = [UIImage imageNamed: @"Rectangle"];
    UIImage *resizableImage = [image resizableImageWithCapInsets: UIEdgeInsetsMake(0, 30, image.size.height, 30)];
    _backgroundView.image = resizableImage;

    [self.leftLabel hp_tuneForSwitchIsOn];
    [self.rightLabel hp_tuneForSwitchIsOff];
}

//==============================================================================

- (void) positionSwitcher: (CGRect) rect
{
    self.view.frame = rect;
    _backgroundView.frame = rect;
}

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
    [self.rightLabel hp_tuneForSwitchIsOn];
    [self.leftLabel hp_tuneForSwitchIsOff];

    CGRect newFrame = [self switchOnLabel: _rightLabel];
    [UIView animateWithDuration: SWITCH_ANIMATION_SPEED
                     animations: ^{
                                    self.switchView.frame = newFrame;
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
    [self.rightLabel hp_tuneForSwitchIsOff];
    [self.leftLabel hp_tuneForSwitchIsOn];

    CGRect newFrame = [self switchOnLabel: _leftLabel];
    [UIView animateWithDuration: SWITCH_ANIMATION_SPEED
                     animations: ^{
                                    self.switchView.frame = newFrame;
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
    CGRect rect = CGRectMake(label.frame.origin.x - 15,
                             _switchView.frame.origin.y,
                             15 * 2 + label.frame.size.width,
                             _switchView.frame.size.height);
    return rect;
}

//==============================================================================

@end
