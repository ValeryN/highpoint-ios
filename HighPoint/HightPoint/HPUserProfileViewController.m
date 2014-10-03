//
//  HPUserProfileViewController.m
//  HighPoint
//
//  Created by Andrey Anisimov on 27.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "HPUserProfileViewController.h"
#import "Utils.h"
#import "HPImageCollectionViewCell.h"
#import "HPUserProfileTableHeaderView.h"

#import "HPUserInfoSecondRowTableViewCell.h"
#import "MaxEntertainmentPrice.h"
#import "MinEntertainmentPrice.h"
#import "UIDevice+HighPoint.h"
#import "HPMakeAvatarViewController.h"
#import "NMRangeSlider.h"
#import "HPUserProfilePhotoAlbumTabViewController.h"
#import "UINavigationBar+HighPoint.h"
#import "HPUserProfileInfoEditTabViewController.h"
#import "DataStorage.h"

//#undef SCREEN_HEIGHT
//#ifdef IS_IPHONE_5
//#define SCREEN_HEIGHT 568
//#else
//#define SCREEN_HEIGHT 480
//#endif
#define ScreenBound       ([[UIScreen mainScreen] bounds])
#define ScreenHeight      (ScreenBound.size.height)


#define CONSTRAINT_GREENBUTTON_FROM_BOTTOM 47.0
#define CONSTRAINT_TRASHBUTTON_FROM_LEFT 274.0
#define FIRST_ROW_HEIGHT_CONST 90.0
#define BUBBLE_VIEW_WIDTH_CONST 290.0
//==============================================================================

@interface HPUserProfileViewController ()
@property(nonatomic, retain) HPUserProfileInfoEditTabViewController *infoEditTabViewController;
@property(nonatomic, retain) HPUserProfilePhotoAlbumTabViewController *photoAlbumTabViewController;
@end

@implementation HPUserProfileViewController

//==============================================================================

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;


    [self configureNavigationBar];
    [self configureSegmentedControl];
    [self configurePhotoTab];
    [self configureInfoTab];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    UIEdgeInsets insets = UIEdgeInsetsMake(self.topLayoutGuide.length,
            0.0,
            self.bottomLayoutGuide.length,
            0.0);
    if (self.infoEditTabViewController.tableView.contentInset.top == 0)
        self.infoEditTabViewController.tableView.contentInset = self.infoEditTabViewController.tableView.scrollIndicatorInsets = insets;
    if (self.photoAlbumTabViewController.collectionView.contentInset.top == 0)
        self.photoAlbumTabViewController.collectionView.contentInset = self.photoAlbumTabViewController.collectionView.scrollIndicatorInsets = insets;
}

- (void)configurePhotoTab {
    self.photoAlbumTabViewController = [[HPUserProfilePhotoAlbumTabViewController alloc] initWithNibName:@"HPUserProfilePhotoAlbumTabViewController" bundle:nil];
    self.photoAlbumTabViewController.user = [[DataStorage sharedDataStorage] getCurrentUser];
    [self addChildViewController:self.photoAlbumTabViewController];
    self.photoAlbumTabViewController.view.frame = self.view.frame;

    [self.view addSubview:self.photoAlbumTabViewController.view];
    RAC(self.photoAlbumTabViewController.view, hidden) = [RACObserve(self, segmentControl.selectedSegmentIndex) map:^id(NSNumber *value) {
        return @(value.unsignedIntegerValue == 1);
    }];
}

- (void)configureInfoTab {
    self.infoEditTabViewController = [[HPUserProfileInfoEditTabViewController alloc] initWithNibName:@"HPUserProfileInfoEditTabViewController" bundle:nil];
    self.infoEditTabViewController.withEditMode = YES;
    self.infoEditTabViewController.user = self.user;
    [self addChildViewController:self.infoEditTabViewController];
    self.infoEditTabViewController.view.frame = self.view.frame;
    [self.view addSubview:self.infoEditTabViewController.view];

    RAC(self.infoEditTabViewController.view, hidden) = [RACObserve(self, segmentControl.selectedSegmentIndex) map:^id(NSNumber *value) {
        return @(value.unsignedIntegerValue == 0);
    }];
}

- (void)configureSegmentedControl {
    self.navigationItem.titleView = self.segmentControl;
}

- (void)configureNavigationBar {
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] init];
    if ([UIDevice hp_isIOS6]) {
        leftBarItem.image = [UIImage imageNamed:@"Down"];
    }
    else {
        leftBarItem.image = [[UIImage imageNamed:@"Down"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    @weakify(self);
    leftBarItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        [self dismissViewControllerAnimated:YES completion:nil];
        return [RACSignal empty];
    }];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    self.navigationItem.rightBarButtonItem = nil;

    [RACObserve(self, navigationController.navigationBar) subscribeNext:^(UINavigationBar *navigationBar) {
        [navigationBar configureTranslucentNavigationBar];
    }];
}

@end
