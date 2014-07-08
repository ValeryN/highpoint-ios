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
#import "UIImage+HighPoint.h"
#import "UITextView+HightPoint.h"

//==============================================================================

#define USERPOINT_ROUND_RADIUS 5
#define AVATAR_BLUR_RADIUS 40

#define CONSTRAINT_TOP_FOR_HEART 245
#define CONSTRAINT_TOP_FOR_NAMELABEL 286
#define CONSTRAINT_WIDTH_FOR_SELF 264
#define CONSTRAINT_WIDE_HEIGHT_FOR_SELF 416
#define CONSTRAINT_HEIGHT_FOR_SELF 340

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
    _backgroundAvatar.image = [_backgroundAvatar.image hp_imageWithGaussianBlur: AVATAR_BLUR_RADIUS];

    [_details hp_tuneForUserCardDetails];
    [_name hp_tuneForUserCardName];
    
    _avatar = [HPAvatarView createAvatar];
    [_avatarGroup addSubview: _avatar];

    [self fixAvatarConstraint];
    [self fixSelfConstraint];
    
    [_pointText hp_tuneForUserPoint];
}

//==============================================================================

- (void) fixSelfConstraint
{
    CGFloat height = CONSTRAINT_WIDE_HEIGHT_FOR_SELF;
    if (![UIDevice hp_isWideScreen])
        height = CONSTRAINT_HEIGHT_FOR_SELF;

    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem: self
                                                                 attribute: NSLayoutAttributeWidth
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: nil
                                                                 attribute: NSLayoutAttributeNotAnAttribute
                                                                multiplier: 1.0
                                                                  constant: CONSTRAINT_WIDTH_FOR_SELF]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem: self
                                                                 attribute: NSLayoutAttributeHeight
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: nil
                                                                 attribute: NSLayoutAttributeNotAnAttribute
                                                                multiplier: 1.0
                                                                  constant: height]];
    if (![UIDevice hp_isWideScreen])
    {
        NSArray* cons = self.constraints;
        for (NSLayoutConstraint* consIter in cons)
        {
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == _name))
                consIter.constant = CONSTRAINT_TOP_FOR_NAMELABEL;
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == _heartLike) &&
                (consIter.secondItem == self))
                consIter.constant = CONSTRAINT_TOP_FOR_HEART;
        }
        cons = _backgroundAvatar.constraints;
        for (NSLayoutConstraint* consIter in cons)
        {
            if (consIter.firstAttribute == NSLayoutAttributeHeight)
                consIter.constant = CONSTRAINT_HEIGHT_FOR_SELF;
        }
    }
}

//==============================================================================

- (void) fixAvatarConstraint
{
    _avatar.translatesAutoresizingMaskIntoConstraints = NO;

    [_avatar addConstraint:[NSLayoutConstraint constraintWithItem: _avatar
                                                                 attribute: NSLayoutAttributeWidth
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: nil
                                                                 attribute: NSLayoutAttributeNotAnAttribute
                                                                multiplier: 1.0
                                                                  constant: _avatar.frame.size.width]];

    [_avatar addConstraint:[NSLayoutConstraint constraintWithItem: _avatar
                                                                 attribute: NSLayoutAttributeHeight
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: nil
                                                                 attribute: NSLayoutAttributeNotAnAttribute
                                                                multiplier: 1.0
                                                                  constant: _avatar.frame.size.height]];
}

//==============================================================================

- (IBAction) pointButtonPressed: (id)sender
{
    if (_delegate == nil)
        return;
    
    [_delegate switchButtonPressed];
}

//==============================================================================

- (IBAction) heartButtonPressed: (id)sender
{
    if (_pointDelegate == nil)
        return;
    
    [_pointDelegate heartTapped];
}

@end
