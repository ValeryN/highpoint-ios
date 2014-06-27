//
//  HPUserPointVC.m
//  HighPoint
//
//  Created by Michael on 23.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "HPUserPointView.h"
#import "UIView+HighPoint.h"
#import "UILabel+HighPoint.h"
#import "UIDevice+HighPoint.h"

//==============================================================================

#define USERPOINT_ROUND_RADIUS 5
#define CONSTRAINT_TOP_FOR_NAMELABEL 276

//==============================================================================

@implementation HPUserPointView

//==============================================================================

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    
    if (self == nil)
        return nil;

    [self initObjects];
    
    return self;
}

//==============================================================================

- (void) initObjects
{
    [_backgroundAvatar hp_roundViewWithRadius: USERPOINT_ROUND_RADIUS];

    [_details hp_tuneForUserCardDetails];
    [_name hp_tuneForUserCardName];
    _avatar = [HPAvatarView createAvatar];
    [self addSubview: _avatar];
    
    [self fixUserCardConstraint];
}

//==============================================================================

- (void) fixUserCardConstraint
{
//   [self addConstraint:[NSLayoutConstraint constraintWithItem: self
//                                                         attribute: NSLayoutAttributeBottom
//                                                         relatedBy: NSLayoutRelationEqual
//                                                            toItem: _avatar
//                                                         attribute: NSLayoutAttributeBottom
//                                                        multiplier: 1.0
//                                                          constant: CONSTRAINT_TOP_LEFT_FOR_AVATAR]];
//   [self addConstraint:[NSLayoutConstraint constraintWithItem: self
//                                                         attribute: NSLayoutAttributeBottom
//                                                         relatedBy: NSLayoutRelationEqual
//                                                            toItem: _avatar
//                                                         attribute: NSLayoutAttributeBottom
//                                                        multiplier: 1.0
//                                                          constant: CONSTRAINT_TOP_LEFT_FOR_AVATAR]];
}

//==============================================================================

- (IBAction) pointButtonPressed: (id)sender
{
    if (_delegate == nil)
        return;
    
    [_delegate switchButtonPressed];
}

//==============================================================================

@end
