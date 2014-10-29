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
@end

@implementation HPRootViewController {
    BOOL isFirstLoad;
    BOOL startUpdate;
}

#pragma mark - controller view delegate -

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureSwitchViewController];
    [self configureFilterViewController];
    [self configureTableViewData];
    [self configureTableView:self.mainListTable withSignal:RACObserve(self, tableArray) andTemplateCell:[UINib nibWithNibName:@"HPMainViewListTableViewCell" bundle:nil]];
    [self configureNextPageLoad];
    [self configurePullToRefresh];
    [RACObserve(self, bottomSwitch.switchState) subscribeNext:^(id x) {
        NSLog(@"Change state");
    }];
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

- (void) configureNextPageLoad{
    @weakify(self);
    RACSignal *contentOffsetSignal = [RACObserve(self.mainListTable, contentOffset) replayLast];
    [[[[[[contentOffsetSignal map:^id(id value) {
        @strongify(self);
        CGFloat offset = [value CGPointValue].y;
        if(offset > 0){
            return @(offset > self.mainListTable.contentSize.height - self.mainListTable.frame.size.height - MIN_SCROLL_BOTTOM_PIXEL_TO_LOAD);
        }
        return @(NO);
    }] distinctUntilChanged] filter:^BOOL(NSNumber *x) {
        return x.boolValue;
    }] subscribeOn:[RACScheduler scheduler]] deliverOn:[RACScheduler scheduler]] subscribeNext:^(NSNumber *x) {
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
    
    CGRect rect  = self.refreshSpinnerView .frame;
    rect.origin.x = refreshControl.bounds.size.width / 2 - self.refreshSpinnerView .frame.size.width/2;
    rect.origin.y = 10;
    self.refreshSpinnerView.frame = rect;
    
    
    [refreshLoadingView addSubview:self.refreshSpinnerView];
    
    [refreshControl addSubview:self.refreshSpinnerView];
    [refreshControl addTarget:self action:@selector(reloadAllData:) forControlEvents:UIControlEventValueChanged];
    [self.mainListTable addSubview:refreshControl];
}

- (void) configureSwitchViewController
{
    if (!_bottomSwitch)
    {
        _bottomSwitch = [[HPSwitchViewController alloc] initWithNibName: @"HPSwitch" bundle: nil];
        _bottomSwitch.delegate = self;
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
    [[HPRequest getUsersWithCity:self.filterViewController.city withGender:self.filterViewController.gender  fromAge:self.filterViewController.fromAge toAge:self.filterViewController.toAge withPoint:self.bottomSwitch.switchState afterUser:user] subscribeNext:^(NSArray* x) {
        @strongify(self);
        NSMutableArray *contents = [self mutableArrayValueForKey:@keypath(self, tableArray)];
        [contents addObjectsFromArray:x];
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

#pragma mark IBActions

- (IBAction) profileButtonPressedStart: (id) sender
{
    [self showNotificationBadge];
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

#pragma mark TRASH!

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar configureTranslucentNavigationBar];
    [self configureNavigationBar];
    if(!isFirstLoad)
        [self.mainListTable reloadData];
    self.mainListTable.hidden = YES;
    startUpdate = NO;
    isFirstLoad = NO;
    self.allUsers.delegate = self;
    
    self.mainListTable.hidden = NO;
    self.isNeedScrollToIndex = NO;
    [self.lensBtn setHitTestEdgeInsets:UIEdgeInsetsMake(-15, -15, -15, -15)];
    self.blendImageView.alpha = 1.0f;
    [self resetPresentationViewCoontrollerContext];
    [self.mainListTable registerNib:[UINib nibWithNibName:@"HPMainViewListTableViewCell" bundle:nil] forCellReuseIdentifier:mainCellId];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.allUsers.delegate = nil;
}




#pragma mark - Configure Navigation bar method -

- (void) configureNavigationBar
{
    self.navigationController.delegate = self;
    [self updateNotificationViewCount];
}

- (void) updateNotificationViewCount {
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

#pragma mark - Navigation bar button tap handler -








- (IBAction) bubbleButtonPressedStart: (id) sender
{
    //[self hideNotificationBadge];
    HPChatListViewController* chatList = [[HPChatListViewController alloc] initWithNibName: @"HPChatListViewController" bundle: nil];
    _crossDissolveAnimationController.viewForInteraction = chatList.view;
    [self.navigationController pushViewController:chatList animated:YES];
    _crossDissolveAnimationController.viewForInteraction = nil;
}




#pragma mark - pull-to-refresh   



- (void) removeRefreshControl {
    NSArray *views = [self.mainListTable subviews];
    for(UIView *v in views) {
        if(v.tag == refreshTag) {
            [v removeFromSuperview];
            break;
        }
    }
}

- (void) hideSpinnerView {
    self.bottomSpinnerView.hidden = YES;
}


#pragma mark - scroll view


- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSArray *arr = [self.mainListTable indexPathsForVisibleRows];
    for(NSIndexPath *path in arr) {
        HPMainViewListTableViewCell *cell = (HPMainViewListTableViewCell*) [self.mainListTable cellForRowAtIndexPath:path];
        [cell hidePoint];
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger lastSectionIndex = [tableView numberOfSections] - 1;
    //NSInteger lastRowIndex = [tableView numberOfRowsInSection:lastSectionIndex] - 1;
    NSInteger lastRowIndex = [[self.allUsers fetchedObjects] count] - 1;
    if ((indexPath.section == lastSectionIndex) && ((indexPath.row  == lastRowIndex - 4) )) {//|| (lastRowIndex - indexPath.row  == 4)
        // This is the last cell

        User *user = [[self.allUsers fetchedObjects] lastObject];
        [self loadNextPageAfterUser:user];
    }
}



#pragma mark - TableView and DataSource delegate -
#pragma mark - Notification view hide/show method -

- (void) hideNotificationBadge
{
    [UIView transitionWithView:[self navigationController].view
                      duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve //any animation
                    animations:^ {
                        self.notificationView.hidden = YES;
                    }
                    completion:^(BOOL finished){
                        
                    }];

}


- (void) showNotificationBadge
{
    [UIView transitionWithView:[self navigationController].view
                      duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve //any animation
                    animations:^ {
                        self.notificationView.hidden = NO;
                    }
                    completion:^(BOOL finished){

                    }];
}


#pragma mark - HPSwitch Delegate -


- (void) switchedToLeft
{
    [self.mainListTable reloadData];
}


- (void) switchedToRight
{
    [self.mainListTable reloadData];
}


#pragma mark - scroll delegate -


- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    [HPMainViewListTableViewCell makeCellReleased];
}


- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [HPMainViewListTableViewCell makeCellReleased];
}


- (void) scrollViewWillEndDragging: (UIScrollView*) scrollView
                      withVelocity: (CGPoint)velocity
               targetContentOffset: (inout CGPoint*) targetContentOffset
{
    if (velocity.y > 0)
    {
        //if (_filterGroupView.frame.origin.y != [self topFilterBorder])
        //    return;

       [self hideFilters];
    }

    if (velocity.y < 0)
    {
        
        //if (_filterGroupView.frame.origin.y != [self bottomFilterBorder])
        //    return;

        [self showFilters];
    }
}


#pragma mark - filter animation -

- (void) hideFilters
{
    [UIView animateWithDuration: HIDE_FILTER_ANIMATION_SPEED
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^
     {
         CGRect rect = _filterGroupView.frame;
         rect.origin.y = [self bottomFilterBorder];
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



- (void) showFilters
{
    [UIView animateWithDuration: HIDE_FILTER_ANIMATION_SPEED
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^
     {
         CGRect rect = _filterGroupView.frame;
         rect.origin.y = [self topFilterBorder];
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


- (CGFloat) topFilterBorder
{
    return self.view.frame.size.height - _filterGroupView.frame.size.height;
}


- (CGFloat) bottomFilterBorder
{
    return self.view.frame.size.height;
}


#pragma mark - filter resend

- (IBAction)sendFilterValue:(id)sender {
    [self showActivity];
    UserFilter *uf = [[DataStorage sharedDataStorage] getUserFilter];
    NSString *genders = @"";
    
    for (Gender *gender in [uf.gender allObjects]) {
        if ([gender.genderType isEqualToNumber:@2]) {
            genders = genders.length > 0 ? [genders stringByAppendingString: @",2"] : [genders stringByAppendingString: @"2"];
        }
        if ([gender.genderType isEqualToNumber:@1]) {
            genders = genders.length > 0 ? [genders stringByAppendingString: @",1"] : [genders stringByAppendingString: @"1"];
        }
    }

    NSDictionary *filterParams = [[NSDictionary alloc] initWithObjectsAndKeys: uf.maxAge, @"maxAge", uf.minAge, @"minAge", [NSNumber numberWithFloat:0], @"viewType", genders, @"genders",uf.city.cityId, @"cityIds", nil];
     [[HPBaseNetworkManager sharedNetworkManager] makeUpdateCurrentUserFilterSettingsRequest:filterParams];
}

#pragma mark - reload on filter change 

- (void) setupFilterSendResults :(NSNotification *)notification {
    NSNumber *status =  [notification.userInfo objectForKey:@"status"];
    if ([status isEqualToNumber:@1]) {
        self.mainListTable.hidden = NO;
        self.sendFilterBtn.hidden = YES;
        self.filterGroupView.hidden = NO;
    } else {
        self.mainListTable.hidden = YES;
        self.sendFilterBtn.hidden = NO;
        self.filterGroupView.hidden = YES;
    }
    [self hideActivity];
}




#pragma mark - delegate
- (void) showNavigationBar {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


#pragma mark - activity

- (void)showActivity {
    if(!self.overlayView)
        self.overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, [UIScreen mainScreen].applicationFrame.size.height +20) ];
    self.overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    if(!self.activityIndicator)
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.center = self.overlayView.center;
    [self.overlayView addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    [[[[[UIApplication sharedApplication]delegate] window] rootViewController].view addSubview:self.overlayView];
    //todo: disable buttons
}

- (void) hideActivity {
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
    self.activityIndicator = nil;
    [self.overlayView removeFromSuperview];
    self.overlayView = nil;
    //todo: enable buttons
}

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
