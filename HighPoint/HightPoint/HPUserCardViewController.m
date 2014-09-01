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

#import "HPBaseNetworkManager.h"
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
    
    NSLog(@"current = %d", self.current);
    if (self.current == 0) {
       // [self.usersCollectionView setContentOffset:CGPointMake(0, ) animated:NO];
    } else {
        
        if (![UIDevice hp_isWideScreen]) {
            [self.usersCollectionView setContentOffset:CGPointMake(0, (428 * self.current) - 64) animated:NO];
        }
        
        if (self.usersCollectionView.contentSize.height <= 428 * (self.current - 1) ) {
            [self.usersCollectionView setContentOffset:CGPointMake(0, (428 * self.current) - 128) animated:NO];
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
    self.usersCollectionView.delegate = self;
    self.usersCollectionView.dataSource = self;
}

#pragma mark - navigation bar

- (void) createNavigationItem
{
    UIBarButtonItem* chatlistButton = [self createBarButtonItemWithImage: [UIImage imageNamed:@"Bubble"]
                                                         highlighedImage: [UIImage imageNamed:@"Bubble Tap"]
                                                                  action: @selector(chatsListTaped:)];
    [self updateNotificationViewCount];
    [chatlistButton.customView addSubview: _notificationView];
    self.navigationItem.rightBarButtonItem = chatlistButton;
    
    UIBarButtonItem* backButton = [self createBarButtonItemWithImage: [UIImage imageNamed:@"Close.png"]
                                                     highlighedImage: [UIImage imageNamed:@"Close Tap.png"]
                                                              action: @selector(backbuttonTaped:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
}


- (void) updateNotificationViewCount {
    int msgsCount = [[DataStorage sharedDataStorage] allUnreadMessagesCount:nil];
    if (msgsCount > 0) {
        self.notificationView = [Utils getNotificationViewForText:[NSString stringWithFormat:@"%d", msgsCount]];
        self.notificationView.userInteractionEnabled = NO;
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
    [[HPBaseNetworkManager sharedNetworkManager] getPointsRequest:0];
    [[HPBaseNetworkManager sharedNetworkManager] getUsersRequest:0];
    [refreshControl endRefreshing];
    [self.usersCollectionView reloadData];
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
                [[HPBaseNetworkManager sharedNetworkManager] getPointsRequest:[user.userId intValue]];
                [[HPBaseNetworkManager sharedNetworkManager] getUsersRequest:[user.userId intValue]];
                [self.usersCollectionView reloadData];
            }
        } else {
            if (self.bottomActivityView.isAnimating) {
                [self.bottomActivityView stopAnimating];
            }
        }
    }
}

#pragma mark - Tap events -
- (void) chatsListTaped: (id) sender
{
    HPChatListViewController* chatList = [[HPChatListViewController alloc] initWithNibName: @"HPChatListViewController" bundle: nil];
    [self.navigationController pushViewController:chatList animated:YES];
}

- (void) backbuttonTaped: (id) sender
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
    dispatch_async(dispatch_get_main_queue(), ^
    {
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
    uiController.delegate = self;
    uiController.user = [usersArr objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:uiController animated:YES];
}
-(void) profileWillBeHidden {
    [self.navigationController setNavigationBarHidden:NO];
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
    HPUserCardUICollectionViewCell* currentCell = ([[collectionView visibleCells]count] > 0) ? [[collectionView visibleCells] objectAtIndex:0] : nil;
    
    if(cell != nil){
        self.currentIndex = [collectionView indexPathForCell:currentCell].row;
    }
    NSLog(@"current index for sync = %d", self.currentIndex);
}

//#pragma mark - Transitioning Delegate (Modal)
//-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
//    _modalAnimationController.type = AnimationTypePresent;
//    return _modalAnimationController;
//}
//
//-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
//    _modalAnimationController.type = AnimationTypeDismiss;
//    return _modalAnimationController;
//}
//- (void)profileWillBeHidden {
//    [self animationViewsDown];
//}
//- (void) animationViewsUp {
//    UIImage *captureImg = [Utils captureView:self.carouselView.currentItemView withArea:CGRectMake(0, 0, self.carouselView.currentItemView.frame.size.width, self.carouselView.currentItemView.frame.size.height)];
//    
//    //need get cell from left and right
//    UIView* leftView;
//    UIView* rightView;
//    
//    NSLog(@"%d",self.carouselView.currentItemIndex);
//    NSLog(@"%d",self.carouselView.numberOfItems);
//    
//    if(self.carouselView.currentItemIndex > 0 && self.carouselView.currentItemIndex < self.carouselView.numberOfItems && self.carouselView.currentItemIndex != self.carouselView.numberOfItems - 1) {
//        leftView = [self.carouselView itemViewAtIndex: self.carouselView.currentItemIndex-1];
//        rightView = [self.carouselView itemViewAtIndex: self.carouselView.currentItemIndex+1];
//    } else if(self.carouselView.currentItemIndex == 0) {
//        leftView = [self.carouselView itemViewAtIndex: self.carouselView.numberOfItems - 1];
//        rightView = [self.carouselView itemViewAtIndex: self.carouselView.currentItemIndex+1];
//    } else if(self.carouselView.currentItemIndex == self.carouselView.numberOfItems - 1) {
//        leftView = [self.carouselView itemViewAtIndex: self.carouselView.numberOfItems - 2];
//        rightView = [self.carouselView itemViewAtIndex: 0];
//    }
//    
//    UIImage *captureImgLeft = [Utils captureView:leftView withArea:CGRectMake(0, 0, leftView.frame.size.width, leftView.frame.size.height)];
//    UIImage *captureImgRight = [Utils captureView:rightView withArea:CGRectMake(0, 0, rightView.frame.size.width, rightView.frame.size.height)];
//    
//    self.captView = [[UIImageView alloc] initWithImage:captureImg];
//    self.captViewLeft = [[UIImageView alloc] initWithImage:captureImgLeft];
//    self.captViewRight = [[UIImageView alloc] initWithImage:captureImgRight];
//    
//    CGRect result = [self.view convertRect:self.carouselView.currentItemView.frame fromView:self.carouselView.currentItemView];
//    CGRect resultLeft = [self.view convertRect:leftView.frame fromView:leftView];
//    CGRect resultRight = [self.view convertRect:rightView.frame fromView:rightView];
//    self.captView.frame = result;
//    self.captViewLeft.frame = resultLeft;
//    self.captViewRight.frame = resultRight;
//    self.carouselView.hidden = YES;
//    [self.view addSubview:self.captView];
//    [self.view addSubview:self.captViewLeft];
//    [self.view addSubview:self.captViewRight];
//    
//    CGRect originalFrame = self.captViewLeft.frame;
//    self.captViewLeft.layer.anchorPoint = CGPointMake(0.0, 1.0);
//    self.captViewLeft.frame = originalFrame;
//    
//    originalFrame = self.captViewRight.frame;
//    self.captViewRight.layer.anchorPoint = CGPointMake(1.0, 1.0);
//    self.captViewRight.frame = originalFrame;
//    
//    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
//        
//        self.captView.frame = CGRectMake(self.captView.frame.origin.x, self.captView.frame.origin.y - 450.0, self.captView.frame.size.width, self.captView.frame.size.height);
//        self.captViewLeft.transform = CGAffineTransformMakeRotation(M_PI * 1.5);
//        self.captViewRight.transform = CGAffineTransformMakeRotation(M_PI * -1.5);
//        
//    } completion:^(BOOL finished) {
//    }];
//    
//    HPUserInfoViewController* uiController = [[HPUserInfoViewController alloc] initWithNibName: @"HPUserInfoViewController" bundle: nil];
//    uiController.user = [usersArr objectAtIndex:_carouselView.currentItemIndex];
//    uiController.delegate = self;
//    uiController.transitioningDelegate = self;
//    uiController.modalPresentationStyle = UIModalPresentationCustom;
//    [self presentViewController:uiController animated:YES completion:nil];
//}
//- (void) animationViewsDown {
//    
//    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
//        
//        self.captView.frame = CGRectMake(self.captView.frame.origin.x, self.captView.frame.origin.y + 450.0, self.captView.frame.size.width, self.captView.frame.size.height);
//        self.captViewLeft.transform = CGAffineTransformIdentity;
//        self.captViewRight.transform = CGAffineTransformIdentity;
//        
//    } completion:^(BOOL finished) {
//        NSLog(@"end animation1");
//        [self.captView removeFromSuperview];
//        [self.captViewLeft removeFromSuperview];
//        [self.captViewRight removeFromSuperview];
//        self.captView = nil;
//        self.captViewLeft  = nil;
//        self.captViewRight =  nil;
//        self.carouselView.hidden = NO;
//        NSLog(@"end animation2");
//        
//    }];
//    
//}
//
//#pragma mark - notifications
//- (void) registerNotification {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needUpdatePointLike) name:kNeedUpdatePointLike object:nil];
//}
//
//- (void) unregisterNotification {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNeedUpdatePointLike object:nil];
//}
//
//- (void) needUpdatePointLike {
//    [self.carouselView reloadData];
//}

//
//
//- (void) fixUserCardConstraint
//{
//    CGFloat topCarousel = CONSTRAINT_WIDE_TOP_FOR_CAROUSEL;
//    if (![UIDevice hp_isWideScreen])
//        topCarousel = CONSTRAINT_TOP_FOR_CAROUSEL;
//
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem: _carouselView
//                                                                 attribute: NSLayoutAttributeTop
//                                                                 relatedBy: NSLayoutRelationEqual
//                                                                    toItem: self.view
//                                                                 attribute: NSLayoutAttributeTop
//                                                                multiplier: 1.0
//                                                                  constant: topCarousel]];
//
//    if (![UIDevice hp_isWideScreen])
//    {
//        
//        NSArray* cons = _carouselView.constraints;
//        for (NSLayoutConstraint* consIter in cons)
//        {
//            if ((consIter.firstAttribute == NSLayoutAttributeHeight) &&
//                (consIter.firstItem == _carouselView))
//                consIter.constant = CONSTRAINT_HEIGHT_FOR_CAROUSEL;
//        }
//    }
//}
//
//
//- (void) fixUserPointConstraint
//{
//}

//- (void) initCarousel
//{
//    _cardOrPoint = [NSMutableArray array];
//    for (NSInteger i = 0; i < ICAROUSEL_ITEMS_COUNT; i++)
//        _cardOrPoint[i] = [HPUserCardOrPoint new];
//
//    _carouselView.type = iCarouselTypeRotary;
//    _carouselView.decelerationRate = 0.7;
//    _carouselView.scrollEnabled = YES;
//    _carouselView.exclusiveTouch = YES;
//}


//#pragma mark - iCarousel data source -
//
//
//- (NSUInteger)numberOfItemsInCarousel: (iCarousel*) carousel
//{
//    return usersArr.count;
//}
//
//
//- (UIView*)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
//{
//    NSLog(@"index %i", index);
//    if (_cardOrPoint == nil)
//        NSAssert(YES, @"no description for carousel item");
//    User *user = [usersArr objectAtIndex:index];
//    view = [[HPUserCardOrPointView alloc] initWithCardOrPoint: _cardOrPoint[index] user: user
//                                                     delegate: self];
//
//    return view;
//}
//
//
//#pragma mark - iCarousel delegate -
//
//
//- (CGFloat)carousel: (iCarousel *)carousel valueForOption: (iCarouselOption)option withDefault:(CGFloat)value
//{
//    switch (option)
//    {
//        case iCarouselOptionFadeMin:
//            return -1;
//        case iCarouselOptionFadeMax:
//            return 1;
//        case iCarouselOptionFadeRange:
//            return 2.0;
//        case iCarouselOptionCount:
//            return 10;
//        case iCarouselOptionSpacing:
//            return value * 1.3;
//        default:
//            return value;
//    }
//}
//
//
//- (CGFloat)carouselItemWidth:(iCarousel*)carousel
//{
//    return ICAROUSEL_ITEMS_WIDTH;
//}
//
//
//#pragma mark - Slide buttons -
//
//
//- (IBAction) slideLeftPressed: (id)sender
//{
//    NSInteger currentItemIndex = _carouselView.currentItemIndex;
//    NSInteger itemIndexToScrollTo = _carouselView.currentItemIndex - 1;
//    if (currentItemIndex == 0)
//        itemIndexToScrollTo = _carouselView.numberOfItems - 1;
//    
//    [_carouselView scrollToItemAtIndex: itemIndexToScrollTo animated: YES];
//}
//
//
//- (IBAction) slideRightPressed: (id)sender
//{
//    NSInteger currentItemIndex = _carouselView.currentItemIndex;
//    NSInteger itemIndexToScrollTo = _carouselView.currentItemIndex + 1;
//    if (currentItemIndex >= _carouselView.numberOfItems)
//        itemIndexToScrollTo = 0;
//    
//    [_carouselView scrollToItemAtIndex: itemIndexToScrollTo animated: YES];
//}


//#pragma mark - User card delegate -
//- (void) switchButtonPressed
//{
//    HPUserCardOrPointView* container = (HPUserCardOrPointView*)self.carouselView.currentItemView;
//    [_cardOrPoint[_carouselView.currentItemIndex] switchUserPoint];
//    
//    User *user = [usersArr objectAtIndex:_carouselView.currentItemIndex];
//    [UIView transitionWithView: container
//                      duration: FLIP_ANIMATION_SPEED
//                       options: UIViewAnimationOptionTransitionFlipFromRight
//                    animations: ^{
//                        [container switchSidesWithCardOrPoint: _cardOrPoint[_carouselView.currentItemIndex] user:user
//                                                     delegate: self];
//                    }
//                    completion: ^(BOOL finished){
//                }];
//}
//
//
//- (void) heartTapped
//{
//    UserPoint *point = ((User *)[usersArr objectAtIndex:self.carouselView.currentItemIndex]).point;
//    if ([point.pointLiked boolValue]) {
//        //unlike request
//        [[HPBaseNetworkManager sharedNetworkManager] makePointUnLikeRequest:point.pointId];
//    } else {
//        //like request
//        [[HPBaseNetworkManager sharedNetworkManager] makePointLikeRequest:point.pointId];
//    }
//    NSLog(@"heart tapped");
//}
//


@end
