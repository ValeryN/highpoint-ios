//
//  HPAvatar.m
//  HighPoint
//
//  Created by Michael on 26.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "HPAvatarView.h"
#import "UIImage+HighPoint.h"

//==============================================================================

@implementation HPAvatarView

//==============================================================================

+ (HPAvatarView*) createAvatar
{
    NSArray* nibs = [[NSBundle mainBundle] loadNibNamed: @"HPAvatarView" owner: self options: nil];
    if ([nibs[0] isKindOfClass:[HPAvatarView class]] == NO)
        return nil;
    
    HPAvatarView* avatar = (HPAvatarView*)nibs[0];
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
    userAvatar = [userAvatar hp_imageWithGaussianBlur: 10];
    UIImage* userAvatarWithMask = [userAvatar hp_maskImageWithPattern: [UIImage imageNamed: @"Userpic Mask"]];
    _avatar.image = userAvatarWithMask;
}

//==============================================================================

@end
