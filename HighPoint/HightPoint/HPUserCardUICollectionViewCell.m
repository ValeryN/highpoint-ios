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
    for(UIView *subview in [self subviews]) {
        if([subview isKindOfClass:[UITextView class]]) {
            [subview removeFromSuperview];
        }
    }
    UITextView *pointTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, 300, 40)];
    pointTextView.textAlignment=NSTextAlignmentCenter;
    pointTextView.backgroundColor = [UIColor clearColor];
    pointTextView.userInteractionEnabled = NO;
    pointTextView.text = user.point.pointText;
    currUser = user;
    [pointTextView hp_tuneForUserPoint];
    [self.userInfoLabel hp_tuneForUserCardName];
    [self.sendMsgBtn hp_tuneFontForGreenButton];
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 5;
    self.photoView.clipsToBounds = YES;
    self.photoView.layer.cornerRadius = 3;
    [self.photoCountLabel hp_tuneForUserCardPhotoIndex];
    if (user.point) {
        self.heartBtn.hidden = NO;
        pointTextView.hidden = NO;
        self.pointBtn.hidden = NO;
    } else {
        self.heartBtn.hidden = YES;
        pointTextView.hidden = YES;
        self.pointBtn.hidden = YES;
    }
    CGSize pointTVSize = [self getContentSize:pointTextView];
    CGRect frame = pointTextView.frame;
    frame.size.height = pointTVSize.height;
    frame.origin.y = self.frame.size.height - 120 - pointTVSize.height;
    [pointTextView setFrame:frame];
    NSString *cityName = user.city.cityName ? user.city.cityName : NSLocalizedString(@"UNKNOWN_CITY_ID", nil);
    self.userInfoLabel.text = [NSString stringWithFormat:@"%@, %@ лет, %@", user.name, user.age, cityName];
    [self addSubview:pointTextView];
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

#pragma mark - textview
-(CGSize) getContentSize:(UITextView*) myTextView{
    return [myTextView sizeThatFits:CGSizeMake(myTextView.frame.size.width, FLT_MAX)];
}

@end
