//
//  HPRootViewController.m
//  HightPoint
//
//  Created by Andrey Anisimov on 22.04.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//


#import "HPRootViewController.h"
#import "HPBaseNetworkManager+CurrentUser.h"
#import "HPBaseNetworkManager+Users.h"
#import "HPBaseNetworkManager+Points.h"
#import "HPMainViewListTableViewCell.h"
#import "Utils.h"
#import "UIImage+HighPoint.h"
#import "UINavigationController+HighPoint.h"
#import "UIDevice+HighPoint.h"
#import "UILabel+HighPoint.h"
#import "DataStorage.h"
#import "HPChatListViewController.h"
#import "HPCurrentUserViewController.h"
#import "NotificationsConstants.h"
#import "User.h"
#import "Career.h"
#import "Education.h"
#import "URLs.h"
#import <QuartzCore/QuartzCore.h>
#import "HPUserCardViewController.h"
#import "HPSelectPopularCityViewController.h"
#import "UIButton+ExtendedEdges.h"
#import "UINavigationBar+HighPoint.h"
#import "HPRequest+Users.h"

#define MIN_SCROLL_BOTTOM_PIXEL_TO_LOAD 200

#define CELLS_COUNT 20  //  for test purposes only remove on production
#define SWITCH_BOTTOM_SHIFT 16
#define HIDE_FILTER_ANIMATION_SPEED 0.25
#define HIDE_BLEND_ANIMATION_SPEED 0.15
#define PORTION_OF_DATA 7
#define CONSTRAINT_TABLEVIEW_HEIGHT 416
static int const refreshTag = 111;
static NSString *mainCellId = @"maincell";
#define kNavBarDefaultPosition CGPointMake(160,64)

@interface HPRootViewController()
@property (nonatomic, retain) HPFilterSettingsViewController* filterViewController;
@property (nonatomic, retain) NSMutableArray* tableArray;
@property (nonatomic, retain) UIImageView *refreshSpinnerView;

//May be some trash
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *sendFilterBtn;

@property (nonatomic, strong) CABasicAnimation* rotationAnimation;
@property (nonatomic, weak) IBOutlet UIButton* chatsListButton;
@property (nonatomic, weak) IBOutlet UIView* filterGroupView;
@property (nonatomic, weak) IBOutlet UITableView *mainListTable;
@property (nonatomic, strong) NSFetchedResultsController *allUsers;
@property (nonatomic, strong) UIView *notificationView;
@property (nonatomic, assign) CGRect savedFrame;
@property (assign, nonatomic) BOOL isNeedScrollToIndex;
@property (assign, nonatomic) int currentIndex;
@property (weak, nonatomic) IBOutlet UIButton *lensBtn;

@property (strong, nonatomic) HPFilterSettingsViewController *filterController;
@property (weak, nonatomic) IBOutlet HPSpinnerView *bottomSpinnerView;
@property (weak, nonatomic) IBOutlet UIImageView *blendImageView;
@property (nonatomic, retain) IBOutlet HPSwitchViewController *bottomSwitch;

@end

@implementation HPRootViewController

#pragma mark - controller view delegate -

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureSwitchViewController];
    [self configureFilterViewController];
    [self configureTableViewData];
    [self configureTableView:self.mainListTable withSignal:RACObserve(self, tableArray) andTemplateCell:[UINib nibWithNibName:@"HPMainViewListTableViewCell" bundle:nil]];
    [self configureSelectionTable];
    [self configureNextPageLoad];
    [self configurePullToRefresh];
    [self configureNavigationBar];
}

#pragma mark configures
- (void) configureFilterViewController {
    self.filterViewController = [[HPFilterSettingsViewController alloc] initWithNibName: @"HPFilterSettings" bundle: nil];
    self.filterViewController.view.frame = self.view.bounds;
    [self addChildViewController:self.filterViewController];
}

- (void) configureTableViewData{
    @weakify(self);
    RACSignal* changeUserFilterSignal = [RACSignal combineLatest:@[RACObserve(self, filterViewController.gender), RACObserve(self, filterViewController.fromAge),RACObserve(self, filterViewController.toAge),RACObserve(self, filterViewController.city), RACObserve(self, bottomSwitch.switchState)]];
    
    [[[changeUserFilterSignal doNext:^(id x) {
        self.tableArray = nil;
    }] throttle:0.1] subscribeNext:^(RACTuple* value) {
        @strongify(self);
        RACTupleUnpack(NSNumber* gender, NSNumber* fromAge,NSNumber* toAge,City* filterCity, NSNumber* onlyPoint) = value;
        [[[HPRequest getUsersWithCity:filterCity withGender:gender.unsignedIntegerValue fromAge:fromAge.unsignedIntegerValue toAge:toAge.unsignedIntegerValue withPoint:onlyPoint.boolValue afterUser:nil] takeUntil:[changeUserFilterSignal skip:1]] subscribeNext:^(NSArray* x) {
            @strongify(self);
            self.tableArray = [x mutableCopy];
        }];
    }];
}

- (void) configureSelectionTable{
    @weakify(self);
    [self.selectRowSignal subscribeNext:^(User* x) {
        @strongify(self);
        HPUserCardViewController* userCardViewController = [[HPUserCardViewController alloc] initWithTableArraySignal:RACObserve(self,tableArray) andSelectedUser:x];
        [userCardViewController.changeViewedUserCard subscribeNext:^(User* x) {
            NSIndexPath* path = [NSIndexPath indexPathForRow:[self.tableArray indexOfObject:x] inSection:0];
            [self.mainListTable reloadData];
            [self.mainListTable scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }];
        [userCardViewController.needLoadNextPage subscribeNext:^(User* x) {
            @strongify(self);
            [self loadNextPageAfterUser:x];
        }];
        [self.navigationController pushViewController:userCardViewController animated:YES];
    }];
}

- (void) configureNextPageLoad{
    @weakify(self);
    RACSignal *contentOffsetSignal = [[RACObserve(self.mainListTable, contentOffset) subscribeOn:[RACScheduler scheduler]] deliverOn:[RACScheduler scheduler]];
    [[[[contentOffsetSignal map:^id(id value) {
        @strongify(self);
        CGFloat offset = [value CGPointValue].y;
        if(offset > 0){
            return @(offset > self.mainListTable.contentSize.height - self.mainListTable.frame.size.height - MIN_SCROLL_BOTTOM_PIXEL_TO_LOAD);
        }
        return @(NO);
    }] distinctUntilChanged] filter:^BOOL(NSNumber *x) {
        return x.boolValue;
    }] subscribeNext:^(NSNumber *x) {
        @strongify(self);
        [self loadNextPageAfterUser:[self.tableArray lastObject]];
    }];
}

- (void) configurePullToRefresh {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor clearColor];
    refreshControl.tag = refreshTag;
    UIView *refreshLoadingView = [[UIView alloc] initWithFrame:refreshControl.bounds];
    refreshLoadingView.backgroundColor = [UIColor clearColor];
    self.refreshSpinnerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Spinner"]];
    
    CGRect rect  = self.refreshSpinnerView.frame;
    rect.origin.x = refreshControl.bounds.size.width / 2 - self.refreshSpinnerView .frame.size.width/2;
    rect.origin.y = 10;
    self.refreshSpinnerView.frame = rect;
    
    
    [refreshLoadingView addSubview:self.refreshSpinnerView];
    
    [refreshControl addSubview:self.refreshSpinnerView];
    [refreshControl addTarget:self action:@selector(reloadAllData:) forControlEvents:UIControlEventValueChanged];
    [self.mainListTable addSubview:refreshControl];
}

- (void) configureNavigationBar
{
    self.navigationController.delegate = self;
    long int msgsCount = [[DataStorage sharedDataStorage] allUnreadMessagesCount:nil];
    if (msgsCount > 0) {
        if(self.notificationView)
            [self.notificationView removeFromSuperview];
        self.notificationView = [Utils getNotificationViewForText:[NSString stringWithFormat:@"%ld", msgsCount]];
        [self.navigationItem.rightBarButtonItem.customView addSubview:self.notificationView];
        self.notificationView.userInteractionEnabled = NO;
    } else {
        [self.notificationView removeFromSuperview];
    }
}

- (void) configureSwitchViewController
{
    if (!_bottomSwitch)
    {
        _bottomSwitch = [[HPSwitchViewController alloc] initWithNibName: @"HPSwitch" bundle: nil];
        [self addChildViewController: _bottomSwitch];
        [_filterGroupView addSubview: _bottomSwitch.view];
        
        CGRect rect = [UIScreen mainScreen].bounds;
        rect = CGRectMake(fabs(rect.size.width - _bottomSwitch.view.frame.size.width) / 2,
                          _filterGroupView.frame.size.height - SWITCH_BOTTOM_SHIFT - _bottomSwitch.view.frame.size.height,
                          _bottomSwitch.view.frame.size.width,
                          _bottomSwitch.view.frame.size.height);
        [_bottomSwitch positionSwitcher: rect];
    }
}

#pragma mark actions
- (void) reloadAllData:(UIRefreshControl*) refresh {
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = @0.0;
    rotationAnimation.toValue = @(M_PI * 2.0f);
    rotationAnimation.duration = 1.0f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 20;
    [self.refreshSpinnerView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    [refresh beginRefreshing];
    @weakify(self);
    [[HPRequest getUsersWithCity:self.filterViewController.city withGender:self.filterViewController.gender  fromAge:self.filterViewController.fromAge toAge:self.filterViewController.toAge withPoint:self.bottomSwitch.switchState afterUser:nil] subscribeNext:^(NSArray* x) {
        @strongify(self);
        self.tableArray = [x mutableCopy];
        [refresh endRefreshing];
        [self.refreshSpinnerView.layer performSelector:@selector(removeAllAnimations) withObject:nil afterDelay:1];
    }];
}

- (void) loadNextPageAfterUser:(User*) user{
    @weakify(self);
    [[HPRequest getUsersWithCity:self.filterViewController.city?[self.filterViewController.city MR_inContext:[NSManagedObjectContext MR_contextForCurrentThread]]:nil withGender:self.filterViewController.gender  fromAge:self.filterViewController.fromAge toAge:self.filterViewController.toAge withPoint:self.bottomSwitch.switchState afterUser:[user MR_inContext:[NSManagedObjectContext MR_contextForCurrentThread]]] subscribeNext:^(NSArray* x) {
        @strongify(self);
        @synchronized(self.tableArray){
            [self willChangeValueForKey:@"tableArray"];
            for(User* user in x){
                if(![self.tableArray containsObject:user]){
                    [self.tableArray addObject:user];
                }
            }
            [self didChangeValueForKey:@"tableArray"];
        }
    }];
}

- (void) resetPresentationViewCoontrollerContext{
    if([UIDevice hp_isIOS7]){
        [self.navigationController setModalPresentationStyle:UIModalPresentationNone];
    }
    else{
        self.navigationController.providesPresentationContextTransitionStyle = NO;
        self.navigationController.definesPresentationContext = NO;
    }
}


- (void) hideBottomFilterView
{
    [UIView animateWithDuration: HIDE_FILTER_ANIMATION_SPEED
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^
     {
         CGRect rect = _filterGroupView.frame;
         rect.origin.y = self.view.frame.size.height;
         _filterGroupView.frame = rect;
     }
                     completion: ^(BOOL finished)
     {
         self.blendImageView.alpha = 1.0f;
         [UIView beginAnimations:nil context:NULL];
         [UIView setAnimationDuration:HIDE_BLEND_ANIMATION_SPEED];
         self.blendImageView.alpha = 0.0f;
         [UIView commitAnimations];
     }];
}



- (void) showBottomFilterView
{
    [UIView animateWithDuration: HIDE_FILTER_ANIMATION_SPEED
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^
     {
         CGRect rect = _filterGroupView.frame;
         rect.origin.y = self.view.frame.size.height - _filterGroupView.frame.size.height;
         _filterGroupView.frame = rect;
     }
                     completion: ^(BOOL finished)
     {
         self.blendImageView.alpha = 0.0f;
         [UIView beginAnimations:nil context:NULL];
         [UIView setAnimationDuration:HIDE_BLEND_ANIMATION_SPEED];
         self.blendImageView.alpha = 1.0f;
         [UIView commitAnimations];
     }];
}

#pragma mark IBActions

- (IBAction) profileButtonPressedStart: (id) sender
{
    HPCurrentUserViewController* cuController = [[HPCurrentUserViewController alloc] initWithNibName: @"HPCurrentUserViewController" bundle: nil];
    UINavigationController* presentingController = [[UINavigationController alloc] initWithRootViewController:cuController];
    if([UIDevice hp_isIOS7]){
        [self.navigationController setModalPresentationStyle:UIModalPresentationCurrentContext];
    }
    else
    {
        self.navigationController.providesPresentationContextTransitionStyle = YES;
        self.navigationController.definesPresentationContext = YES;
        [presentingController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    }
    presentingController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentViewController:presentingController animated:YES completion:nil];
}

- (IBAction) filterButtonTap: (id)sender
{
    [self.view addSubview:self.filterViewController.view];
    self.filterViewController.view.alpha = 0;
    [self.filterViewController didMoveToParentViewController:self];
    @weakify(self);
    [UIView animateWithDuration:0.3 animations:^{
        @strongify(self);
        self.filterViewController.view.alpha = 1;
    } completion:^(BOOL finished) {
        @strongify(self);
        [self.filterViewController didMoveToParentViewController:self];
    }];
    
}

- (IBAction) bubbleButtonPressedStart: (id) sender
{
    //[self hideNotificationBadge];
    HPChatListViewController* chatList = [[HPChatListViewController alloc] initWithNibName: @"HPChatListViewController" bundle: nil];
    [self.navigationController pushViewController:chatList animated:YES];
}


#pragma mark scroll delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSArray *arr = [self.mainListTable indexPathsForVisibleRows];
    for(NSIndexPath *path in arr) {
        HPMainViewListTableViewCell *cell = (HPMainViewListTableViewCell*) [self.mainListTable cellForRowAtIndexPath:path];
        [cell hidePoint];
    }
}


- (void) scrollViewWillEndDragging: (UIScrollView*) scrollView
                      withVelocity: (CGPoint)velocity
               targetContentOffset: (inout CGPoint*) targetContentOffset
{
    if (velocity.y > 0)
    {
       [self hideBottomFilterView];
    }

    if (velocity.y < 0)
    {
        [self showBottomFilterView];
    }
}


#pragma mark view controller delegate

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    if(self.view.window == nil){
        self.overlayView = nil;
        self.activityIndicator = nil;
        self.rotationAnimation = nil;
        self.notificationView = nil;
    }
}

@end
