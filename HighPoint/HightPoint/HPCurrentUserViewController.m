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
#import "HPSettingsViewController.h"
#import "HPAvatarView.h"
#import "SDWebImageManager.h"
#import "UINavigationBar+HighPoint.h"
#import "HPRequest.h"
#import "HPRequest+Points.h"
#import "User+UserImage.h"


@interface HPCurrentUserViewController ()
@property(nonatomic, retain) User *currentUser;
@property(nonatomic, retain) HPCurrentUserPointCollectionViewCell *cellPoint;
@property(nonatomic, retain) HPCurrentUserUICollectionViewCell *cellUser;


@property(weak, nonatomic) IBOutlet UICollectionView *currentUserCollectionView;
@property(retain, nonatomic) IBOutlet UIPageControl *pageController;


@property(weak, nonatomic) IBOutlet UIView *bottomView;
@property(weak, nonatomic) IBOutlet UIImageView *personalDataDownImgView;
@property(weak, nonatomic) IBOutlet UILabel *personalDataLabel;
@property(weak, nonatomic) IBOutlet UIButton *bottomBtn;
@property(weak, nonatomic) IBOutlet UIView *bottomLikedView;
@property(weak, nonatomic) IBOutlet UIView *bottomNobodyLikeLabel;
@end

@implementation HPCurrentUserViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentUser = [[DataStorage sharedDataStorage] getCurrentUser];

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
    [self configureAvatarSignal];
}

- (void)configureAvatarSignal {
    @weakify(self);
    self.avatarSignal = [[[RACObserve(self, currentUser.avatar.originalImageSrc) distinctUntilChanged] flattenMap:^RACStream *(id value) {
        @strongify(self);
        return [self.currentUser userImageSignal];
    }] replayLast];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar configureOpaqueNavigationBar];
    [super viewWillAppear:animated];
    [self resetNavigationBarButtons];
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


#pragma mark - Actions

- (IBAction)bottomTap:(id)sender {
    if (self.pageController.currentPage == 0) {
        @weakify(self);
        [[self.usersLikeYourPost filter:^BOOL(NSArray *array) {
            return array.count > 0;
        }] subscribeNext:^(id x) {
            @strongify(self);
            [self showLikedUserPointViewController];
        }];
    } else {
        [self showCurrentUserProfileViewController];
    }
}

- (void)showCurrentUserProfileViewController {
    HPUserProfileViewController *uiController = [[HPUserProfileViewController alloc] initWithNibName:@"HPUserProfile" bundle:nil];
    uiController.user = self.currentUser;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:uiController];
    uiController.transitioningDelegate = self;
    uiController.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)showLikedUserPointViewController {
    HPPointLikesViewController *plController = [[HPPointLikesViewController alloc] initWithNibName:@"HPPointLikesViewController" bundle:nil];
    plController.user = self.currentUser;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:plController];
    plController.transitioningDelegate = self;
    plController.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:navigationController animated:YES completion:nil];
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
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] init];
    if ([UIDevice hp_isIOS6]) {
        rightBarItem.image = [UIImage imageNamed:@"Close"];
    }
    else {
        rightBarItem.image = [[UIImage imageNamed:@"Close"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    rightBarItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        HPSettingsViewController* settingsVC = [[HPSettingsViewController alloc] initWithNibName: @"HPSettingsViewController" bundle: nil];
        [self.navigationController pushViewController: settingsVC animated: YES];
        return [RACSignal empty];
    }];
    
    self.navigationItem.rightBarButtonItem = rightBarItem;
}


#pragma mark Configures

- (void)configureNavigationBar {
    [[RACSignal combineLatest:@[RACObserve(self, cellPoint.editUserPointMode), RACObserve(self, navigationController.navigationBar)]] subscribeNext:^(RACTuple *x) {
        RACTupleUnpack(NSNumber *editUserPointMode, UINavigationBar *navigationBar) = x;
        if (editUserPointMode.boolValue) {
            [navigationBar configureTranslucentNavigationBar];
        }
        else {
            [navigationBar configureOpaqueNavigationBar];
        }
    }];
}

- (void)configurePageControl {
    @weakify(self);
    [[self.pageController rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(UIPageControl *pageControl) {
        @strongify(self);
        self.pageController.currentPage = pageControl.currentPage;
        [self.currentUserCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:pageControl.currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }];
    RAC(self.pageController, currentPage) = [RACObserve(self.currentUserCollectionView, contentOffset) map:^id(NSValue *value) {
        CGPoint contentOffset = [value CGPointValue];
        NSUInteger page = (NSUInteger) (floor((contentOffset.x - 320 / 2) / 320) + 1);

        return @(page);
    }];
}

- (void)configureBottomMenu {
    @weakify(self);

    RACSignal *yourHavePoint = [RACObserve(self, currentUser.point) map:^id(id value) {
        return @(value!=nil);
    }];
    //По умолчанию никто не любит твой пост, как мило =)
    RACSignal *nobodyLikeYourPost = [[RACSignal return:@YES] concat:[self.usersLikeYourPost map:^id(NSArray *value) {
        return @(value.count == 0);
    }]];
    RACSignal *needShowLikesOfYourPost = [RACObserve(self, pageController.currentPage) map:^id(NSNumber *index) {
        return @(index.intValue == 0);
    }];

    RACSignal *needShowBottomMenu = [[RACSignal combineLatest:@[RACObserve(self, pageController.currentPage), RACObserve(self, cellPoint.editUserPointMode), RACObserve(self, currentUser.point.pointId)]] map:^id(id value) {
        RACTupleUnpack(NSNumber *index, NSNumber *editMode, UserPoint *userPoint) = value;
        return @((index.intValue == 0 && userPoint != nil) || index.intValue == 1);
    }];

    //Properties
    RAC(self, personalDataLabel.text) = [RACObserve(self, pageController.currentPage) map:^id(NSNumber *index) {
        return (index.intValue == 0) ? NSLocalizedString(@"YOUR_POINT_LIKES", nil) : NSLocalizedString(@"YOUR_PHOTO_ALBUM_AND_DATA", nil);
    }];

    RAC(self, personalDataDownImgView.hidden) = needShowLikesOfYourPost;
    RAC(self, bottomView.hidden) = [needShowBottomMenu not];
    RAC(self, bottomNobodyLikeLabel.hidden) = [[[RACSignal combineLatest:@[yourHavePoint ,nobodyLikeYourPost, needShowLikesOfYourPost]] and] not];
    RAC(self, bottomLikedView.hidden) = [[[RACSignal combineLatest:@[yourHavePoint, [nobodyLikeYourPost not], needShowLikesOfYourPost]] and] not];

    [self.usersLikeYourPost subscribeNext:^(RACTuple *usersTuple) {
        @strongify(self);
        for (UIView *view in [self.bottomLikedView subviews])
            [view removeFromSuperview];
        if (usersTuple.count > 0) {
            NSArray *arraySlice = [usersTuple.allObjects subarrayWithRange:NSMakeRange(0, usersTuple.count > 4 ? 4 : usersTuple.count)];

            @strongify(self);
            NSMutableDictionary *constraintViewDictionary = @{}.mutableCopy;
            for (User *user in arraySlice) {
                HPAvatarView *avatarView = [HPAvatarView avatarViewWithUser:user];
                avatarView.frame = (CGRect) {0, 0, 33, 33};
                avatarView.translatesAutoresizingMaskIntoConstraints = NO;
                constraintViewDictionary[[NSString stringWithFormat:@"avatarView_%d", rand() % 100000]] = avatarView;
                [self.bottomLikedView addSubview:avatarView];
            }
            if (constraintViewDictionary.count) {
                NSMutableString *horizontalConstraintFormat = @"H:".mutableCopy;

                for (NSString *key in constraintViewDictionary) {
                    [self.bottomLikedView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[%@(32)]", key]
                                                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                                                 metrics:nil
                                                                                                   views:constraintViewDictionary]];
                    [horizontalConstraintFormat appendFormat:@"[%@(32)]-(4)-", key];


                }
                [horizontalConstraintFormat appendString:@"|"];
                [self.bottomLikedView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horizontalConstraintFormat
                                                                                             options:0
                                                                                             metrics:nil
                                                                                               views:constraintViewDictionary]];
            }

        }


    }];
}

- (void)configureCurrentUsersForCells {
    [[RACSignal combineLatest:@[RACObserve(self, currentUser), RACObserve(self, cellPoint)]] subscribeNext:^(RACTuple *x) {
        RACTupleUnpack(User *currentUser, HPCurrentUserPointCollectionViewCell *cellPoint) = x;
        cellPoint.currentUser = currentUser;
    }];
    [[RACSignal combineLatest:@[RACObserve(self, currentUser), RACObserve(self, cellUser)]] subscribeNext:^(RACTuple *x) {
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

#pragma mark RACSignals

- (RACSignal *)usersLikeYourPost {
    if(!_usersLikeYourPost) {
        @weakify(self);
        RACSignal * getLikesFromServer  = [[[HPRequest getLikedUserOfPoint:self.currentUser.point] deliverOn:[RACScheduler scheduler]] flattenMap:^RACStream *(id value) {
            if (value)
                return [RACSignal return:value];
            else
                return [RACSignal empty];
        }];

        _usersLikeYourPost = [[[[[[[[RACObserve(self, currentUser.point.pointId) deliverOn:[RACScheduler scheduler]] filter:^BOOL(id value) {
            return (value != nil);
        }] take:1] map:^id(id value) {
            return self.currentUser.point.likedBy;
        }] concat:getLikesFromServer] deliverOn:[RACScheduler mainThreadScheduler]] replayLast] catchTo:[RACSignal empty]];
    }
    return _usersLikeYourPost;
}


@end
