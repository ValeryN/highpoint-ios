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

+ (HPAvatarView*) createAvatar :(UIImage *) image
{
    NSArray* nibs = [[NSBundle mainBundle] loadNibNamed: @"HPAvatarView" owner: self options: nil];
    if ([nibs[0] isKindOfClass:[HPAvatarView class]] == NO)
        return nil;
    
    HPAvatarView* avatar = (HPAvatarView*)nibs[0];
    [avatar initObjects:image];
    
    return avatar;
}

//==============================================================================

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    if (self == nil)
        return nil;
    
    [self initObjects:nil];
    
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initObjects: nil];
    }
    return self;
}


- (void) initObjects : (UIImage *) image
{
    UIImage* userAvatar = image;
    UIImage* userAvatarWithMask = [userAvatar hp_maskImageWithPattern: [UIImage imageNamed: @"Userpic Mask"]];
    _avatar.image = userAvatarWithMask;
}

#pragma mark - online

- (void) makeOnline
{
    _avatarBorder.image = [UIImage imageNamed: @"Userpic Shape Green"];
}

- (void) makeOffline
{
    _avatarBorder.image = [UIImage imageNamed: @"Userpic Shape Red"];
}

#pragma mark - privacy

- (void) privacyLevel
{
    [self blurUserImage:nil];
}

- (void) blurUserImage :(UIImage *) image
{
    UIImage* userAvatar = image;
    userAvatar = [userAvatar hp_imageWithGaussianBlur: 10];
    UIImage* userAvatarWithMask = [userAvatar hp_maskImageWithPattern: [UIImage imageNamed: @"Userpic Mask"]];
    _avatar.image = userAvatarWithMask;
}



@end
