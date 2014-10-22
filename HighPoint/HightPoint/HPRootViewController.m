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

#define CELLS_COUNT 20  //  for test purposes only remove on production
#define SWITCH_BOTTOM_SHIFT 16
#define HIDE_FILTER_ANIMATION_SPEED 0.25
#define HIDE_BLEND_ANIMATION_SPEED 0.15
#define PORTION_OF_DATA 7
#define CONSTRAINT_TABLEVIEW_HEIGHT 416
static int const refreshTag = 111;
#define kNavBarDefaultPosition CGPointMake(160,64)

@implementation HPRootViewController {
    BOOL isFirstLoad;
    BOOL startUpdate;
}

#pragma mark - controller view delegate -

- (void)viewDidLoad
{
    [super viewDidLoad];
    isFirstLoad = YES;
    self.isNeedScrollToIndex = NO;
    [self createSwitch];
    
    _crossDissolveAnimationController = [[CrossDissolveAnimation alloc] initWithNavigationController:self.navigationController];
    if (![UIDevice hp_isWideScreen])
    {
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem: self.mainListTable
                                                              attribute: NSLayoutAttributeHeight
                                                              relatedBy: NSLayoutRelationEqual
                                                                 toItem: nil
                                                              attribute: NSLayoutAttributeHeight
                                                             multiplier: 1.0
                                                               constant: CONSTRAINT_TABLEVIEW_HEIGHT]];
    }
    self.bottomSpinnerView.hidden = YES;
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar configureTranslucentNavigationBar];
    [self configureNavigationBar];
    [self registerNotification];
    [self updateCurrentView];
    [self addPullToRefresh];
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
}
- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterNotification];
    self.allUsers.delegate = nil;
}


- (void) registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserFilterCities:) name:kNeedUpdateFilterCities object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupFilterSendResults:) name:kNeedUpdateUserFilterData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPullToRefresh) name:kNeedUpdatePullToRefreshInd object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideSpinnerView) name:kNeedHideSpinnerView object:nil];
}

- (void) unregisterNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNeedUpdateFilterCities object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNeedUpdateUserFilterData object:nil];
}

- (void) createSwitch
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


- (IBAction) profileButtonPressedStart: (id) sender
{
    [self showNotificationBadge];
    HPCurrentUserViewController* cuController = [[HPCurrentUserViewController alloc] initWithNibName: @"HPCurrentUserViewController" bundle: nil];
    [self.navigationController pushViewController:cuController animated:YES];
}


- (IBAction) bubbleButtonPressedStart: (id) sender
{
    //[self hideNotificationBadge];
    HPChatListViewController* chatList = [[HPChatListViewController alloc] initWithNibName: @"HPChatListViewController" bundle: nil];
    _crossDissolveAnimationController.viewForInteraction = chatList.view;
    [self.navigationController pushViewController:chatList animated:YES];
    _crossDissolveAnimationController.viewForInteraction = nil;
}


#pragma mark - filter button tap handler -


- (IBAction) filterButtonTap: (id)sender
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.filterController = [[HPFilterSettingsViewController alloc] initWithNibName: @"HPFilterSettings" bundle: nil];
    self.filterController.delegate = self;
    self.filterController.view.frame = self.view.bounds;
    [self.view addSubview:self.filterController.view];
    [self addChildViewController:self.filterController];
    [self.filterController didMoveToParentViewController:self];
}


- (void) updateCurrentView {
    startUpdate  = NO;
    self.navigationItem.title = [Utils getTitleStringForUserFilter];
    if (_bottomSwitch.switchState) {
        self.allUsers = [[DataStorage sharedDataStorage] allUsersWithPointFetchResultsController];
    } else {
        self.allUsers = [[DataStorage sharedDataStorage] allUsersFetchResultsController];
    }
    [self.mainListTable reloadData];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller;
{
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.mainListTable beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            // your code for insert
            break;
        case NSFetchedResultsChangeDelete:
            // your code for deletion
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{

    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.mainListTable insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.mainListTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate: {
            User *user = [self.allUsers objectAtIndexPath:indexPath];
            [(HPMainViewListTableViewCell *) [self.mainListTable cellForRowAtIndexPath:indexPath] configureCell:user];
        }
            break;

        case NSFetchedResultsChangeMove:
            [self.mainListTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.mainListTable insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
   [self.mainListTable endUpdates];
    //[self.mainListTable reloadData];
}


#pragma mark - update user filter

-(void) updateUserFilterCities :(NSNotification *) notification {
    NSArray *cities = [notification.userInfo objectForKey:@"cities"];
    
    [[DataStorage sharedDataStorage] setAndSaveCityToUserFilter:cities[0]];
    
}

#pragma mark - pull-to-refresh   

- (void) addPullToRefresh {
    [self removeRefreshControl];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor clearColor];
    refreshControl.tag = refreshTag;
    UIView *refreshLoadingView = [[UIView alloc] initWithFrame:refreshControl.bounds];
    refreshLoadingView.backgroundColor = [UIColor clearColor];
    UIImageView *spinner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Spinner"]];
    
    CGRect rect  = spinner.frame;
    rect.origin.x = refreshControl.bounds.size.width / 2 - spinner.frame.size.width/2;
    rect.origin.y = 10;
    spinner.frame = rect;
    
    
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = @0.0;
    rotationAnimation.toValue = @(M_PI * 2.0f);
    rotationAnimation.duration = 1.0f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    [spinner.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    
    
    [refreshLoadingView addSubview:spinner];
    
    [refreshControl addSubview:refreshLoadingView];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.mainListTable addSubview:refreshControl];
}
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

- (void)refresh:(UIRefreshControl *)refreshControl {
    
    [self makeUsersRequest];
    [refreshControl endRefreshing];
    //[self.mainListTable reloadData];
}

- (void) makeUsersRequest {
    if(_bottomSwitch.switchState)
        [[HPBaseNetworkManager sharedNetworkManager] getPointsRequest:0];
    else [[HPBaseNetworkManager sharedNetworkManager] getUsersRequest:0];
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

- (void) loadNextPageAfterUser:(User*) user{
    self.bottomSpinnerView.hidden = NO;
    [[HPBaseNetworkManager sharedNetworkManager] createTaskArray];
    if(_bottomSwitch.switchState)
        [[HPBaseNetworkManager sharedNetworkManager] getPointsRequest:[user.userId intValue]];
    else
        [[HPBaseNetworkManager sharedNetworkManager] getUsersRequest:[user.userId intValue]];
}

#pragma mark - TableView and DataSource delegate -


- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.allUsers sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    static NSString *mainCellId = @"maincell";
    HPMainViewListTableViewCell *mCell = [tableView dequeueReusableCellWithIdentifier: mainCellId forIndexPath:indexPath];
    if (!mCell)
        mCell = [[HPMainViewListTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: mainCellId];

    User *user = [self.allUsers objectAtIndexPath:indexPath];
    NSLog(@"city id %@", user.cityId);
    [mCell configureCell: user];
    return mCell;
}


- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
    HPMainViewListTableViewCell *mCell = (HPMainViewListTableViewCell*) [self.mainListTable cellForRowAtIndexPath:indexPath];
    [mCell hidePoint];
    
    HPUserCardViewController* card = [[HPUserCardViewController alloc] initWithController:self.allUsers andSelectedUser:[self.allUsers objectAtIndexPath:indexPath]];
    @weakify(self);
    [[[card.changeViewedUserCard takeUntil:[self rac_signalForSelector:@selector(viewWillAppear:)]] takeLast:1]
    subscribeNext:^(User* user) {
        @strongify(self);
        NSIndexPath* path = [self.allUsers indexPathForObject:user];
        [self.mainListTable reloadData];
        [self.mainListTable scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }];
    [[card.needLoadNextPage distinctUntilChanged] subscribeNext:^(User* x) {
        @strongify(self);
        [self loadNextPageAfterUser:x];
    }];
    
    [self.navigationController pushViewController: card animated: YES];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

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
    [self updateCurrentView];
    [self.mainListTable reloadData];
}


- (void) switchedToRight
{
    [self updateCurrentView];
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
        [self getNewFilteredUsers];
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


- (void) getNewFilteredUsers {
    [self makeUsersRequest];
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
