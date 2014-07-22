//
//  HPRootViewController.m
//  HightPoint
//
//  Created by Andrey Anisimov on 22.04.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "HPRootViewController.h"
#import "HPBaseNetworkManager.h"
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


//==============================================================================

#define CELLS_COUNT 20  //  for test purposes only remove on production
#define SWITCH_BOTTOM_SHIFT 16
#define HIDE_FILTER_ANIMATION_SPEED 0.5

//==============================================================================

@implementation HPRootViewController

#pragma mark - controller view delegate -

- (void)viewDidLoad
{
    [super viewDidLoad];

    //TODO : delete
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys: @"email", @"email", @"password", @"password", nil];
    [[HPBaseNetworkManager sharedNetworkManager] makeAutorizationRequest:params];
    [[HPBaseNetworkManager sharedNetworkManager] getCurrentUserRequest];

    //socket init
    NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:@"localhost",@"host", @"3002",@"port", nil];
    [[HPBaseNetworkManager sharedNetworkManager] initSocketIO:param];

    //

    [self configureNavigationBar];
    [self createSwitch];
    _crossDissolveAnimationController = [[CrossDissolveAnimation alloc] initWithNavigationController:self.navigationController];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self registerNotification];
    [self updateCurrentView];
    
//    NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:@"исп",@"query", @"20", @"limit", nil];
//    [[HPBaseNetworkManager sharedNetworkManager] findLanguagesRequest:param];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterNotification];
}


- (void) registerNotification {
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrentView) name:kNeedUpdateUsersListViews object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserFilterCities:) name:kNeedUpdateFilterCities object:nil];
}


- (void) unregisterNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNeedUpdateUsersListViews object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNeedUpdateFilterCities object:nil];
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
    [self.navigationController hp_configureNavigationBar];
    self.navigationController.delegate = self;

    self.notificationView = [Utils getNotificationViewForText: @"8"];
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
    
}


#pragma mark - filter button tap handler -


- (IBAction) filterButtonTap: (id)sender
{
    HPFilterSettingsViewController* filter = [[HPFilterSettingsViewController alloc] initWithNibName: @"HPFilterSettings" bundle: nil];
    _crossDissolveAnimationController.viewForInteraction = filter.view;
    [self.navigationController pushViewController:filter animated:YES];
}
- (void) updateCurrentView {
    NSLog(@"switcher state = %d", _bottomSwitch.switchState);
    
    self.navigationItem.title = [Utils getTitleStringForUserFilter];
    if (_bottomSwitch.switchState) {
        self.allUsers = [[DataStorage sharedDataStorage] allUsersWithPointFetchResultsController];
    } else {
        self.allUsers = [[DataStorage sharedDataStorage] allUsersFetchResultsController];
    }
    [self.mainListTable reloadData];
}




#pragma mark - update user filter

-(void) updateUserFilterCities :(NSNotification *) notification {
    NSArray *cities = [notification.userInfo objectForKey:@"cities"];
    for (City *city in cities) {
        [[DataStorage sharedDataStorage] setCityToUserFilter:city];
    }
}


#pragma mark - TableView and DataSource delegate -


- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return [[self.allUsers fetchedObjects] count];
}


- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    static NSString *mainCellId = @"maincell";
    HPMainViewListTableViewCell *mCell = [tableView dequeueReusableCellWithIdentifier: mainCellId];
    if (!mCell)
        mCell = [[HPMainViewListTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: mainCellId];
    User *user = [[self.allUsers fetchedObjects] objectAtIndex:indexPath.row];
    [mCell configureCell: user];
    if (indexPath.row == 3)
        [mCell makeAnonymous];
    
    return mCell;
}


- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
    HPUserCardViewController* card = [[HPUserCardViewController alloc] initWithNibName: @"HPUserCardViewController" bundle: nil];
    card.onlyWithPoints = _bottomSwitch.switchState;
    card.current = indexPath.row;
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
    if (velocity.y > 0)
    {
        if (_filterGroupView.frame.origin.y != [self topFilterBorder])
            return;
        
        [self hideFilters];
    }
    
    if (velocity.y < 0)
    {
        if (_filterGroupView.frame.origin.y != [self bottomFilterBorder])
            return;
        
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


@end
