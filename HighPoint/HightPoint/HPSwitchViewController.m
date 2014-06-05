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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initObjects];
}

//==============================================================================

- (void) initObjects
{
    if ([Utils screenPhysicalSize] == SCREEN_SIZE_IPHONE_CLASSIC)
        self.view.frame = CGRectMake(mainScreenSwitchToLeft, iPhone4ScreenHight - mainScreenSwitchToBottom_480 - mainScreenSwitchHeight , mainScreenSwitchWidth, mainScreenSwitchHeight);
    else
        self.view.frame = CGRectMake(mainScreenSwitchToLeft, iPhone5ScreenHight - mainScreenSwitchToBottom_568 - mainScreenSwitchHeight, mainScreenSwitchWidth, mainScreenSwitchHeight);

    self.switchView = [self createSwitchView];
    [self.view addSubview: self.switchView];
    
    //switch label
    [self.leftLabel removeFromSuperview];
    [self.rightLabel removeFromSuperview];
    
    [self.leftLabel hp_tuneForSwitchIsOn];
    [self.rightLabel hp_tuneForSwitchIsOff];
    
    [self.view addSubview: self.leftLabel];
    [self.view addSubview: self.rightLabel];
}

//==============================================================================

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addGesture];
}

//==============================================================================

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeGesture];
}

//==============================================================================

- (UIView*) createSwitchView
{
    UIImage *imgC = [[UIImage imageNamed: @"Switcher-C"] resizableImageWithCapInsets: UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *imgL= [UIImage imageNamed: @"Switcher-L"];
    UIImage *imgR= [UIImage imageNamed: @"Switcher-R"];

    UIImageView *viewLeft = [[UIImageView alloc] initWithImage: imgL];
    viewLeft.frame = CGRectMake(0, 0, viewLeft.frame.size.width / 2.0, viewLeft.frame.size.height / 2.0);
    UIImageView *viewRight = [[UIImageView alloc] initWithImage: imgR];
    
    UIImageView *viewCenter = [[UIImageView alloc] initWithImage: imgC];
    viewCenter.frame = CGRectMake(viewLeft.frame.size.width, 0, 56, viewCenter.frame.size.height / 2.0);
    viewRight.frame = CGRectMake(viewLeft.frame.size.width + viewCenter.frame.size.width,
                                 0,
                                 viewRight.frame.size.width / 2.0,
                                 viewCenter.frame.size.height);
    
    CGRect rect = CGRectMake(0,
                             0,
                             viewLeft.frame.size.width + viewCenter.frame.size.width + viewRight.frame.size.width,
                             viewCenter.frame.size.height);
    UIView* notView = [[UIView alloc] initWithFrame: rect];
    notView.backgroundColor = [UIColor clearColor];
    [notView addSubview: viewLeft];
    [notView addSubview: viewCenter];
    [notView addSubview: viewRight];

    rect = notView.frame;
    rect.origin.x = 2;
    rect.origin.y = 2;
    notView.frame = rect;
     
    return notView;
    
}

//==============================================================================

- (void) addGesture
{
    if(self.tapGesture == nil)
    {
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        self.swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
        self.tapGesture.cancelsTouchesInView = NO;
        self.swipeGesture.cancelsTouchesInView = NO;
        self.tapGesture.numberOfTouchesRequired = 1;
        self.swipeGesture.direction  = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
        self.swipeGesture.numberOfTouchesRequired = 1;
        [self.tapGesture setDelegate:self];
        [self.swipeGesture setDelegate:self];
        [[self view] addGestureRecognizer:self.tapGesture];
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

- (void) moveSwitchToRight {
    CGRect newFrame;
    if([Utils screenPhysicalSize] == SCREEN_SIZE_IPHONE_CLASSIC) {
        newFrame = CGRectMake(2 + 102, 2 , mainScreenSwitchWidth, mainScreenSwitchHeight);
    } else {
        newFrame = CGRectMake(2 + 102, 2, mainScreenSwitchWidth, mainScreenSwitchHeight);
    }
    self.rightLabel.textColor = [UIColor colorWithRed:80.0/255.0 green:226.0/255.0 blue:193.0/255.0 alpha:0.4];
    self.leftLabel.textColor = [UIColor colorWithRed:80.0/255.0 green:226.0/255.0 blue:193.0/255.0 alpha:1.0];
    CGRect offSetRect=CGRectOffset(newFrame, 0.0f, 0.0f);
    [UIView animateWithDuration:0.4 animations:^{
     self.switchView.frame=offSetRect;
     }
     completion:^(BOOL finished){
         self.rightLabel.textColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:48.0/255.0 alpha:0.4];
         
     }];
}

//==============================================================================

- (void) moveSwitchToLeft {
    CGRect newFrame;
    if([Utils screenPhysicalSize] == SCREEN_SIZE_IPHONE_CLASSIC) {
        newFrame = CGRectMake(2, 2 , mainScreenSwitchWidth, mainScreenSwitchHeight);
    } else {
        newFrame = CGRectMake(2, 2, mainScreenSwitchWidth, mainScreenSwitchHeight);
    }
    self.leftLabel.textColor = [UIColor colorWithRed:80.0/255.0 green:226.0/255.0 blue:193.0/255.0 alpha:0.4];
    self.rightLabel.textColor = [UIColor colorWithRed:80.0/255.0 green:226.0/255.0 blue:193.0/255.0 alpha:1.0];
    CGRect offSetRect=CGRectOffset(newFrame, 0.0f, 0.0f);
    [UIView animateWithDuration:0.4 animations:^{
        self.switchView.frame=offSetRect;
    }
                     completion:^(BOOL finished){
                         self.leftLabel.textColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:48.0/255.0 alpha:0.4];
                         
                     }];

}

//==============================================================================

@end
