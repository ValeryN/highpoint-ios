//
//  HPUserInfoViewController.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 10.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPUserInfoViewController.h"
#import "HPTownTableViewCell.h"
#import "HPAddPhotoMenuViewController.h"
#import "Utils.h"
#import "MaxEntertainmentPrice.h"
#import "MinEntertainmentPrice.h"
#import "UIDevice+HighPoint.h"
#import "UILabel+HighPoint.h"
#import "UIButton+HighPoint.h"
#import "UIImage+HighPoint.h"
//#import "Place.h"
#import "DataStorage.h"
#import "School.h"
#import "NotificationsConstants.h"
#import "HPUserProfileInfoEditTabViewController.h"
#import "HPUserCardViewController.h"
#import "HPUserInfoPhotoAlbumViewController.h"
#import "UIViewController+HighPoint.h"



@interface HPUserInfoViewController ()
@property (nonatomic, retain) HPUserProfileInfoEditTabViewController* infoEditTabViewController;
@property (nonatomic, retain) HPUserInfoPhotoAlbumViewController* photoAlbumTabViewController;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentController;
@end

@implementation HPUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [RACObserve(self, navigationController.navigationBar) subscribeNext:^(UINavigationBar* bar) {
        bar.translucent = YES;
    }];
    self.user = [[DataStorage sharedDataStorage] getCurrentUser];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self configureSegmentedControl];
    [self configurePhotoTab];
    [self configureInfoTab];
    [self configureBackButton];
}


- (void)configurePhotoTab {
    self.photoAlbumTabViewController = [[HPUserInfoPhotoAlbumViewController alloc] initWithNibName:@"HPUserInfoPhotoAlbumViewController" bundle:nil];
    self.photoAlbumTabViewController.user = self.user;
    [self addChildViewController:self.photoAlbumTabViewController];
    self.photoAlbumTabViewController.view.frame = self.view.frame;

    [self.view addSubview:self.photoAlbumTabViewController.view];
    RAC(self.photoAlbumTabViewController.view, hidden) = [RACObserve(self, segmentController.selectedSegmentIndex) map:^id(NSNumber *value) {
        return @(value.unsignedIntegerValue == 1);
    }];
}

- (void)configureInfoTab {
    self.infoEditTabViewController = [[HPUserProfileInfoEditTabViewController alloc] initWithNibName:@"HPUserProfileInfoEditTabViewController" bundle:nil];
    self.infoEditTabViewController.user = self.user;
    [self addChildViewController:self.infoEditTabViewController];
    self.infoEditTabViewController.view.frame = self.view.frame;
    [self.view addSubview:self.infoEditTabViewController.view];

    RAC(self.infoEditTabViewController.view, hidden) = [RACObserve(self, segmentController.selectedSegmentIndex) map:^id(NSNumber *value) {
        return @(value.unsignedIntegerValue == 0);
    }];
}

- (void)configureSegmentedControl {
    @weakify(self);
    [RACObserve(self.user, visibility) subscribeNext:^(NSNumber* type) {
        @strongify(self);
        switch ((UserVisibilityType)type.intValue) {
            case UserVisibilityBlur:
            case UserVisibilityVisible:
            case UserVisibilityRequestBlur:
                self.navigationItem.titleView = self.segmentController;
                break;
            case UserVisibilityHidden:
            case UserVisibilityRequestHidden:
                self.navigationItem.titleView = nil;
                self.navigationItem.title = @"Профиль скрыт";
                break;
        }
    }];
    
}


@end
