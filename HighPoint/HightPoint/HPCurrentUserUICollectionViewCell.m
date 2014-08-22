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
#import "UIDevice+HighPoint.h"
#import "SDWebImageManager.h"
#import "Avatar.h"
#import "UserPoint.h"

#define AVATAR_BLUR_RADIUS 10.0

@interface HPCurrentUserUICollectionViewCell ()
@property(weak, nonatomic) IBOutlet UILabel *yourProfilelabel;
@property(weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property(weak, nonatomic) IBOutlet UILabel *userInfoLabel;
@property(weak, nonatomic) IBOutlet UIButton *visibleBtn;
@property(weak, nonatomic) IBOutlet UIButton *lockBtn;
@property(weak, nonatomic) IBOutlet UIButton *invisibleBtn;
@property(weak, nonatomic) IBOutlet UILabel *visibilityInfoLabel;

@property(nonatomic, strong) IBOutletCollection(NSLayoutConstraint) NSArray *constraintFor4inch;
@property(nonatomic, weak) IBOutlet NSLayoutConstraint *bottomPositionNameConstraint;

@property(nonatomic, retain) RACSignal *userAvatarSignal;
@end

@implementation HPCurrentUserUICollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self remove4InchConstraint];

    [self configureCellInfoLabel];
    [self configureYourNameLabel];
    [self configureProfileVisibilityLabel];
    [self configureVisibleButton];
    [self configureBlurButton];
    [self configureHiddenButton];
    [self configureAvatarImageView];
}

#pragma mark - constraint

- (void)remove4InchConstraint {
    if (![UIDevice hp_isWideScreen]) {
        for (NSLayoutConstraint *constraint in self.constraintFor4inch) {
            constraint.priority = 1;
        }
    }
}

#pragma mark Configuring UIElements

- (void)configureHiddenButton {
    RAC(self, invisibleBtn.enabled) = [RACObserve(self, currentUser.visibility) map:^id(NSNumber *visibility) {
        return @(visibility.unsignedIntegerValue != UserVisibilityHidden);
    }];

    @weakify(self);
    [[self.invisibleBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.delegate updateUserVisibility:UserVisibilityHidden forUser:self.currentUser];
    }];
}

- (void)configureBlurButton {
    RAC(self, lockBtn.enabled) = [RACObserve(self, currentUser.visibility) map:^id(NSNumber *visibility) {
        return @(visibility.unsignedIntegerValue != UserVisibilityBlur);
    }];

    @weakify(self);
    [[self.lockBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.delegate updateUserVisibility:UserVisibilityBlur forUser:self.currentUser];
    }];
}

- (void)configureVisibleButton {
    RAC(self, visibleBtn.enabled) = [RACObserve(self, currentUser.visibility) map:^id(NSNumber *visibility) {
        return @(visibility.unsignedIntegerValue != UserVisibilityVisible);
    }];

    @weakify(self);
    [[self.visibleBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.delegate updateUserVisibility:UserVisibilityVisible forUser:self.currentUser];
    }];
}

- (void)configureProfileVisibilityLabel {
    RAC(self.visibilityInfoLabel, hidden) = [RACObserve(self, currentUser.visibility) map:^id(NSNumber *visibility) {
        return @(visibility.unsignedIntegerValue == UserVisibilityVisible);
    }];
}

- (void)configureYourNameLabel {
    RAC(self.userInfoLabel, text) = [[RACSignal combineLatest:@[RACObserve(self, currentUser),RACObserve(self, currentUser.visibility)]] map:^id(RACTuple *x) {
        RACTupleUnpack(User *user,NSNumber * visibility) = x;
        switch ((UserVisibilityType) visibility.unsignedIntegerValue) {
            case UserVisibilityVisible: {
                NSString *cityName = user.city.cityName ? user.city.cityName : NSLocalizedString(@"UNKNOWN_CITY_ID", nil);
                return [NSString stringWithFormat:@"%@, %@ лет, %@", user.name, user.age, cityName];
            }
            case UserVisibilityBlur: {
                return @"Вы скрыли свое имя и фотографии";
            }
            case UserVisibilityHidden: {
                return @"Вы скрыли свой профиль";
            }
        }
        return @"";
    }];

    RAC(self.bottomPositionNameConstraint, priority) = [RACObserve(self, currentUser.visibility) map:^id(NSNumber *visibility) {
        if (visibility.unsignedIntegerValue == UserVisibilityVisible) {
            return @(800);
        }
        else {
            return @(700);
        }
        return nil;
    }];
}

- (void)configureAvatarImageView {
    self.userAvatarSignal = [[RACObserve(self, currentUser.avatar.originalImageSrc) flattenMap:^RACStream *(NSString *avatarUrl) {
        return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadWithURL:[NSURL URLWithString:avatarUrl]
                             options:0
                            progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                            }
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                               if (image) {
                                   [subscriber sendNext:image];
                                   [subscriber sendCompleted];
                               }
                           }];
            return nil;
        }];
    }] replayLast];
    self.avatarImageView.layer.cornerRadius = 5;
    self.avatarImageView.layer.masksToBounds = YES;
    RAC(self.avatarImageView, image) = [[[[RACSignal combineLatest:@[[self userAvatarSignal], RACObserve(self, currentUser.visibility)]] subscribeOn:[RACScheduler scheduler]] deliverOn:[RACScheduler mainThreadScheduler]] map:^id(RACTuple *x) {
        RACTupleUnpack(UIImage *avatarImage, NSNumber *visibility) = x;
        if (visibility.unsignedIntegerValue == UserVisibilityVisible) {
            return avatarImage;
        }
        else {
            return [avatarImage hp_applyBlurWithRadius:AVATAR_BLUR_RADIUS];
        }
    }];
}

- (void)configureCellInfoLabel {
    self.yourProfilelabel.hidden = ![UIDevice hp_isWideScreen];
}


@end
