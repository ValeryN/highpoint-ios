//
//  HPCurrentUserUICollectionViewCell.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 04.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPCurrentUserUICollectionViewCell.h"
#import "UILabel+HighPoint.h"
#import "UIImage+HighPoint.h"

#define AVATAR_BLUR_RADIUS 10.0

@interface HPCurrentUserUICollectionViewCell()
@property (weak, nonatomic) IBOutlet UILabel *yourProfilelabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *visibleBtn;
@property (weak, nonatomic) IBOutlet UIButton *lockBtn;
@property (weak, nonatomic) IBOutlet UIButton *invisibleBtn;
@property (weak, nonatomic) IBOutlet UILabel *visibilityInfoLabel;
@end

@implementation HPCurrentUserUICollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    [self configureMainView];
    [self configureCellInfoLabel];
    [self configureYourNameLabel];
    [self configureProfileVisibilityLabel];
    [self configureVisibleButton];
    [self configureBlurButton];
    [self configureHiddenButton];
}

- (void)configureHiddenButton {

}

- (void)configureBlurButton {

}

- (void)configureVisibleButton {

}

- (void)configureProfileVisibilityLabel {

}

- (void)configureYourNameLabel {
    RAC(self.userInfoLabel,text) = [RACObserve(self, currentUser) map:^id(User* user) {
        NSString *cityName = user.city.cityName ? user.city.cityName : NSLocalizedString(@"UNKNOWN_CITY_ID", nil);
        return [NSString stringWithFormat:@"%@, %@ лет, %@", user.name, user.age, cityName];
    }];
}

- (void)configureCellInfoLabel {

}

- (void)configureMainView {

}

//Trash
- (void) configureCell : (User *) user {
//    self.yourProfilelabel.text = NSLocalizedString(@"YOUR_PROFILE", nil);
//    [self.yourProfilelabel hp_tuneForUserCardName];
//    self.avatarImageView.clipsToBounds = YES;
//    self.avatarImageView.layer.cornerRadius = 5;
//    [self.userInfoLabel hp_tuneForUserCardName];
//
//    [self setAvatarVisibilityBlur:user];
//    [self setVisibility:user.visibility];
}

- (void) setAvatarVisibilityBlur :(User *) user {
    if (([user.visibility intValue] == UserVisibilityBlur) || ([user.visibility intValue] == UserVisibilityHidden)) {
        self.avatarImageView.image = [self.avatarImageView.image hp_imageWithGaussianBlur: AVATAR_BLUR_RADIUS];
    }
}

- (void) setVisibility : (NSNumber *) visibility {
    if ([visibility isEqualToNumber:@(UserVisibilityVisible)]) {
        self.visibleBtn.selected = YES;
        self.invisibleBtn.selected = NO;
        self.lockBtn.selected = NO;
        self.visibilityInfoLabel.hidden = NO;
        self.visibilityInfoLabel.hidden = YES;
    }
    if ([visibility isEqualToNumber:@(UserVisibilityBlur)]) {
        self.visibleBtn.selected = NO;
        self.invisibleBtn.selected = YES;
        self.lockBtn.selected = NO;
        self.visibilityInfoLabel.hidden = NO;
        [self.visibilityInfoLabel hp_tuneForUserVisibilityInfo];
        self.visibilityInfoLabel.text = NSLocalizedString(@"VISIBILITY_INFO_LABEL", nil);
        self.userInfoLabel.text = NSLocalizedString(@"YOUR_PROFILE_INVISIBLE", nil);
        
    }
    if ([visibility isEqualToNumber:@(UserVisibilityHidden)]) {
        self.visibleBtn.selected = NO;
        self.invisibleBtn.selected = NO;
        self.lockBtn.selected = YES;
        self.visibilityInfoLabel.hidden = NO;
        [self.visibilityInfoLabel hp_tuneForUserVisibilityInfo];
        self.visibilityInfoLabel.text = NSLocalizedString(@"VISIBILITY_INFO_LABEL", nil);
        self.userInfoLabel.text = NSLocalizedString(@"YOUR_PROFILE_LOCKED", nil);
    }
}


@end
