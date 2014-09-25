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

#define CELLS_COUNT 20  //  for test purposes only remove on production
#define SWITCH_BOTTOM_SHIFT 16
#define HIDE_FILTER_ANIMATION_SPEED 0.5
#define PORTION_OF_DATA 7
#define CONSTRAINT_TABLEVIEW_HEIGHT 416
#define kNavBarDefaultPosition CGPointMake(160,64)

@implementation HPRootViewController {
    BOOL isFirstLoad;
}

#pragma mark - controller view delegate -

- (void)viewDidLoad
{
    [super viewDidLoad];
    isFirstLoad = YES;
    self.isNeedScrollToIndex = NO;
    [self createSwitch];
    [self addPullToRefresh];
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
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self configureNavigationBar];
    [self registerNotification];
    [self updateCurrentView];
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    isFirstLoad = NO;
    if (self.isNeedScrollToIndex) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
        [self.mainListTable reloadData];
        [self.mainListTable scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    self.isNeedScrollToIndex = NO;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterNotification];
    self.allUsers.delegate = nil;
}


- (void) registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrentView) name:kNeedUpdateUsersListViews object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserFilterCities:) name:kNeedUpdateFilterCities object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupFilterSendResults:) name:kNeedUpdateUserFilterData object:nil];
}


- (void) unregisterNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNeedUpdateUsersListViews object:nil];
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
    int msgsCount = [[DataStorage sharedDataStorage] allUnreadMessagesCount : nil];
    if (msgsCount > 0) {
        if(self.notificationView)
            [self.notificationView removeFromSuperview];
        self.notificationView = nil;
        self.notificationView = [Utils getNotificationViewForText:[NSString stringWithFormat:@"%d", msgsCount]];
        self.notificationView.userInteractionEnabled = NO;
    }
    [_chatsListButton addSubview: _notificationView];
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
    [self hideNotificationBadge];
    HPChatListViewController* chatList = [[HPChatListViewController alloc] initWithNibName: @"HPChatListViewController" bundle: nil];
    _crossDissolveAnimationController.viewForInteraction = chatList.view;
    [self.navigationController pushViewController:chatList animated:YES];
    _crossDissolveAnimationController.viewForInteraction = nil;
}


#pragma mark - filter button tap handler -


- (IBAction) filterButtonTap: (id)sender
{
    HPFilterSettingsViewController* filter = [[HPFilterSettingsViewController alloc] initWithNibName: @"HPFilterSettings" bundle: nil];
    filter.delegate = self;
    _crossDissolveAnimationController.viewForInteraction = filter.view;
    [self.navigationController pushViewController:filter animated:YES];
    _crossDissolveAnimationController.viewForInteraction = nil;
}

- (void) updateCurrentView {
    self.navigationItem.title = [Utils getTitleStringForUserFilter];
    if (_bottomSwitch.switchState) {
        self.allUsers = [[DataStorage sharedDataStorage] allUsersWithPointFetchResultsController];
    } else {
        self.allUsers = [[DataStorage sharedDataStorage] allUsersFetchResultsController];
    }
    self.allUsers.delegate = self;
    [self.mainListTable reloadData];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller;
{
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
   // [self.mainListTable beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            // your code for insert
//            break;
//        case NSFetchedResultsChangeDelete:
//            // your code for deletion
//            break;
//    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{

//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [self.mainListTable insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//
//        case NSFetchedResultsChangeDelete:
//            [self.mainListTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//
//        case NSFetchedResultsChangeUpdate: {
//            User *user = [self.allUsers objectAtIndexPath:indexPath];
//            [(HPMainViewListTableViewCell *) [self.mainListTable cellForRowAtIndexPath:indexPath] configureCell:user];
//        }
//            break;
//
//        case NSFetchedResultsChangeMove:
//            [self.mainListTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [self.mainListTable insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
   // [self.mainListTable endUpdates];
    [self.mainListTable reloadData];
}


#pragma mark - update user filter

-(void) updateUserFilterCities :(NSNotification *) notification {
    NSArray *cities = [notification.userInfo objectForKey:@"cities"];
    
    [[DataStorage sharedDataStorage] setAndSaveCityToUserFilter:cities[0]];
    
}

#pragma mark - pull-to-refresh   

- (void) addPullToRefresh {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.mainListTable addSubview:refreshControl];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [self makeUsersRequest];
    [refreshControl endRefreshing];
    [self.mainListTable reloadData];
}

- (void) makeUsersRequest {
    [[HPBaseNetworkManager sharedNetworkManager] getPointsRequest:0];
    [[HPBaseNetworkManager sharedNetworkManager] getUsersRequest:0];
}

#pragma mark - scroll view


- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (!isFirstLoad) {
        CGFloat scrollPosition = self.mainListTable.contentSize.height - self.mainListTable.frame.size.height - self.mainListTable.contentOffset.y;
        if (scrollPosition < -40)
        {
            if (!self.bottomActivityView.isAnimating) {
                [self.bottomActivityView startAnimating];
                User *user = [[self.allUsers fetchedObjects] lastObject];
                [[HPBaseNetworkManager sharedNetworkManager] getPointsRequest:[user.userId intValue]];
                [[HPBaseNetworkManager sharedNetworkManager] getUsersRequest:[user.userId intValue]];
                [self.mainListTable reloadData];
            }
        } else {
            if (self.bottomActivityView.isAnimating) {
                [self.bottomActivityView stopAnimating];
            }
        }
    }
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
    HPMainViewListTableViewCell *mCell = [tableView dequeueReusableCellWithIdentifier: mainCellId];
    if (!mCell)
        mCell = [[HPMainViewListTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: mainCellId];

    User *user = [self.allUsers objectAtIndexPath:indexPath];
    [mCell configureCell: user];
    return mCell;
}


- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
    HPUserCardViewController* card = [[HPUserCardViewController alloc] initWithNibName: @"HPUserCardViewController" bundle: nil];
    card.onlyWithPoints = _bottomSwitch.switchState;
    card.current = indexPath.row;
    card.delegate = self;
    
    [self.navigationController pushViewController: card animated: YES];
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
    NSLog(@"switched into left");
    NSLog(@"switcher state = %d", _bottomSwitch.switchState);
}


- (void) switchedToRight
{
    [self updateCurrentView];
    NSLog(@"switched into right");
    NSLog(@"switcher state = %d", _bottomSwitch.switchState);
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
    NSLog(@"%f", velocity.y);
    if (velocity.y > 0)
    {
        //if (_filterGroupView.frame.origin.y != [self topFilterBorder])
        //    return;

       [self showFilters];
    }

    if (velocity.y < 0)
    {
        NSLog(@"%f", [self bottomFilterBorder]);
        
        //if (_filterGroupView.frame.origin.y != [self bottomFilterBorder])
        //    return;

        [self hideFilters];
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
    NSLog(@"send genders = %@", genders);
    NSDictionary *filterParams = [[NSDictionary alloc] initWithObjectsAndKeys: uf.maxAge, @"maxAge", uf.minAge, @"minAge", [NSNumber numberWithFloat:0], @"viewType", genders, @"genders",uf.city.cityId, @"cityIds", nil];
     [[HPBaseNetworkManager sharedNetworkManager] makeUpdateCurrentUserFilterSettingsRequest:filterParams];
}

#pragma mark - reload on filter change 

- (void) setupFilterSendResults :(NSNotification *)notification {
    NSLog(@"%@", notification.userInfo);
    NSLog(@"%@", [notification.userInfo objectForKey:@"status"]);
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

#pragma mark - sync position
- (void) syncronizePosition : (NSInteger) currentPosition {
    self.isNeedScrollToIndex = YES;
    self.currentIndex = currentPosition;
}

@end
