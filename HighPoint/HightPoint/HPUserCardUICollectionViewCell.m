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
#import "HPBaseNetworkManager+Points.h"
#import "UIImage+HighPoint.h"
#import "SDWebImageManager.h"
#import "Avatar.h"
#import "DataStorage.h"

#define AVATAR_BLUR_RADIUS 10.0

@interface HPUserCardUICollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendMsgBtn;
@property (weak, nonatomic) IBOutlet UIButton *heartBtn;
@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *photoCountLabel;
@end

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
    } else {
        self.heartBtn.hidden = YES;
        pointTextView.hidden = YES;
    }
    self.photoCountLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)[[DataStorage sharedDataStorage] getPhotoForUserId:user.userId].count];
    CGSize pointTVSize = [self getContentSize:pointTextView];
    CGRect frame = pointTextView.frame;
    frame.size.height = pointTVSize.height;
    frame.origin.y = self.frame.size.height - 120 - pointTVSize.height;
    [pointTextView setFrame:frame];
    self.avatarImageView.image = [UIImage imageNamed:@"img_sample1.png"];
    NSString *cityName = user.city.cityName ? user.city.cityName : NSLocalizedString(@"UNKNOWN_CITY_ID", nil);
    self.userInfoLabel.text = [NSString stringWithFormat:@"%@, %@ лет, %@", user.name, user.age, cityName];
    [self loadAvatar:user];
    [self addSubview:pointTextView];
    [self.heartBtn setSelected:[user.point.pointLiked boolValue]];
    [self setAvatarVisibilityBlur:user];
    [self setPrivacyText:user];
    if ([currUser.gender isEqualToNumber:@1]) {
        [self.sendMsgBtn setTitle:NSLocalizedString(@"SEND_MSG_HIM", nil) forState:UIControlStateNormal];
        [self.sendMsgBtn setTitle:NSLocalizedString(@"SEND_MSG_HIM", nil) forState:UIControlStateHighlighted];
    } else {
        [self.sendMsgBtn setTitle:NSLocalizedString(@"SEND_MSG_HER", nil) forState:UIControlStateNormal];
        [self.sendMsgBtn setTitle:NSLocalizedString(@"SEND_MSG_HER", nil) forState:UIControlStateHighlighted];
    }
}


#pragma mark - avatar

- (void) loadAvatar : (User *) user {
    NSString* avatarUrl = user.avatar.originalImgSrc;
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadWithURL:[NSURL URLWithString:avatarUrl]
                     options:0
                    progress:^(NSInteger receivedSize, NSInteger expectedSize)
     {
         // progression tracking code
     }
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
     {
         if (image)
         {
             self.avatarImageView.image = image;
         }
     }];
}

#pragma mark - privacy

- (void) setAvatarVisibilityBlur :(User *) user {
    if (([user.visibility intValue] == 2) || ([user.visibility intValue] == 3)) {
        self.avatarImageView.image = [self.avatarImageView.image hp_imageWithGaussianBlur: AVATAR_BLUR_RADIUS];
    }
}

- (void) setPrivacyText :(User *) user {
    if ([user.visibility intValue] == 2) {
        if ([user.gender intValue] == 1) {
            self.userInfoLabel.text = NSLocalizedString(@"HIDE_HIS_PROFILE_INFO", nil);
        } else {
            self.userInfoLabel.text = NSLocalizedString(@"HIDE_HER_PROFILE_INFO", nil);
        }
    }
    if ([user.visibility intValue] == 3) {
        if ([user.gender intValue] == 1) {
            self.userInfoLabel.text = NSLocalizedString(@"HIDE_HER_NAME_INFO", nil);
        } else {
            self.userInfoLabel.text = NSLocalizedString(@"HIDE_HIS_NAME_INFO", nil);
        }
    }
}


- (IBAction)sendMsgBtnTap:(id)sender {
    if ([self.delegate respondsToSelector:@selector(openChatControllerWithUser:)]) {
        [self.delegate openChatControllerWithUser:self.tag];
    }
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

#pragma mark - textview
-(CGSize) getContentSize:(UITextView*) myTextView{
    return [myTextView sizeThatFits:CGSizeMake(myTextView.frame.size.width, FLT_MAX)];
}

@end
