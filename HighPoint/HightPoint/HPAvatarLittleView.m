//
//  HPAvatarLittleView.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 22.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPAvatarLittleView.h"
#import "UIImage+HighPoint.h"

@implementation HPAvatarLittleView


+ (HPAvatarLittleView*) createAvatar :(UIImage *) image
{
    NSArray* nibs = [[NSBundle mainBundle] loadNibNamed: @"HPAvatarLittleView" owner: self options: nil];
    if ([nibs[0] isKindOfClass:[HPAvatarLittleView class]] == NO)
        return nil;
    
    HPAvatarLittleView* avatar = (HPAvatarLittleView*)nibs[0];
    [avatar initObjects:image];
    
    return avatar;
}


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

@end
