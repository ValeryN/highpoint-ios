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
#define CONSTRAINT_TOP_FOR_NAMELABEL 276
#define AVATAR_BLUR_RADIUS 40
#define CONSTRAINT_TOP_FOR_AVATAR_GROUP 40

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
    _backgroundAvatar.image = [_backgroundAvatar.image hp_applyBlurWithRadius: AVATAR_BLUR_RADIUS];

    [_details hp_tuneForUserCardDetails];
    [_name hp_tuneForUserCardName];
    
    _avatar = [HPAvatarView createAvatar];
    [_avatarGroup addSubview: _avatar];
    [self fixAvatarConstraint];
    
    [_pointText hp_tuneForUserPoint];
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
    if (![UIDevice hp_isWideScreen])
    {
        NSArray* cons = _avatarGroup.constraints;
        for (NSLayoutConstraint* consIter in cons)
        {
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == self) &&
                (consIter.secondItem == _avatarGroup)
                )
                consIter.constant = CONSTRAINT_TOP_FOR_AVATAR_GROUP;
        }
    }
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
