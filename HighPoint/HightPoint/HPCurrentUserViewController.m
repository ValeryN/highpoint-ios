//
//  HPCurrentUserViewController.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 10.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPCurrentUserViewController.h"
#import "DataStorage.h"
#import "UIDevice+HighPoint.h"
#import "HPPointLikesViewController.h"
#import "Utils.h"
#import "HPSettingsViewController.h"
#import "HPAvatarView.h"
#import "UINavigationBar+HighPoint.h"
#import "HPRequest.h"
#import "HPRequest+Points.h"
#import "User+UserImage.h"
#import "HPCurrentUserPrivacyViewController.h"
#import "UIViewController+HighPoint.h"
#import "UITextView+HPRacSignal.h"
#import "UITextView+HightPoint.h"


@interface HPCurrentUserViewController ()
@property(nonatomic, retain) User *currentUser;
@property(nonatomic) RACSignal* currentUserSignal;

@property (nonatomic,weak) IBOutlet HPAvatarView* avatarView;
@property (nonatomic,weak) IBOutlet UIScrollView* mainScroll;
@property (nonatomic,weak) IBOutlet UIView* contentView;
@property (nonatomic,weak) IBOutlet UILabel* nameLabel;
@property (nonatomic,weak) IBOutlet UILabel* userInfoLabel;
@property (nonatomic,weak) IBOutlet UITextView* pointTextField;
@property (nonatomic,weak) IBOutlet UILabel* pointStatus;

@property (nonatomic, weak) IBOutlet UIButton* openPrivacyButton;
@property (nonatomic, weak) IBOutlet UIButton* openPhotoAlbumButton;
@property (nonatomic, weak) IBOutlet UIButton* openConciergeButton;

@property (nonatomic) BOOL pointMode;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint * totalContentViewHeightConstraint;
@end

@implementation HPCurrentUserViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.currentUser = [[DataStorage sharedDataStorage] getCurrentUser];
    self.automaticallyAdjustsScrollViewInsets = YES;
    [self configureBlurView];
    [self configureUserInfo];
    [self configureButtons];
    [self configureLeftBarButton];
    [self configureOffsetInEditMode];
    
}

- (void) configureBlurView{
    self.view.backgroundColor = [UIColor clearColor];
    UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:self.view.frame];
    toolbar.barStyle = UIBarStyleBlack;
    toolbar.translucent = YES;
    [self.view insertSubview:toolbar atIndex:0];
}

- (void) configureButtons{
    @weakify(self);
    [[self.openPrivacyButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        HPCurrentUserPrivacyViewController* privacyVc = [[HPCurrentUserPrivacyViewController alloc] initWithNibName:@"HPCurrentUserPrivacyViewController" bundle:nil];
        privacyVc.currentUser = self.currentUser;
        [self.navigationController pushViewController:privacyVc animated:YES];
    }];
    
    [[self.openPhotoAlbumButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        HPUserProfileViewController* profile = [[HPUserProfileViewController alloc] initWithNibName:@"HPUserProfile" bundle:nil];
        profile.user = self.currentUser;
        [self.navigationController pushViewController:profile animated:YES];
    }];
    
    [[self.openConciergeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [[[UIAlertView alloc] initWithTitle:@"Not implemented" message:@"No design" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
    }];
}

- (void) configureUserInfo{
    RAC(self.nameLabel,text) = [[self currentUserSignal] map:^id(User* value) {
        return value.name;
    }];
    
    RAC(self.userInfoLabel,text) = [[self currentUserSignal] map:^id(User* value) {
        NSString *cityName = value.city.cityName ? value.city.cityName : NSLocalizedString(@"UNKNOWN_CITY_ID", nil);
        return [NSString stringWithFormat:@"%@ лет, %@", value.age,cityName];
    }];
    
    RAC(self.avatarView, user) = [self currentUserSignal];
}

- (void) configureLeftBarButton{
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] init];
    if ([UIDevice hp_isIOS6]) {
        leftBarItem.image = [UIImage imageNamed:@"Close"];
    }
    else {
        leftBarItem.image = [[UIImage imageNamed:@"Close"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    @weakify(self);
    leftBarItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        self.navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [UIView animateWithDuration:0.3 animations:^{
            @strongify(self);
            self.navigationController.view.alpha = 0;
        } completion:^(BOOL finished) {
            @strongify(self);
            [self.navigationController dismissViewControllerAnimated:NO completion:nil];
        }];        
        return [RACSignal empty];
    }];
    self.navigationItem.leftBarButtonItem = leftBarItem;
}

- (void) configureOffsetInEditMode{
    @weakify(self);
    [[self moveUpAvatarSignal] subscribeNext:^(NSNumber* x) {
        @strongify(self);
        if(!x.boolValue){
            [self.contentView removeConstraint:self.totalContentViewHeightConstraint];
        }
        else{
            self.totalContentViewHeightConstraint.constant = self.view.frame.size.height+120;
            [self.contentView addConstraint:self.totalContentViewHeightConstraint];
            self.mainScroll.bounces = NO;
            [self.mainScroll layoutIfNeeded];
            [UIView animateWithDuration:0.25 animations:^{
                 [self.mainScroll setContentOffset:(CGPoint){0,120}];
                 [self.mainScroll layoutIfNeeded];
            }];
        }
    }];
    RAC(self, mainScroll.bounces) = [[self moveUpAvatarSignal] not];
    RAC(self, mainScroll.scrollEnabled) = [[self moveUpAvatarSignal] not];
}

- (RACSignal*) currentUserSignal{
    if(!_currentUserSignal){
        _currentUserSignal = [[RACObserve(self, currentUser) distinctUntilChanged] replayLast];
    }
    return _currentUserSignal;
}

- (RACSignal*) moveUpAvatarSignal {
    RACSignal * keyboardIsOpened = [self.pointTextField rac_isEditing];
    return [[RACSignal combineLatest:@[RACObserve(self, pointMode),keyboardIsOpened]] or];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    if(self.view.window == nil){
        self.view = nil;
    }
}

@end