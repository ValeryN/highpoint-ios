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
#import "UIButton+HighPoint.h"

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

    [self.leftButton hp_tuneFontForSwitch];
    [self.leftButtonInactive hp_tuneFontForSwitch];

    [self.rightButton hp_tuneFontForSwitch];
    [self.rightButtonInactive hp_tuneFontForSwitch];

    [self makeRightButtonClickable];
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

- (IBAction) buttonTap:(id)sender
{
    self.switchState = !self.switchState;
    if (self.switchState)
        [self moveSwitchToRight];
    else
        [self moveSwitchToLeft];
}

//==============================================================================

- (IBAction) tapGesture:(UITapGestureRecognizer *)recognizer
{
    self.switchState = !self.switchState;
    if (self.switchState)
        [self moveSwitchToRight];
    else
        [self moveSwitchToLeft];
}

//==============================================================================

- (IBAction) swipeRightGesture:(UISwipeGestureRecognizer *)recognizer
{
    if ((!self.switchState) && (recognizer.direction == UISwipeGestureRecognizerDirectionRight))
    {
        self.switchState = !self.switchState;
        [self moveSwitchToRight];
        
    }
}

//==============================================================================

- (IBAction) swipeLeftGesture:(UISwipeGestureRecognizer *)recognizer
{
    if ((self.switchState) && (recognizer.direction == UISwipeGestureRecognizerDirectionLeft))
    {
        self.switchState = !self.switchState;
        [self moveSwitchToLeft];
        
    }
}

//==============================================================================

- (void) moveSwitchToRight
{
    [self makeLeftButtonClickable];
    
    CGRect newFrame = [self switchOnLabel: _rightButton];
    [UIView animateWithDuration: SWITCH_ANIMATION_SPEED
                     animations: ^{
                                     self.switchView.frame = newFrame;
                                     self.leftButton.alpha = 0;
                                     self.leftButtonInactive.alpha = 1;
                                     self.rightButton.alpha = 1;
                                     self.rightButtonInactive.alpha = 0;
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
    [self makeRightButtonClickable];
    
    CGRect newFrame = [self switchOnLabel: _leftButton];
    [UIView animateWithDuration: SWITCH_ANIMATION_SPEED
                     animations: ^{
                                    self.switchView.frame = newFrame;
                         self.leftButton.alpha = 1;
                         self.leftButtonInactive.alpha = 0;
                         self.rightButton.alpha = 0;
                         self.rightButtonInactive.alpha = 1;
                                }
                     completion: ^(BOOL finished)
                                {
                                 }];

    if (_delegate == nil)
        return;
    
    [_delegate switchedToLeft];
}

//==============================================================================

- (void) makeRightButtonClickable
{
    _rightButton.userInteractionEnabled = YES;
    _rightButtonInactive.userInteractionEnabled = YES;
    _leftButton.userInteractionEnabled = NO;
    _leftButtonInactive.userInteractionEnabled = NO;
}

//==============================================================================

- (void) makeLeftButtonClickable
{
    _rightButton.userInteractionEnabled = NO;
    _rightButtonInactive.userInteractionEnabled = NO;
    _leftButton.userInteractionEnabled = YES;
    _leftButtonInactive.userInteractionEnabled = YES;
}

//==============================================================================

- (CGRect) switchOnLabel: (UIView*) label
{
    CGRect rect = CGRectMake(label.frame.origin.x - SIDE_BORDER_SIZE,
                             _switchView.frame.origin.y,
                             SIDE_BORDER_SIZE * 2 + label.frame.size.width,
                             _switchView.frame.size.height);
    return rect;
}

//==============================================================================

@end
