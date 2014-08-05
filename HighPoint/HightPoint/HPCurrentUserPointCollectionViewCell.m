//
//  HPCurrentUserPointCollectionViewCell.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 05.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPCurrentUserPointCollectionViewCell.h"
#import "UILabel+HighPoint.h"
#import "UIButton+HighPoint.h"
#import "UITextView+HightPoint.h"

@implementation HPCurrentUserPointCollectionViewCell {
    BOOL isUp;
}

- (void) configureCell {
    [self setImageViewBgTap];
    isUp = NO;
    self.yourPointLabel.text = NSLocalizedString(@"YOUR_POINT", nil);
    [self.yourPointLabel hp_tuneForUserCardName];
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 5;
    [self.pointInfoLabel hp_tuneForCurrentPointInfo];
    [self.publishBtn hp_tuneFontForGreenButton];
    self.pointTextView.delegate = self;
    self.pointTextView.text = NSLocalizedString(@"YOUR_EMPTY_POINT", nil);
    [self.pointTextView hp_tuneForUserPoint];
}


#pragma mark - text view

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self editPointUp];
}


- (void)textViewDidEndEditing:(UITextView *)textView {
    [self editPointDown];
}

#pragma mark - animation
- (void) editPointUp {
    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationCurveEaseOut
                     animations:^{
                         self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - 110, self.frame.size.width, self.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         isUp = YES;
                     }];
}

- (void) editPointDown {
    if (isUp) {
        [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationCurveEaseOut
                         animations:^{
                             self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + 110, self.frame.size.width, self.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             isUp = NO;
                         }];
    }
}


#pragma mark - tap

-(void) setImageViewBgTap {
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(bgTap)];
    tgr.delegate = self;
    [self.avatarImageView addGestureRecognizer:tgr];
}

- (void) bgTap {
    [self endEditing:YES];
}

@end
