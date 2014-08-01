//
//  HPUserCardUICollectionViewCell.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 01.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPUserCardUICollectionViewCell.h"
#import "UITextView+HightPoint.h"
#import "UILabel+HighPoint.h"
#import "UIButton+HighPoint.h"
#import <QuartzCore/QuartzCore.h>

@implementation HPUserCardUICollectionViewCell


- (void) configureCell : (User *) user {
    [self.pointTextView hp_tuneForUserPoint];
    [self.userInfoLabel hp_tuneForUserCardName];
    [self.sendMsgBtn hp_tuneFontForGreenButton];
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 5;
    self.pointTextView.text = user.point.pointText;
    NSString *cityName = user.city.cityName ? user.city.cityName : NSLocalizedString(@"UNKNOWN_CITY_ID", nil);
    self.userInfoLabel.text = [NSString stringWithFormat:@"%@, %@ лет, %@", user.name, user.age, cityName];
}


- (IBAction)sendMsgBtnTap:(id)sender {
    NSLog(@"send msg btn tap");
}

- (IBAction)heartBtnTap:(id)sender {
    NSLog(@"heart btn tap");
}

- (IBAction)pointBtnTap:(id)sender {
    NSLog(@"point btn tap");
}

@end
