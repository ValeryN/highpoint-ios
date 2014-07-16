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
#import "UIDevice+HighPoint.h"

#define USERPOINT_ROUND_RADIUS 5
#define AVATAR_BLUR_RADIUS 40
#define POINT_LENGTH 140


#define CONSTRAINT_TOP_FOR_HEART 245
#define CONSTRAINT_TOP_FOR_NAMELABEL 286
#define CONSTRAINT_WIDTH_FOR_SELF 264
#define CONSTRAINT_WIDE_HEIGHT_FOR_SELF 416
#define CONSTRAINT_HEIGHT_FOR_SELF 340

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
    self.bgAvatarImageView.userInteractionEnabled = YES;
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
    self.bgAvatarImageView.userInteractionEnabled = NO;
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
    [self fixSelfConstraint];
    
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


#pragma mark - constraint

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
                (consIter.firstItem == self.publishPointBtn))
                consIter.constant = CONSTRAINT_TOP_FOR_NAMELABEL;
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == self.pointInfoLabel) &&
                (consIter.secondItem == self))
                consIter.constant = CONSTRAINT_TOP_FOR_HEART;
        }
    }
}


- (IBAction)profileBtnTap:(id)sender {
    NSLog(@"profile tap");
    if (_delegate == nil)
        return;
    [_delegate switchButtonPressed];
}


@end
