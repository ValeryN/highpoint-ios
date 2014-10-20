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


@interface HPCurrentUserViewController ()
@property(nonatomic, retain) User *currentUser;
@property(nonatomic) RACSignal* currentUserSignal;

@property (nonatomic,weak) IBOutlet HPAvatarView* avatarView;
@property (nonatomic,weak) IBOutlet UILabel* nameLabel;
@property (nonatomic,weak) IBOutlet UILabel* userInfoLabel;
@property (nonatomic,weak) IBOutlet UITextView* pointTextField;
@property (nonatomic,weak) IBOutlet UILabel* pointStatus;

@property (nonatomic, weak) IBOutlet UIButton* openPrivacyButton;
@end

@implementation HPCurrentUserViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentUser = [[DataStorage sharedDataStorage] getCurrentUser];
    [self configureUserInfo];
    [self configureButtons];
}

- (void) configureButtons{
    @weakify(self);
    [[self.openPrivacyButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        HPCurrentUserPrivacyViewController* privacyVc = [[HPCurrentUserPrivacyViewController alloc] initWithNibName:@"HPCurrentUserPrivacyViewController" bundle:nil];
        privacyVc.currentUser = self.currentUser;
        [self.navigationController pushViewController:privacyVc animated:YES];
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

- (RACSignal*) currentUserSignal{
    if(!_currentUserSignal){
        _currentUserSignal = [[RACObserve(self, currentUser) distinctUntilChanged] replayLast];
    }
    return _currentUserSignal;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    if(self.view.window == nil){
        self.view = nil;
    }
}

@end