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
#import "Avatar.h"
#import "DataStorage.h"
#import "HPRoundedShadowedImageView.h"
#import "UIImageView+AFNetworking.h"
#import "User+UserImage.h"

#define AVATAR_BLUR_RADIUS 10.0

@interface HPUserCardUICollectionViewCell()
@property (weak, nonatomic) IBOutlet HPRoundedShadowedImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendMsgBtn;
@property (weak, nonatomic) IBOutlet UIButton *heartBtn;
@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *photoCountLabel;
@property (retain, nonatomic) User* currUser;
@end

@implementation HPUserCardUICollectionViewCell

- (void)awakeFromNib{
    [super awakeFromNib];
    RAC(self.heartBtn,selected) = [RACObserve(self, currUser.point.pointLiked) map:^id(id value) {
        if(value==nil)
            return @NO;
        else
            return value;
    }];
}

- (void) bindViewModel: (User *) user {
    for(UIView *subview in [self subviews]) {
        if([subview isKindOfClass:[UITextView class]]) {
            [subview removeFromSuperview];
        }
    }
    self.currUser = user;
    
    UITextView *pointTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, 300, 40)];
    pointTextView.textAlignment=NSTextAlignmentCenter;
    pointTextView.backgroundColor = [UIColor clearColor];
    pointTextView.userInteractionEnabled = NO;
    pointTextView.text = user.point.pointText;    
    [pointTextView hp_tuneForUserPoint];
    [self.sendMsgBtn hp_tuneFontForGreenButton];
    self.photoView.clipsToBounds = YES;
    self.photoView.layer.cornerRadius = 2;
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
    frame.origin.y = self.frame.size.height - 115 - pointTVSize.height;
    [pointTextView setFrame:frame];
    self.avatarImageView.image = [UIImage imageNamed:@"img_sample1.png"];
    NSString *cityName = user.city.cityName ? user.city.cityName : NSLocalizedString(@"UNKNOWN_CITY_ID", nil);
    self.userInfoLabel.text = [NSString stringWithFormat:@"%@, %@ лет, %@", user.name, user.age, cityName];
    
    UIColor *onlineUserNameColor = [UIColor colorWithRed: 64.0 / 255.0
                                                   green: 199.0 / 255.0
                                                    blue: 79.0 / 255.0
                                                   alpha: 1.0];
    
    UIColor *offlineUserNameColor = [UIColor colorWithRed: 255.0 / 255.0
                                                    green: 153.0 / 255.0
                                                     blue: 0.0 / 255.0
                                                    alpha: 1.0];
    NSMutableAttributedString *text =
    [[NSMutableAttributedString alloc]
     initWithAttributedString: self.userInfoLabel.attributedText];
    
    if ([_currUser.online boolValue]) {
        [text addAttribute:NSForegroundColorAttributeName
                     value:onlineUserNameColor
                     range:NSMakeRange(0, user.name.length)];
    } else {
        [text addAttribute:NSForegroundColorAttributeName
                     value:offlineUserNameColor
                     range:NSMakeRange(0, user.name.length)];
    }
    [self.userInfoLabel setAttributedText: text];
    [self loadAvatar:user];
    [self addSubview:pointTextView];
    [self setAvatarVisibilityBlur:user];
    [self setPrivacyText:user];
    if ([_currUser.gender isEqualToNumber:@1]) {
        [self.sendMsgBtn setTitle:NSLocalizedString(@"SEND_MSG_HIM", nil) forState:UIControlStateNormal];
        [self.sendMsgBtn setTitle:NSLocalizedString(@"SEND_MSG_HIM", nil) forState:UIControlStateHighlighted];
    } else {
        [self.sendMsgBtn setTitle:NSLocalizedString(@"SEND_MSG_HER", nil) forState:UIControlStateNormal];
        [self.sendMsgBtn setTitle:NSLocalizedString(@"SEND_MSG_HER", nil) forState:UIControlStateHighlighted];
    }
}


#pragma mark - avatar

- (void) loadAvatar : (User *) user {
    @weakify(self);
    [user.userImageSignal subscribeNext:^(UIImage* x) {
        @strongify(self);
        self.avatarImageView.image = x;
    }];
}

#pragma mark - privacy

- (void) setAvatarVisibilityBlur :(User *) user {
    if (([user.visibility intValue] == UserVisibilityBlur) || ([user.visibility intValue] == UserVisibilityHidden)) {
        self.avatarImageView.image = [self.avatarImageView.image hp_imageWithGaussianBlur: AVATAR_BLUR_RADIUS];
    }
}

- (void) setPrivacyText :(User *) user {
    if ([user.visibility intValue] == UserVisibilityBlur) {
        if ([user.gender intValue] == UserGenderMale) {
            self.userInfoLabel.text = NSLocalizedString(@"HIDE_HIS_PROFILE_INFO", nil);
        } else {
            self.userInfoLabel.text = NSLocalizedString(@"HIDE_HER_PROFILE_INFO", nil);
        }
    }
    if ([user.visibility intValue] == UserVisibilityHidden) {
        if ([user.gender intValue] == UserGenderMale) {
            self.userInfoLabel.text = NSLocalizedString(@"HIDE_HER_NAME_INFO", nil);
        } else {
            self.userInfoLabel.text = NSLocalizedString(@"HIDE_HIS_NAME_INFO", nil);
        }
    }
}


- (IBAction)sendMsgBtnTap:(id)sender {
    if ([self.delegate respondsToSelector:@selector(openChatControllerWithUser:)]) {
        [self.delegate openChatControllerWithUser:_currUser];
    }
}

- (IBAction)heartBtnTap:(id)sender {
    NSLog(@"current point prev = %d", [_currUser.point.pointLiked boolValue]);
    if ([_currUser.point.pointLiked boolValue]) {
        //unlike request
        [[DataStorage sharedDataStorage] setAndSavePointLiked: self.currUser.point.pointId isLiked:NO withComplationBlock:^(id object) {
            if (object) {
                [[HPBaseNetworkManager sharedNetworkManager] makePointUnLikeRequest:_currUser.point.pointId];
            }
            else {
                //TODO : error msg
            }
        }];
    } else {
        //like request        
        [[DataStorage sharedDataStorage] setAndSavePointLiked: self.currUser.point.pointId isLiked:YES withComplationBlock:^(id object) {
            if (object) {
                [[HPBaseNetworkManager sharedNetworkManager] makePointLikeRequest:_currUser.point.pointId];
            }
            else {
                //TODO : error msg
            }
        }];
    }
}

#pragma mark - textview
-(CGSize) getContentSize:(UITextView*) myTextView{
    return [myTextView sizeThatFits:CGSizeMake(myTextView.frame.size.width, FLT_MAX)];
}

@end
