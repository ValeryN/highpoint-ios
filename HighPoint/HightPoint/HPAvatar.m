//
//  HPAvatar.m
//  HighPoint
//
//  Created by Michael on 26.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "HPAvatar.h"
#import "UIImage+HighPoint.h"

//==============================================================================

@implementation HPAvatar

//==============================================================================

+ (HPAvatar*) createAvatar
{
    NSArray* nibs = [[NSBundle mainBundle] loadNibNamed: @"HPAvatar" owner: self options: nil];
    if ([nibs[0] isKindOfClass:[HPAvatar class]] == NO)
        return nil;
    
    HPAvatar* avatar = (HPAvatar*)nibs[0];
    [avatar initObjects];
    
    return avatar;
}

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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initObjects];
    }
    return self;
}

//==============================================================================

- (void) initObjects
{
    UIImage* userAvatar = [UIImage imageNamed: @"img_sample1"];
    UIImage* userAvatarWithMask = [userAvatar hp_maskImageWithPattern: [UIImage imageNamed: @"Userpic Mask"]];
    _avatar.image = userAvatarWithMask;
}

//==============================================================================

- (void) makeOnline
{
    _avatarBorder.image = [UIImage imageNamed: @"Userpic Shape Green"];
}

//==============================================================================

- (void) makeOffline
{
    _avatarBorder.image = [UIImage imageNamed: @"Userpic Shape Red"];
}

//==============================================================================

- (void) privacyLevel
{
    [self blurUserImage];
}

//==============================================================================

- (void) blurUserImage
{
    UIImage* userAvatar = [UIImage imageNamed: @"img_sample1"];
    userAvatar = [userAvatar hp_applyBlurWithRadius: 5.0];
    UIImage* userAvatarWithMask = [userAvatar hp_maskImageWithPattern: [UIImage imageNamed: @"Userpic Mask"]];
    _avatar.image = userAvatarWithMask;
}

//==============================================================================

@end
