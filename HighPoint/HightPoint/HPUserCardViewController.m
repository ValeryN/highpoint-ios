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

@interface HPUserCardViewController()
@property (nonatomic, retain) NSFetchedResultsController* searchController;
@property (nonatomic, strong) UIView *notificationView;
@property (weak, nonatomic) IBOutlet UICollectionView *usersCollectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bottomActivityView;
@end

@implementation HPUserCardViewController {
     BOOL isFirstLoad;
}

- (instancetype) initWithController:(NSFetchedResultsController*) controller andSelectedUser:(User*) user{
    self = [super initWithNibName: @"HPUserCardViewController" bundle: nil];
    if (self) {
        self.changeViewedUserCard = [RACSubject subject];
        self.needLoadNextPage = [RACSubject subject];
        
        self.searchController = [[NSFetchedResultsController alloc] initWithFetchRequest:[controller.fetchRequest copy] managedObjectContext:controller.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        self.searchController.delegate = self;
        [self.searchController performFetch:nil];
        
        @weakify(self);
        [[RACObserve(self, usersCollectionView) filter:^BOOL(id value) {
            return value != nil;
        }] subscribeNext:^(UICollectionView* collection) {
            @strongify(self);
            [self configureCollectionView:collection withSignal:[RACSignal return:self.searchController] andTemplateCell:[UINib nibWithNibName:@"HPUserCardUICollectionViewCell" bundle:nil]];
            [[[RACObserve(collection, contentSize) skip:1] take:1] subscribeNext:^(id x) {
                @strongify(self);
                [collection scrollToItemAtIndexPath:[self.searchController indexPathForObject:user] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
            }];
        }];
        
        [[self.changeViewedUserCard distinctUntilChanged] subscribeNext:^(User* usr) {
            [[HPBaseNetworkManager sharedNetworkManager] makeReferenceRequest:[[DataStorage sharedDataStorage] prepareParamFromUser:usr]];
        }];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createNavigationItem];
    [self addPullToRefresh];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationItem.title = [Utils getTitleStringForUserFilter];
    [self updateNotificationViewCount];
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
- (void) openChatControllerWithUser : (User*) user {
    HPChatViewController *chatController = [[HPChatViewController alloc] initWithNibName:@"HPChatViewController" bundle:nil];
    Contact* contact = [Contact MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"user = %@",user]];
    if(contact){
        chatController.contact = contact;
        [self.navigationController pushViewController:chatController animated:YES];
    }
    else{
        //TODO: how to add user as a contact (API)?
        [[[UIAlertView alloc] initWithTitle:@"Not implemented" message:@"Not implenented on server \"AddContact\"" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
    }
}

#pragma mark - scroll view


- (void) scrollViewDidScroll:(UIScrollView *)scrollView {

    if (!isFirstLoad) {
        CGFloat scrollPosition = self.usersCollectionView.contentSize.height - self.usersCollectionView.frame.size.height - self.usersCollectionView.contentOffset.y;
        if (scrollPosition < -86)
        {
            if (!self.bottomActivityView.isAnimating) {
                
                //TODO: Load more users
                /*
                [self.bottomActivityView startAnimating];
                User *user = [usersArr lastObject];
                [[HPBaseNetworkManager sharedNetworkManager] getPointsRequest:[user.userId integerValue]];
                [[HPBaseNetworkManager sharedNetworkManager] getUsersRequest:[user.userId integerValue]];
                [self.usersCollectionView reloadData];
                 */
            }
        } else {
            if (self.bottomActivityView.isAnimating) {
                [self.bottomActivityView stopAnimating];
            }
        }
    }
    
    CGRect visibleRect = (CGRect){.origin = self.usersCollectionView.contentOffset, .size = self.usersCollectionView.bounds.size};
    CGPoint visiblePoint = CGPointMake(CGRectGetMidX(visibleRect), CGRectGetMidY(visibleRect));
    NSIndexPath *visibleIndexPath = [self.usersCollectionView indexPathForItemAtPoint:visiblePoint];
    if(visibleIndexPath){
        [self.changeViewedUserCard sendNext:[self.searchController objectAtIndexPath:visibleIndexPath]];
    }
    
    NSUInteger lastRowIndex = [self collectionView:self.usersCollectionView numberOfItemsInSection:0] - 1;
    if(lastRowIndex == visibleIndexPath.row){
        //Load on last cell
        [self.needLoadNextPage sendNext:[self.searchController objectAtIndexPath:visibleIndexPath]];
    }
}
- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGRect visibleRect = (CGRect){.origin = self.usersCollectionView.contentOffset, .size = self.usersCollectionView.bounds.size};
    CGPoint visiblePoint = CGPointMake(CGRectGetMidX(visibleRect), CGRectGetMidY(visibleRect));
    NSIndexPath *visibleIndexPath = [self.usersCollectionView indexPathForItemAtPoint:visiblePoint];

    NSUInteger lastRowIndex = [self collectionView:self.usersCollectionView numberOfItemsInSection:0] - 1;
    //Pull to load more
    if(lastRowIndex == visibleIndexPath.row){
        [self.needLoadNextPage sendNext:[self.searchController objectAtIndexPath:visibleIndexPath]];
    }
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
}


#pragma mark - uicollection view

#pragma mark - UICollectionView Datasource
// 1

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}


/*- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    User * usr = [self.searchController objectAtIndexPath:indexPath];
    HPUserInfoViewController* uiController = [[HPUserInfoViewController alloc] initWithNibName: @"HPUserInfoViewController" bundle: nil];
    uiController.user = usr;
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
        newTargetOffset = ceilf(currentOffset / pageWidth) * pageWidth - self.topLayoutGuide.length;
    } else {
        newTargetOffset = floorf(currentOffset / pageWidth) * pageWidth - self.topLayoutGuide.length;
    }
    if (newTargetOffset < -self.topLayoutGuide.length) {
        newTargetOffset = -self.topLayoutGuide.length;
    } else if (newTargetOffset >= (scrollView.contentSize.height - 400)) {
        newTargetOffset = scrollView.contentSize.height - self.topLayoutGuide.length;
    }
    
    targetContentOffset->y = currentOffset;
    [scrollView setContentOffset:CGPointMake(0, newTargetOffset) animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{

}



@end
