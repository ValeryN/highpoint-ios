//
//  HPUserProfileViewController.m
//  HighPoint
//
//  Created by Andrey Anisimov on 27.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "HPUserProfileViewController.h"
#import "Utils.h"
#import "UIDevice+HighPoint.h"

//==============================================================================

#define GREEN_BUTTON_BOTTOM 20

//==============================================================================

@implementation HPUserProfileViewController

//==============================================================================

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createGreenButton];
}

//==============================================================================

- (void) createGreenButton
{
    HPGreenButtonVC* sendMessage = [[HPGreenButtonVC alloc] initWithNibName: @"HPGreenButtonVC" bundle: nil];
    sendMessage.view.translatesAutoresizingMaskIntoConstraints = NO;
    sendMessage.delegate = self;

    CGRect rect = sendMessage.view.frame;
    CGRect bounds = [UIScreen mainScreen].bounds;
    rect.origin.x = (bounds.size.width - rect.size.width) / 2.0f;
    rect.origin.y = bounds.size.height - rect.size.height - GREEN_BUTTON_BOTTOM;
    sendMessage.view.frame = rect;

    [self addChildViewController: sendMessage];
    [self.view addSubview: sendMessage.view];

    [self createGreenButtonsConstraint: sendMessage];
}

//==============================================================================

- (void) createGreenButtonsConstraint: (HPGreenButtonVC*) sendMessage
{
    [sendMessage.view addConstraint:[NSLayoutConstraint constraintWithItem: sendMessage.view
                                                                 attribute: NSLayoutAttributeWidth
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: nil
                                                                 attribute: NSLayoutAttributeNotAnAttribute
                                                                multiplier: 1.0
                                                                  constant: sendMessage.view.frame.size.width]];

    [sendMessage.view addConstraint:[NSLayoutConstraint constraintWithItem: sendMessage.view
                                                                 attribute: NSLayoutAttributeHeight
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: nil
                                                                 attribute: NSLayoutAttributeNotAnAttribute
                                                                multiplier: 1.0
                                                                  constant: sendMessage.view.frame.size.height]];
//
//    NSArray* cons = self.view.constraints;
//    for (NSLayoutConstraint* consIter in cons)
//    {
//        if ((consIter.firstAttribute == NSLayoutAttributeBottom) &&
//            (consIter.firstItem == self.view) &&
//            (consIter.secondItem == _infoButton))
//            {
//               [self.view addConstraint:[NSLayoutConstraint constraintWithItem: self.view
//                                                                     attribute: NSLayoutAttributeBottom
//                                                                     relatedBy: NSLayoutRelationEqual
//                                                                        toItem: sendMessage.view
//                                                                     attribute: NSLayoutAttributeBottom
//                                                                    multiplier: 1.0
//                                                                      constant: consIter.constant]];
//            }
//    }
}

//==============================================================================

- (void) greenButtonPressed: (HPGreenButtonVC*) button
{
    NSLog(@"Green button pressed");
}

//==============================================================================

@end
