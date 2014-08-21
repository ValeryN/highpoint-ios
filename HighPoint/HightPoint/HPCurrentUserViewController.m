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
#import "HPCurrentUserUICollectionViewCell.h"
#import "Utils.h"


@interface HPCurrentUserViewController ()
@property(nonatomic, retain) User *currentUser;
@property(nonatomic, retain) HPCurrentUserPointCollectionViewCell *cellPoint;
@property(nonatomic, retain) HPCurrentUserUICollectionViewCell *cellUser;

@end

@implementation HPCurrentUserViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    [self.currentUserCollectionView registerNib:[UINib nibWithNibName:@"HPUserCardUICollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"UserCardIdentif"];
    [self.currentUserCollectionView registerNib:[UINib nibWithNibName:@"HPCurrentUserUICollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CurrentUserCollectionCell"];
    [self.currentUserCollectionView registerNib:[UINib nibWithNibName:@"HPCurrentUserPointCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CurrentUserPointIdentif"];

    self.currentUserCollectionView.delegate = self;
    self.currentUserCollectionView.dataSource = self;

    [self createPageControlInNavigationBar];

    [self configureNavigationBar];
    [self configureCurrentUsersForCells];
    [self configureBottomMenu];
    [self configurePageControl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self resetNavigationBarButtons];

    self.currentUser = [[DataStorage sharedDataStorage] getCurrentUser];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return 2;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if (!self.cellPoint) {
            self.cellPoint = [cv dequeueReusableCellWithReuseIdentifier:@"CurrentUserPointIdentif" forIndexPath:indexPath];
            self.cellPoint.delegate = self;
            [self lockHorizontalScrollWhileEditPointInView:self.cellPoint];
            [self hidePageControlWhileEditPoingInView:self.cellPoint];
        }
        return self.cellPoint;
    } else {
        if (!self.cellUser) {
            self.cellUser = [cv dequeueReusableCellWithReuseIdentifier:@"CurrentUserCollectionCell" forIndexPath:indexPath];
            self.cellUser.delegate = self;
        }
        return self.cellUser;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = [UIScreen mainScreen].bounds.size;
    //Status bar - 20
    //Navigation bar 44
    size.height -= (20 + 44);
    return size;
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    double index = scrollView.contentOffset.x / 320.0;
    self.pageController.currentPage = (int) index;
}


#pragma mark - Actions

- (IBAction)bottomTap:(id)sender {
    if (self.pageController.currentPage == 0) {
        [self showLikedUserPointViewController];
    } else {
        [self showCurrentUserProfileViewController];
    }
}

- (void)showCurrentUserProfileViewController {
    HPUserProfileViewController *uiController = [[HPUserProfileViewController alloc] initWithNibName:@"HPUserProfile" bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:uiController];
    uiController.delegate = self;
    uiController.transitioningDelegate = self;
    uiController.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)showLikedUserPointViewController {
    HPPointLikesViewController *plController = [[HPPointLikesViewController alloc] initWithNibName:@"HPPointLikesViewController" bundle:nil];
    [self.navigationController pushViewController:plController animated:YES];
}

- (void)createPointWithPointText:(NSString *)text andTime:(NSNumber *)time forUser:(User *)user {
    NSDictionary *dictionary = @{@"createdAt" : @"Как время может быть строкой! Искать збс удобно в базе", @"text" : text, @"userId" : user.userId, @"pointValidTo" : @"Ммм, строка плюс строка, клас."};
    [[DataStorage sharedDataStorage] createAndSavePoint:dictionary];
}

- (void)deleteCurrentUserPointForUser:(User *)user {
    [[DataStorage sharedDataStorage] deleteAndSaveUserPointForUser:user];
}

- (void)updateUserVisibility:(UserVisibilityType)visibilityType forUser:(User *)user {
    [[DataStorage sharedDataStorage] updateAndSaveVisibility:visibilityType forUser:user];
}


#pragma mark - navigation item


- (void)resetNavigationBarButtons {
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
        [self.navigationController popViewControllerAnimated:YES];
        return [RACSignal empty];
    }];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    self.navigationItem.rightBarButtonItem = nil;
}


#pragma mark Configures

- (void)configureNavigationBar {
    [[RACSignal combineLatest:@[RACObserve(self, cellPoint.editUserPointMode), RACObserve(self, navigationController.navigationBar)]] subscribeNext:^(RACTuple *x) {
        RACTupleUnpack(NSNumber *editUserPointMode, UINavigationBar *navigationBar) = x;
        if (editUserPointMode.boolValue) {
            navigationBar.barTintColor = [UIColor colorWithRed:34.0 / 255.0 green:45.0 / 255.0 blue:77.0 / 255.0 alpha:0.9];
            navigationBar.translucent = YES;
        }
        else {
            navigationBar.barTintColor = [UIColor colorWithRed:30.f / 255.f green:29.f / 255.f blue:48.f / 255.f alpha:1];
            navigationBar.translucent = NO;
        }
    }];
}

- (void)configurePageControl {
    @weakify(self);
    [[self.pageController rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(UIPageControl * pageControl) {
        @strongify(self);
        self.pageController.currentPage =  pageControl.currentPage;
        [self.currentUserCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:pageControl.currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }];
}

- (void)configureBottomMenu {
    @weakify(self);
    [[RACSignal combineLatest:@[RACObserve(self, pageController.currentPage), RACObserve(self, cellPoint.editUserPointMode), RACObserve(self, currentUser.point)]] subscribeNext:^(RACTuple *x) {
        @strongify(self);
        RACTupleUnpack(NSNumber *index, NSNumber *editMode, UserPoint *userPoint) = x;
        if (index.intValue == 0) {
            if (userPoint == nil) {
                self.bottomView.hidden = YES;
            }
            else if (editMode.boolValue) {
                self.bottomView.hidden = YES;
            }
            else {
                self.bottomView.hidden = NO;
                self.personalDataLabel.text = NSLocalizedString(@"YOUR_POINT_LIKES", nil);
                self.personalDataDownImgView.hidden = YES;
            }
        } else {
            self.bottomView.hidden = NO;
            self.personalDataLabel.text = NSLocalizedString(@"YOUR_PHOTO_ALBUM_AND_DATA", nil);
            self.personalDataDownImgView.hidden = NO;
        }
    }];
}

- (void)configureCurrentUsersForCells {
    [[RACSignal zip:@[RACObserve(self, currentUser), RACObserve(self, cellPoint)]] subscribeNext:^(RACTuple *x) {
        RACTupleUnpack(User *currentUser, HPCurrentUserPointCollectionViewCell *cellPoint) = x;
        cellPoint.currentUser = currentUser;
    }];
    [[RACSignal zip:@[RACObserve(self, currentUser), RACObserve(self, cellUser)]] subscribeNext:^(RACTuple *x) {
        RACTupleUnpack(User *currentUser, HPCurrentUserUICollectionViewCell *cellUser) = x;
        cellUser.currentUser = currentUser;
    }];
}


- (void)lockHorizontalScrollWhileEditPointInView:(HPCurrentUserPointCollectionViewCell *)cell {
    RAC(self.currentUserCollectionView, scrollEnabled) = [RACObserve(cell, editUserPointMode) not];
}

- (void)hidePageControlWhileEditPoingInView:(HPCurrentUserPointCollectionViewCell *)cell {
    RAC(self.pageController, hidden) = RACObserve(cell, editUserPointMode);
}

#pragma mark UIElements

- (void)createPageControlInNavigationBar {
    self.pageController = [[UIPageControl alloc] initWithFrame:(CGRect) {0, 0, 100, 20}];
    self.pageController.numberOfPages = 2;
    UIView *view = [[UIView alloc] initWithFrame:(CGRect) {0, 0, 100, 20}];
    [view addSubview:self.pageController];
    self.navigationItem.titleView = view;
    self.pageController.currentPage = 0;

}


@end
