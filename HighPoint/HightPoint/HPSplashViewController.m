//
//  HPSplashViewController.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 18.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPSplashViewController.h"
#import "HPBaseNetworkManager.h"
#import "HPBaseNetworkManager+ApplicationSettings.h"
#import "HPBaseNetworkManager+CurrentUser.h"
#import "HPBaseNetworkManager+Contacts.h"
#import "HPBaseNetworkManager+Messages.h"
#import "HPBaseNetworkManager+Users.h"
#import "HPBaseNetworkManager+Points.h"
#import "HPBaseNetworkManager+Geo.h"
#import "HPRootViewController.h"
#import "NotificationsConstants.h"
#import "HPAppDelegate.h"
#import "DataStorage.h"

@interface HPSplashViewController ()

@end

@implementation HPSplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    [[DataStorage sharedDataStorage] deleteAndSaveAllUsersWithBlock:^(NSError *error) {
        if(!error) {
            [[DataStorage sharedDataStorage] deleteAndSaveAllContacts];
            [[DataStorage sharedDataStorage] deleteAndSaveAllMessages];
            [[HPBaseNetworkManager sharedNetworkManager] createTaskArray];
            [[HPBaseNetworkManager sharedNetworkManager] getPointsRequest:1];   //4
            [[HPBaseNetworkManager sharedNetworkManager] getUsersRequest:1];    //2
            [[HPBaseNetworkManager sharedNetworkManager] getCurrentUserRequest];
            [[HPBaseNetworkManager sharedNetworkManager] getContactsRequest];
            [[HPBaseNetworkManager sharedNetworkManager] getPointLikesRequest:@1];  //3
            [[HPBaseNetworkManager sharedNetworkManager] getUnreadMessageRequest]; //1
            
            [[HPBaseNetworkManager sharedNetworkManager] getApplicationSettingsRequest];
            //[[HPBaseNetworkManager sharedNetworkManager] getUserPhotoRequest];
            [[HPBaseNetworkManager sharedNetworkManager] getPopularCitiesRequest];
        }
    }];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerNotification];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterNotification];
}


#pragma mark - notifications

- (void) registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideSplashView) name:kNeedHideSplashView object:nil];
}


- (void) unregisterNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNeedHideSplashView object:nil];
}

#pragma mark - hide splash

- (void) hideSplashView {
    HPRootViewController *rootController;
    UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"Storyboard_568" bundle:nil];
    rootController = [mainstoryboard instantiateViewControllerWithIdentifier:@"HPRootViewController"];
    [self performSelector:@selector(openViewController:) withObject:rootController afterDelay:1];
}

- (void) openViewController:(UIViewController *) controller{
    ((HPAppDelegate*)[UIApplication sharedApplication].delegate).window.rootViewController = [[UINavigationController alloc] initWithRootViewController:controller];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
