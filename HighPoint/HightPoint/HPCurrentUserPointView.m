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
#import "UILabel+HighPoint.h"

#define USERPOINT_ROUND_RADIUS 5
#define AVATAR_BLUR_RADIUS 40
#define POINT_LENGTH 140


@implementation HPCurrentUserPointView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
    return self;
}


#pragma mark - image view tap

-(void) setImageViewBgTap {
    self.bgAvatarImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]
                                     initWithTarget:self action:@selector(handlePinch:)];
    tgr.delegate = self;
    [self.bgAvatarImageView addGestureRecognizer:tgr];
}


- (void)handlePinch:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    [self endEditing:YES];
    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationCurveEaseOut
            animations:^{
                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + 110, self.frame.size.width, self.frame.size.height);
            }
            completion:^(BOOL finished){
            }];
}

#pragma mark - textview editing
- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.pointInfoLabel.hidden = NO;
    [self setSymbolsCounter];
    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationCurveEaseOut
           animations:^{
               self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - 110, self.frame.size.width, self.frame.size.height);
           }
            completion:^(BOOL finished){
            }];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.pointInfoLabel.hidden = YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    [self setSymbolsCounter];
    return YES;
}

#pragma mark - symbols counter

- (void) setSymbolsCounter {
    
    signed int symbCount = POINT_LENGTH - self.pointTextView.text.length;
    self.pointInfoLabel.text = [NSString stringWithFormat:@"%d", symbCount];
    if(symbCount <=10) {
        [self.pointInfoLabel hp_tuneForSymbolCounterRed];
    } else {
        [self.pointInfoLabel hp_tuneForSymbolCounterWhite];
    }
}

#pragma mark - init objects

- (void) initObjects
{
    [self setImageViewBgTap];
    [self.bgAvatarImageView hp_roundViewWithRadius: USERPOINT_ROUND_RADIUS];
    [self.pointTextView hp_tuneForUserPoint];
    
    self.pointTextView.delegate = self;
    [self setPointText];
    
}

- (void) setPointText {
    self.pointTextView.text = NSLocalizedString(@"EMPTY_POINT_TEXT", nil);
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
