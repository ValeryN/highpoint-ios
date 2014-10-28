//
//  HPCurrentUserUICollectionViewCell.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 04.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPCurrentUserPrivacyViewController.h"
#import "UILabel+HighPoint.h"
#import "UIImage+HighPoint.h"
#import "UIDevice+HighPoint.h"
#import "Avatar.h"
#import "UserPoint.h"
#import "HPCurrentUserViewController.h"
#import "DataStorage.h"
#import "HPRoundedShadowedImageView.h"
#import "User+UserImage.h"

#define AVATAR_BLUR_RADIUS 10.0

@interface HPCurrentUserPrivacyViewController ()
@property(weak, nonatomic) IBOutlet HPRoundedShadowedImageView* avatarView;
@property(weak, nonatomic) IBOutlet UILabel *yourProfilelabel;
@property(weak, nonatomic) IBOutlet UILabel *userInfoLabel;
@property(weak, nonatomic) IBOutlet UIButton *visibleBtn;
@property(weak, nonatomic) IBOutlet UIButton *lockBtn;
@property(weak, nonatomic) IBOutlet UIButton *invisibleBtn;
@property(weak, nonatomic) IBOutlet UILabel *visibilityInfoLabel;
@property(weak, nonatomic) IBOutlet UILabel *pointLabel;

@property(nonatomic, strong) IBOutletCollection(NSLayoutConstraint) NSArray *constraintFor4inch;
@property(nonatomic, weak) IBOutlet NSLayoutConstraint *bottomPositionNameConstraint;

@property(nonatomic,retain) RACSignal* visibilitySignal;
@end

@implementation HPCurrentUserPrivacyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self configureCellInfoLabel];
    [self configureYourNameLabel];
    [self configureProfileVisibilityLabel];
    [self configureVisibleButton];
    [self configureBlurButton];
    [self configureHiddenButton];
    [self configureAvatarImageView];
    [self configurePointLabel];
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
    @weakify(self);
    RAC(self, invisibleBtn.enabled) = [[self visibilitySignal]  map:^id(NSNumber *visibility) {
        return @(visibility.unsignedIntegerValue != UserVisibilityHidden);
    }];

    [[self.invisibleBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [[DataStorage sharedDataStorage] updateAndSaveVisibility:UserVisibilityHidden forUser:self.currentUser];
    }];
}

- (void)configureBlurButton {
    @weakify(self);
    RAC(self, lockBtn.enabled) = [[self visibilitySignal]  map:^id(NSNumber *visibility) {
        return @(visibility.unsignedIntegerValue != UserVisibilityBlur);
    }];

    [[self.lockBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [[DataStorage sharedDataStorage] updateAndSaveVisibility:UserVisibilityBlur forUser:self.currentUser];
    }];
}

- (void)configureVisibleButton {
    @weakify(self);
    RAC(self, visibleBtn.enabled) = [[self visibilitySignal]  map:^id(NSNumber *visibility) {
        return @(visibility.unsignedIntegerValue != UserVisibilityVisible);
    }];

    [[self.visibleBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [[DataStorage sharedDataStorage] updateAndSaveVisibility:UserVisibilityVisible forUser:self.currentUser];
    }];
}

- (void)configureProfileVisibilityLabel {
    @weakify(self);
    if(![UIDevice hp_isWideScreen]){
        self.visibilityInfoLabel.alpha = 0;
        [[[self visibilitySignal]  skip:1] subscribeNext:^(id x) {
            [UIView animateKeyframesWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                @strongify(self);
                self.visibilityInfoLabel.alpha = 1;
                self.visibleBtn.alpha = 0;
                self.lockBtn.alpha = 0;
                self.invisibleBtn.alpha = 0;
            } completion:^(BOOL completed){
                if(completed){
                    [UIView animateKeyframesWithDuration:0.5f delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
                        @strongify(self);
                        self.visibilityInfoLabel.alpha = 0;
                        self.visibleBtn.alpha = 1;
                        self.lockBtn.alpha = 1;
                        self.invisibleBtn.alpha = 1;
                    } completion:nil];
                }
            }];
        }];
    }
    
    RAC(self.visibilityInfoLabel, text) = [[self visibilitySignal]  map:^id(NSNumber *visibility) {
        switch ((UserVisibilityType)visibility.unsignedIntegerValue) {
            case UserVisibilityVisible:
                return @"Фотографии и личная информация видна всем людям";
                break;
            case UserVisibilityBlur:
                return @"Ваши фотографии никто не увидити, пока вы сами не захотите этого";
                break;
            case UserVisibilityHidden:
                return @"Ваши фотографии и личную информацию никто не увидит, пока вы сами не захотите этого";
                break;
            default:
                return @"";
                break;
        }
    }];
}

- (void)configureYourNameLabel {
    RAC(self.userInfoLabel, text) = [[RACSignal combineLatest:@[RACObserve(self, currentUser),[self visibilitySignal]]] map:^id(RACTuple *x) {
        RACTupleUnpack(User *user,NSNumber * visibility) = x;
        switch ((UserVisibilityType) visibility.unsignedIntegerValue) {
            case UserVisibilityVisible: {
                NSString *cityName = user.city.cityName ? user.city.cityName : NSLocalizedString(@"UNKNOWN_CITY_ID", nil);
                return [NSString stringWithFormat:@"%@, %@ лет, %@", user.name, user.age, cityName];
            }
            case UserVisibilityBlur:
            case UserVisibilityRequestBlur:{
                return @"Вы скрыли свое имя и фотографии";
            }
            case UserVisibilityHidden:
            case UserVisibilityRequestHidden:{
                return @"Вы скрыли свой профиль";
            }
        }
        return @"";
    }];

    RAC(self.bottomPositionNameConstraint, priority) = [[self visibilitySignal] map:^id(NSNumber *visibility) {
        if (visibility.unsignedIntegerValue == UserVisibilityVisible) {
            return @(800);
        }
        else {
            return @(700);
        }
        return nil;
    }];
}

- (void) configurePointLabel{
    RAC(self.pointLabel, text) = [[RACSignal combineLatest:@[RACObserve(self, currentUser.point),[self visibilitySignal]]] map:^id(RACTuple* value) {
        RACTupleUnpack(UserPoint* point, NSNumber* visibility) = value;
        if(!point && visibility.integerValue == UserVisibilityHidden){
            return @"Вы польностью скрыли свой профиль от других пользователей. Опубликуйте поинт что-бы появится в ленте.";
        }
        else if(point){
            return point.pointText;
        }
        else
            return @"";
    }];
    RAC(self.pointLabel, textColor) = [[RACSignal combineLatest:@[RACObserve(self, currentUser.point),[self visibilitySignal]]] map:^id(RACTuple* value) {
        RACTupleUnpack(UserPoint* point, NSNumber* visibility) = value;
        if(!point && visibility.integerValue == UserVisibilityHidden){
            return [UIColor colorWithRed:1.f green:102.f/255.f blue:112.f/255.f alpha:1];
        }
        else
            return [UIColor colorWithRed:224.f/255.f green:231.f/255.f blue:239.f/255.f alpha:1];
    }];
}

- (RACSignal*) visibilitySignal{
    if(!_visibilitySignal)
    {
        _visibilitySignal = [RACObserve(self, currentUser.visibility) replayLast];
    }
    return _visibilitySignal;
}

- (RACSignal*) avatarSignal{
    return [RACObserve(self, currentUser) flattenMap:^RACStream *(User* value) {
        return value.userImageSignal;
    }];
}

- (void)configureAvatarImageView {
    RAC(self.avatarView, image) = [[[[RACSignal combineLatest:@[[self avatarSignal], [self visibilitySignal]]] deliverOn:[RACScheduler scheduler]] map:^id(RACTuple *x) {
        RACTupleUnpack(UIImage *avatarImage, NSNumber *visibility) = x;
        if (visibility.unsignedIntegerValue == UserVisibilityVisible) {
            return avatarImage;
        }
        else {
            return [avatarImage hp_applyBlurWithRadius:AVATAR_BLUR_RADIUS];
        }
    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (void)configureCellInfoLabel {
    self.yourProfilelabel.hidden = ![UIDevice hp_isWideScreen];
}


@end
