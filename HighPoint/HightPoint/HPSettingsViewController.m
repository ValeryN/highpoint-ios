//
//  HPSettingsViewController.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 21.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPSettingsViewController.h"
#import "URLs.h"
#import "UserTokenUtils.h"
#import "HPAuthorizationViewController.h"
#import "HPSettingsTableViewCell.h"
#import "HPUserProfileTableHeaderView.h"
#import "HPSettingsDataManager.h"
#import "UIViewController+HighPoint.h"
#import "HPAppDelegate.h"
#import "HPChangeAccountPasswordViewController.h"

typedef NS_ENUM(NSUInteger, SettingsSectionType){
    SettingsSectionNotify,
    SettingsSectionEvents,
    SettingsSectionAppication,
    SettingsSectionAccountInfo,
    SetiingsSectionApplication,
    //
    SetiingsSectionCount
};

typedef NS_ENUM(NSUInteger, SettingCellType){
    SettingsCellSound,
    SettingsCellStatusBar,
    SettingsCellBannerBar,
    //
    SettingsCellEventMessage,
    SettingsCellEventVotePoint,
    SettingsCellEventPointLimit,
    //
    SettingsCellEnterAppication,
    //
    SettingsCellAccountPassword,
    SettingsCellAccountExit,
    //
    SettingsCellAppicationInfo,
    SettingsCellPrivacyPolicy
};

@interface HPSettingsViewController ()
@property(nonatomic,retain) HPSettingsDataManager* settingsManager;
//Section: Notify
@property(nonatomic,retain) IBOutlet HPSettingsTableViewCell * soundSettings;
@property(nonatomic,retain) IBOutlet HPSettingsTableViewCell * statusBarSettings;
@property(nonatomic,retain) IBOutlet HPSettingsTableViewCell * bannerBarSettings;
//Section: Events
@property(nonatomic,retain) IBOutlet HPSettingsTableViewCell * eventsWriteMessage;
@property(nonatomic,retain) IBOutlet HPSettingsTableViewCell * eventVotePoint;
@property(nonatomic,retain) IBOutlet HPSettingsTableViewCell * eventPointLimit;
//Section: Application enter
@property(nonatomic,retain) IBOutlet HPSettingsTableViewCell * enterApplication;
//Section: Account info
@property(nonatomic,retain) IBOutlet HPSettingsTableViewCell * accountChangePassword;
@property(nonatomic,retain) IBOutlet HPSettingsTableViewCell * accountExit;
//Section: Application
@property(nonatomic,retain) IBOutlet HPSettingsTableViewCell * applicationInfo;
@property(nonatomic,retain) IBOutlet HPSettingsTableViewCell * privacyPolicy;

//Footer view
@property(nonatomic, retain) IBOutlet UIView* versionView;
@property(nonatomic, weak) IBOutlet UILabel* versionLabel;
@end

@implementation HPSettingsViewController

- (void) viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"Настройки";
    self.settingsManager = [HPSettingsDataManager sharedInstance];
    [self configureTwoWaySwitchCell];
    [self configureCheckmarCell];
    [self configureVersionView];
    [self configureBackButton];
}

- (void) configureTwoWaySwitchCell{
    RAC(self, soundSettings.switchView.on) = RACObserve(self, settingsManager.soundEnabled);
    RAC(self,settingsManager.soundEnabled) = self.soundSettings.switchView.rac_newOnChannel;
    
    RAC(self, eventsWriteMessage.switchView.on) = RACObserve(self, settingsManager.notificationWriteMessageEnabled);
    RAC(self,settingsManager.notificationWriteMessageEnabled) = self.eventsWriteMessage.switchView.rac_newOnChannel;
    
    RAC(self, eventVotePoint.switchView.on) = RACObserve(self, settingsManager.notificationLikeYourPointEnabled);
    RAC(self,settingsManager.notificationLikeYourPointEnabled) = self.eventVotePoint.switchView.rac_newOnChannel;
    
    RAC(self, eventPointLimit.switchView.on) = RACObserve(self, settingsManager.notificationPointTimeIsUpEnabled);
    RAC(self,settingsManager.notificationPointTimeIsUpEnabled) = self.eventPointLimit.switchView.rac_newOnChannel;
}

- (void) configureCheckmarCell{
    RAC(self,statusBarSettings.accessoryType) = [RACObserve(self,settingsManager.notificationType) map:^id(NSNumber* value) {
        switch ((SettingsNotificationType)value.intValue) {
            case SettingsNotificationBanner:
                return @(UITableViewCellAccessoryNone);
                break;
            case SettingsNotificationStatus:
                return @(UITableViewCellAccessoryCheckmark);
                break;
        }
        return @(UITableViewCellAccessoryNone);
    }];
    
    RAC(self,bannerBarSettings.accessoryType) = [RACObserve(self,settingsManager.notificationType) map:^id(NSNumber* value) {
        switch ((SettingsNotificationType)value.intValue) {
            case SettingsNotificationBanner:
                return @(UITableViewCellAccessoryCheckmark);
                break;
            case SettingsNotificationStatus:
                return @(UITableViewCellAccessoryNone);
                break;
        }
        return @(UITableViewCellAccessoryNone);
    }];
}

- (void) configureVersionView{
    self.tableView.tableFooterView = self.versionView;
    self.versionLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

- (SettingsSectionType) sectionTypeForSection:(NSUInteger) section{
    return (SettingsSectionType) section;
}

- (SettingCellType) cellTypeForIndexPath:(NSIndexPath*) path{
    switch ([self sectionTypeForSection:path.section]) {
        case SettingsSectionNotify:
            switch (path.row) {
                case 0:
                    return SettingsCellSound;
                    break;
                case 1:
                    return SettingsCellStatusBar;
                    break;
                case 2:
                    return SettingsCellBannerBar;
                    break;
                }
            break;
        case SettingsSectionEvents:
            switch (path.row) {
                case 0:
                    return SettingsCellEventMessage;
                    break;
                case 1:
                    return SettingsCellEventVotePoint;
                    break;
                case 2:
                    return SettingsCellEventPointLimit;
                    break;
            }
            break;
        case SettingsSectionAppication:
            switch (path.row) {
                case 0:
                    return SettingsCellEnterAppication;
                    break;
            }
            break;
        case SettingsSectionAccountInfo:
            switch (path.row) {
                case 0:
                    return SettingsCellAccountPassword;
                    break;
                case 1:
                    return SettingsCellAccountExit;
                    break;
            }
            break;
        case SetiingsSectionApplication:
            switch (path.row) {
                case 0:
                    return SettingsCellAppicationInfo;
                    break;
                case 1:
                    return SettingsCellPrivacyPolicy;
                    break;
            }
            break;
        default:
            NSAssert(false,@"Must bee found %d",[self sectionTypeForSection:path.section]);
            return -1;
    }
    return -1;
}

- (HPSettingsTableViewCell*) cellForIndexPath:(NSIndexPath*) path{
    switch ([self cellTypeForIndexPath:path]) {
        case SettingsCellSound:
            return self.soundSettings;
        case SettingsCellStatusBar:
            return self.statusBarSettings;
        case SettingsCellBannerBar:
            return self.bannerBarSettings;
        case SettingsCellEventMessage:
            return self.eventsWriteMessage;
        case SettingsCellEventVotePoint:
            return self.eventVotePoint;
        case SettingsCellEventPointLimit:
            return self.eventPointLimit;
        case SettingsCellEnterAppication:
            return self.enterApplication;
        case SettingsCellAccountPassword:
            return self.accountChangePassword;
        case SettingsCellAccountExit:
            return self.accountExit;
        case SettingsCellAppicationInfo:
            return self.applicationInfo;
        case SettingsCellPrivacyPolicy:
            return self.privacyPolicy;
    }
    NSAssert(false,@"Cell not found %d",[self cellTypeForIndexPath:path]);
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return SetiingsSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch ([self sectionTypeForSection:section]) {
        case SettingsSectionNotify:
            return 3;
        case SettingsSectionEvents:
            return 3;
        case SettingsSectionAppication:
            return 1;
        case SettingsSectionAccountInfo:
            return 2;
        case SetiingsSectionApplication:
            return 2;
        default:
            NSAssert(false,@"Number of rows unknown %d",[self sectionTypeForSection:section]);
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch ([self sectionTypeForSection:section]) {
        case SettingsSectionNotify:
            return @"УВЕДОМЛЕНИЯ";
        case SettingsSectionEvents:
            return @"СОБЫТИЯ";
        case SettingsSectionAppication:
            return @"ВХОД В ПРИЛОЖЕНИЕ";
        case SettingsSectionAccountInfo:
            return @"АККАУНТ";
        case SetiingsSectionApplication:
            return @"ПРИЛОЖЕНИЕ";
        default:
            return @"";
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString* sectionName = [self tableView:tableView titleForHeaderInSection:section];
    HPUserProfileTableHeaderView *headerView = [[NSBundle mainBundle] loadNibNamed:@"HPUserProfileSettingsTableHeaderView" owner:self options:nil][0];
    headerView.headerTextLabel.text = sectionName;
    UIView *separator = [[UIView alloc] initWithFrame:(CGRect) {13, 47.5f, 294, 0.5f}];
    separator.backgroundColor = [UIColor colorWithRed:230.f / 255.f green:236.f / 255.f blue:242.f / 255.f alpha:0.25];
    [headerView addSubview:separator];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 48;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self cellForIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self cellForIndexPath:indexPath].frame.size.height;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [self cellForIndexPath:indexPath];
    if(cell == self.statusBarSettings){
        self.settingsManager.notificationType = SettingsNotificationStatus;
    }
    if(cell == self.bannerBarSettings){
        self.settingsManager.notificationType = SettingsNotificationBanner;
    }
    if(cell == self.accountChangePassword){
        UIViewController* controller = [[HPChangeAccountPasswordViewController alloc] initWithNibName:@"HPChangeAccountPasswordViewController" bundle:nil];
        [self.navigationController pushViewController:controller animated:YES];
    }
    if(cell == self.accountExit){
        [UserTokenUtils setUserToken:nil];
        UIStoryboard* storyBoard = [UIStoryboard storyboardWithName: @"Storyboard_568" bundle: nil];
        HPAuthorizationViewController* authViewController = [storyBoard instantiateViewControllerWithIdentifier: @"auth"];
        ((HPAppDelegate*)[UIApplication sharedApplication].delegate).window.rootViewController = [[UINavigationController alloc] initWithRootViewController:authViewController];;
    }
    if(cell == self.applicationInfo){
        UIViewController* controller = [[UIViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }
    if(cell == self.privacyPolicy){
        UIViewController* controller = [[UIViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
