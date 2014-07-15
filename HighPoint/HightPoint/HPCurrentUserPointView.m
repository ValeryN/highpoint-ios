//
//  HPCurrentUserPointView.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 14.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPCurrentUserPointView.h"
#import "UIImage+HighPoint.h"
#import "UIView+HighPoint.h"
#import "UITextView+HightPoint.h"

#define USERPOINT_ROUND_RADIUS 5
#define AVATAR_BLUR_RADIUS 40


@implementation HPCurrentUserPointView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) initObjects
{
    [self.bgAvatarImageView hp_roundViewWithRadius: USERPOINT_ROUND_RADIUS];
    [self.pointTextView hp_tuneForUserPoint];
}

- (void) setCropedAvatar :(UIImage *)image {
    _avatar = [HPAvatarView createAvatar: image];
    [_avatarView addSubview: _avatar];
    [self fixAvatarConstraint];
}

- (void) setBlurForAvatar {
    self.bgAvatarImageView.image = [self.bgAvatarImageView.image hp_imageWithGaussianBlur: AVATAR_BLUR_RADIUS];
}



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


- (IBAction)profileBtnTap:(id)sender {
    NSLog(@"profile tap");
    if (_delegate == nil)
        return;
    [_delegate switchButtonPressed];
}


@end
