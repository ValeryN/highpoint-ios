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
#import "HPBaseNetworkManager.h"

@implementation HPUserCardUICollectionViewCell {
    User *currUser;
}


- (void) configureCell : (User *) user {
    currUser = user;
    [self.pointTextView hp_tuneForUserPoint];
    [self.userInfoLabel hp_tuneForUserCardName];
    [self.sendMsgBtn hp_tuneFontForGreenButton];
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 5;
    self.photoView.clipsToBounds = YES;
    self.photoView.layer.cornerRadius = 3;
    [self.photoCountLabel hp_tuneForUserCardPhotoIndex];
    if (user.point) {
        self.heartBtn.hidden = NO;
        self.pointTextView.hidden = NO;
    } else {
        self.heartBtn.hidden = YES;
        self.pointTextView.hidden = YES;
    }
    self.pointTextView.text = user.point.pointText;
    NSString *cityName = user.city.cityName ? user.city.cityName : NSLocalizedString(@"UNKNOWN_CITY_ID", nil);
    self.userInfoLabel.text = [NSString stringWithFormat:@"%@, %@ лет, %@", user.name, user.age, cityName];
    [self.heartBtn setSelected:[user.point.pointLiked boolValue]];
}


- (IBAction)sendMsgBtnTap:(id)sender {
    NSLog(@"send msg btn tap");
}

- (IBAction)heartBtnTap:(id)sender {
       if ([currUser.point.pointLiked boolValue]) {
        //unlike request
           [[HPBaseNetworkManager sharedNetworkManager] makePointUnLikeRequest:currUser.point.pointId];
       } else {
        //like request
          [[HPBaseNetworkManager sharedNetworkManager] makePointLikeRequest:currUser.point.pointId];
     }
}

- (IBAction)pointBtnTap:(id)sender {
    NSLog(@"point btn tap");
}

@end
