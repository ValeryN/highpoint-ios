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
    self.view.frame = CGRectMake(mainScreenSwitchToLeft, iPhone5ScreenHight - mainScreenSwitchToBottom_568 - mainScreenSwitchHeight, self.view.frame.size.width, self.view.frame.size.height);
    
    [self createSwitchView];

    [self.leftLabel hp_tuneForSwitchIsOn];
    [self.rightLabel hp_tuneForSwitchIsOff];

}

//==============================================================================

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addGesture];
    [_leftLabel sizeToFit];
    [_rightLabel sizeToFit];
}

//==============================================================================

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeGesture];
}

//==============================================================================

- (void) createSwitchView
{
    UIImage *image = [UIImage imageNamed: @"Rectangle"];
    UIImage *resizableImage = [image resizableImageWithCapInsets: UIEdgeInsetsMake(0, 30, image.size.height, 30)];
    _backgroundView.image = resizableImage;
}

//==============================================================================

- (void) addGesture
{
    if(self.tapGesture == nil)
    {
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        self.tapGesture.cancelsTouchesInView = NO;
        self.tapGesture.numberOfTouchesRequired = 1;
        [self.tapGesture setDelegate:self];
        [[self view] addGestureRecognizer:self.tapGesture];

        self.swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
        self.swipeGesture.cancelsTouchesInView = NO;
        self.swipeGesture.direction  = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
        self.swipeGesture.numberOfTouchesRequired = 1;
        [self.swipeGesture setDelegate:self];
        [[self view] addGestureRecognizer:self.swipeGesture];
    }
}

//==============================================================================

- (void) removeGesture
{
    [[self view] removeGestureRecognizer:self.tapGesture];
    [[self view] removeGestureRecognizer:self.swipeGesture];

    self.tapGesture = nil;
    self.swipeGesture = nil;
}

//==============================================================================

- (void) tapGesture:(UITapGestureRecognizer *)recognizer {
    self.switchState = !self.switchState;
    if(self.switchState) {
        [self moveSwitchToRight];
    } else {
        [self moveSwitchToLeft];
    }
}

//==============================================================================

- (void) swipeGesture:(UISwipeGestureRecognizer *)recognizer {
    self.switchState = !self.switchState;
    if(self.switchState) {
        [self moveSwitchToRight];
    } else {
        [self moveSwitchToLeft];
    }
}

//==============================================================================

- (void) moveSwitchToRight
{
    [self.rightLabel hp_tuneForSwitchIsOn];
    [self.leftLabel hp_tuneForSwitchIsOff];

    CGRect newFrame = [self switchOnLabel: _rightLabel];
    [UIView animateWithDuration: 0.4
                     animations: ^{
                                    self.switchView.frame = newFrame;
                                 }
                     completion: ^(BOOL finished)
                                {
                                 }];
}

//==============================================================================

- (void) moveSwitchToLeft
{
    [self.rightLabel hp_tuneForSwitchIsOff];
    [self.leftLabel hp_tuneForSwitchIsOn];

    CGRect newFrame = [self switchOnLabel: _leftLabel];
    [UIView animateWithDuration: 0.4
                     animations: ^{
                                    self.switchView.frame = newFrame;
                                }
                     completion: ^(BOOL finished)
                        {
                         }];

}

//==============================================================================

- (CGRect) switchOnLabel: (UILabel*) label
{
    
//    CGRect rect = CGRectMake(_centerPart.frame.origin.x,
//                             _centerPart.frame.origin.y,
//                             label.frame.size.width,
//                             _centerPart.frame.size.height);
//    _centerPart.frame = rect;
//    
//    rect = CGRectMake(label.frame.origin.x - 15,
//                      _switchView.frame.origin.y,
//                      15 * 2 + _centerPart.frame.size.width,
//                      _switchView.frame.size.height);
    CGRect rect = CGRectMake(label.frame.origin.x - 15,
                              _switchView.frame.origin.y,
                              15 * 2 + label.frame.size.width + 100,
                              _switchView.frame.size.height);
    return rect;
}

//==============================================================================

@end
