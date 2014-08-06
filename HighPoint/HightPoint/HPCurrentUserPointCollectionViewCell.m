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


#define POINT_LENGTH 150


@implementation HPCurrentUserPointCollectionViewCell

- (void) configureCell {
    [self.pointSettingsView setHidden:YES];
    [self setImageViewBgTap];
    self.isUp = NO;
    self.yourPointLabel.text = NSLocalizedString(@"YOUR_POINT", nil);
    [self.yourPointLabel hp_tuneForUserCardName];
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 5;
    [self.pointInfoLabel hp_tuneForCurrentPointInfo];
    [self.publishBtn hp_tuneFontForGreenButton];
    self.pointTextView.delegate = self;
    self.pointTextView.text = NSLocalizedString(@"YOUR_EMPTY_POINT", nil);
    [self.pointTextView hp_tuneForUserPointEmpty];
    
    self.pointTimeInfoLabel.text = NSLocalizedString(@"SET_TIME_FOR_YOUR_POINT", nil);
    [self.pointTimeInfoLabel hp_tuneForCurrentPointInfo];
    [self.publishSettBtn hp_tuneFontForGreenButton];
}


#pragma mark - text view

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(startEditingPoint)]) {
        [self.delegate startEditingPoint];
    }
    [self editPointUp];
    [self.pointTextView hp_tuneForUserPoint];
    [self setSymbolsCounter];
}


- (void)textViewDidEndEditing:(UITextView *)textView {
//    [self editPointDown];
//    if ([self.delegate respondsToSelector:@selector(cancelPointTap)]) {
//        [self.delegate cancelPointTap];
//    }
}

-(void)textViewDidChange:(UITextView *)textView
{
    [self setSymbolsCounter];
}

#pragma mark - symbols counting

- (void) setSymbolsCounter {
    
    signed int symbCount = POINT_LENGTH - self.pointTextView.text.length;
    self.pointInfoLabel.text = [NSString stringWithFormat:@"%d", symbCount];
    if(symbCount <=10) {
        [self.pointInfoLabel hp_tuneForSymbolCounterRed];
    } else {
        [self.pointInfoLabel hp_tuneForSymbolCounterWhite];
    }
}

#pragma mark - animation
- (void) editPointUp {
    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationCurveEaseOut
                     animations:^{
                         self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - 115, self.frame.size.width, self.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         self.isUp = YES;
                     }];
}

- (void) editPointDown {
    if (self.isUp) {
        [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationCurveEaseOut
                         animations:^{
                             self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + 115, self.frame.size.width, self.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             self.isUp = NO;
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
    if ([self.delegate respondsToSelector:@selector(cancelPointTap)]) {
        [self.delegate cancelPointTap];
    }
}



- (IBAction)publishSettTap:(id)sender {
    if ([self.delegate respondsToSelector:@selector(sharePointTap)]) {
        [self.delegate sharePointTap];
    }
}


@end
