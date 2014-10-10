//
//  HPUserCardViewController.m
//  HightPoint
//
//  Created by Andrey Anisimov on 13.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//



#import "HPUserCardViewController.h"
#import "Utils.h"
#import "UIImage+HighPoint.h"
#import "UINavigationController+HighPoint.h"
#import "UIViewController+HighPoint.h"
#import "UILabel+HighPoint.h"
#import "UIView+HighPoint.h"
#import "UIDevice+HighPoint.h"
#import "DataStorage.h"
#import "User.h"
#import "UIButton+HighPoint.h"
#import "HPChatViewController.h"

#import "HPBaseNetworkManager+Users.h"
#import "HPBaseNetworkManager+Points.h"
#import "HPBaseNetworkManager+Reference.h"
#import "NotificationsConstants.h"
#import "ModalAnimation.h"
#import "HPUserCardUICollectionViewCell.h"
#import "HPChatListViewController.h"

//#define ICAROUSEL_ITEMS_COUNT 50
//#define ICAROUSEL_ITEMS_WIDTH 264.0
#define GREENBUTTON_BOTTOM_SHIFT 50
#define SPACE_BETWEEN_GREENBUTTON_AND_INFO 40
#define FLIP_ANIMATION_SPEED 0.5
//#define CONSTRAINT_TOP_FOR_CAROUSEL 76
//#define CONSTRAINT_WIDE_TOP_FOR_CAROUSEL 80
//#define CONSTRAINT_HEIGHT_FOR_CAROUSEL 340



@implementation HPUserCardViewController {
     BOOL isFirstLoad;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    isFirstLoad = YES;
    self.currentIndex = 0;
    [self initObjects];
    
    [self addPullToRefresh];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.translucent = NO;
    [self registerNotification];
    if (self.onlyWithPoints) {
        usersArr = [[[DataStorage sharedDataStorage] allUsersWithPointFetchResultsController] fetchedObjects];
    } else {
        usersArr = [[[DataStorage sharedDataStorage] allUsersFetchResultsController] fetchedObjects];
    }
    self.navigationItem.title = [Utils getTitleStringForUserFilter];
    [self updateNotificationViewCount];
    _modalAnimationController = [[ModalAnimation alloc] init];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    self.currentIndex = self.current;
    NSLog(@"current = %d", self.current);
    self.usersCollectionView.delegate = self;
    self.usersCollectionView.dataSource = self;
    if (self.current == 0) {
        // [self.usersCollectionView setContentOffset:CGPointMake(0, ) animated:NO];
    } else {
        
        if (![UIDevice hp_isWideScreen]) {
            [self.usersCollectionView setContentOffset:CGPointMake(0, (428 * self.current) - 0) animated:NO];// 64
        }
        
        if (self.usersCollectionView.contentSize.height <= 428 * (self.current - 1) ) {
            [self.usersCollectionView setContentOffset:CGPointMake(0, (428 * self.current) - 0) animated:NO];
        } else {
            [self.usersCollectionView setContentOffset:CGPointMake(0, (428 * self.current)) animated:NO];
        }
    }
    isFirstLoad = NO;
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterNotification];
}

#pragma mark - init objects

- (void) initObjects
{
    [self createNavigationItem];
    [self.usersCollectionView registerNib:[UINib nibWithNibName:@"HPUserCardUICollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"UserCardIdentif"];
    
    
}

#pragma mark - navigation bar

- (void) createNavigationItem
{
    UIBarButtonItem* chatlistButton = [self createBarButtonItemWithImage: [UIImage imageNamed:@"Bubble"]
                                                         highlighedImage: [UIImage imageNamed:@"Bubble Tap"]
                                                                  action: @selector(chatsListTaped:)];
    [chatlistButton.customView addSubview: _notificationView];
    
    self.navigationItem.rightBarButtonItem = chatlistButton;
    
    UIBarButtonItem* backButton = [self createBarButtonItemWithImage:[UIImage imageNamed:@"Close.png"]
                                                     highlighedImage:[UIImage imageNamed:@"Close Tap.png"]
                                                              action:@selector(backButtonTaped:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
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


- (UIBarButtonItem*) createBarButtonItemWithImage: (UIImage*) image
                                  highlighedImage: (UIImage*) highlighedImage
                                           action: (SEL) action
{
    UIButton* newButton = [UIButton buttonWithType: UIButtonTypeCustom];
    newButton.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [newButton setBackgroundImage: image forState: UIControlStateNormal];
    [newButton setBackgroundImage: highlighedImage forState: UIControlStateHighlighted];
    [newButton addTarget: self
                  action: action
        forControlEvents: UIControlEventTouchUpInside];
    
    UIBarButtonItem* newbuttonItem = [[UIBarButtonItem alloc] initWithCustomView: newButton];
    
    return newbuttonItem;
}

#pragma mark - pull-to-refresh

- (void) addPullToRefresh {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.usersCollectionView addSubview:refreshControl];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [[HPBaseNetworkManager sharedNetworkManager] getPointsRequest:1];
    [[HPBaseNetworkManager sharedNetworkManager] getUsersRequest:1];
    [refreshControl endRefreshing];
    [self.usersCollectionView reloadData];
}

#pragma mark - open chat
- (void) openChatControllerWithUser : (NSInteger) userIndex {
    HPChatViewController *chatController = [[HPChatViewController alloc] initWithNibName:@"HPChatViewController" bundle:nil];
    //TODO: how to add user as a contact (API)?
    // chatController.contact = contact;
    [self.navigationController pushViewController:chatController animated:YES];
}

#pragma mark - scroll view


- (void) scrollViewDidScroll:(UIScrollView *)scrollView {

    if (!isFirstLoad) {
        CGFloat scrollPosition = self.usersCollectionView.contentSize.height - self.usersCollectionView.frame.size.height - self.usersCollectionView.contentOffset.y;
        if (scrollPosition < -86)
        {
            if (!self.bottomActivityView.isAnimating) {
                [self.bottomActivityView startAnimating];
                User *user = [usersArr lastObject];
                [[HPBaseNetworkManager sharedNetworkManager] getPointsRequest:[user.userId integerValue]];
                [[HPBaseNetworkManager sharedNetworkManager] getUsersRequest:[user.userId integerValue]];
                [self.usersCollectionView reloadData];
            }
        } else {
            if (self.bottomActivityView.isAnimating) {
                [self.bottomActivityView stopAnimating];
            }
        }
    }
}
- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGRect visibleRect = (CGRect){.origin = self.usersCollectionView.contentOffset, .size = self.usersCollectionView.bounds.size};
    CGPoint visiblePoint = CGPointMake(CGRectGetMidX(visibleRect), CGRectGetMidY(visibleRect));
    NSIndexPath *visibleIndexPath = [self.usersCollectionView indexPathForItemAtPoint:visiblePoint];
    
    self.currentIndex = visibleIndexPath.row;
}

#pragma mark - Tap events -
- (void) chatsListTaped: (id) sender
{
    HPChatListViewController* chatList = [[HPChatListViewController alloc] initWithNibName: @"HPChatListViewController" bundle: nil];
    [self.navigationController pushViewController:chatList animated:YES];
}

- (void) backButtonTaped: (id) sender
{
    self.usersCollectionView.delegate = nil;
    [self.navigationController popViewControllerAnimated: YES];
    if ([self.delegate respondsToSelector:@selector(syncronizePosition:)]) {
        [self.delegate syncronizePosition:self.currentIndex];
    }
}

#pragma mark - Buttons pressed -


- (IBAction)writeMsgTap:(id)sender {
    NSLog(@"write");
}


- (IBAction) infoButtonPressed: (id)sender
{
    //[self animationViewsUp];
}


#pragma mark - notifications
- (void) registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePointLike) name:kNeedUpdatePointLike object:nil];
}

- (void) unregisterNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNeedUpdatePointLike object:nil];

}

- (void) updatePointLike {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^
    {
        @strongify(self);
        [self.usersCollectionView reloadData];
    });
}

#pragma mark - uicollection view

#pragma mark - UICollectionView Datasource
// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return usersArr.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HPUserCardUICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"UserCardIdentif" forIndexPath:indexPath];
    cell.delegate = self;
    [cell configureCell: [usersArr objectAtIndex:indexPath.row]];
    cell.tag = indexPath.row;
    return cell;
}

/*- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    User * usr = [usersArr objectAtIndex:indexPath.row];
    if(usr) {
        [[HPBaseNetworkManager sharedNetworkManager] makeReferenceRequest:[[DataStorage sharedDataStorage] prepareParamFromUser:usr]];
    }
    HPUserInfoViewController* uiController = [[HPUserInfoViewController alloc] initWithNibName: @"HPUserInfoViewController" bundle: nil];
    uiController.user = [usersArr objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:uiController animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(320, 418);
}


- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


#pragma mark - Pagination
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    float currentOffset = scrollView.contentOffset.y;
    float targetOffset = targetContentOffset->y;
    float pageWidth = 418 + 10; // h + space
    float newTargetOffset = 0;
    if (targetOffset > currentOffset){
        newTargetOffset = ceilf(currentOffset / pageWidth) * pageWidth ;
    } else {
        newTargetOffset = floorf(currentOffset / pageWidth) * pageWidth;
    }
    if (newTargetOffset < 0) {
        newTargetOffset = 0;
    } else if (newTargetOffset >= (scrollView.contentSize.height - 400)) {
        newTargetOffset = scrollView.contentSize.height;
    }
    
    targetContentOffset->y = currentOffset;
    [scrollView setContentOffset:CGPointMake(0, newTargetOffset) animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    //HPUserCardUICollectionViewCell* currentCell = ([[collectionView visibleCells]count] > 0) ? [[collectionView visibleCells] objectAtIndex:0] : nil;
    
    //if(cell != nil){
        //self.currentIndex = [collectionView indexPathForCell:currentCell].row;
    //}
    //NSLog(@"current index for sync = %d", self.currentIndex);
}



@end
