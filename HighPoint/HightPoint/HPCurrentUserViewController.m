//
//  HPCurrentUserViewController.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 10.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPCurrentUserViewController.h"
#import "HPChatListViewController.h"
#import "HPConciergeViewController.h"
#import "HPUserInfoViewController.h"
#import "DataStorage.h"
#import "UILabel+HighPoint.h"
#import "UIDevice+HighPoint.h"
#import "UIButton+HighPoint.h"
#import "HPBaseNetworkManager.h"
#import "HPPointLikesViewController.h"
#import "ModalAnimation.h"
#import "Utils.h"
#import "HPUserCardUICollectionViewCell.h"
#import "HPCurrentUserUICollectionViewCell.h"
#import "HPCurrentUserPointCollectionViewCell.h"
#import "UINavigationController+HighPoint.h"



#define CONSTRAINT_TOP_FOR_BOTTOM_VIEW 432
#define CONSTRAINT_HEIGHT_FOR_COLLECTIONVIEW 480


@interface HPCurrentUserViewController ()

@end

@implementation HPCurrentUserViewController {
    User *currentUser;
    HPCurrentUserPointCollectionViewCell *cellPoint;
    HPCurrentUserUICollectionViewCell *cellUser;
    UINavigationBar *navBar;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.currentUserCollectionView registerNib:[UINib nibWithNibName:@"HPUserCardUICollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"UserCardIdentif"];
    [self.currentUserCollectionView registerNib:[UINib nibWithNibName:@"HPCurrentUserUICollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CurrentUserCollectionCell"];
    [self.currentUserCollectionView registerNib:[UINib nibWithNibName:@"HPCurrentUserPointCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CurrentUserPointIdentif"];
    //
    self.currentUserCollectionView.delegate = self;
    self.currentUserCollectionView.dataSource = self;

    self.pageController.currentPage = 0;
    [self fixUserCardConstraint];
    [self showBottomElement];
    _modalAnimationController = [[ModalAnimation alloc] init];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    currentUser = [[DataStorage sharedDataStorage] getCurrentUser];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - button handlers

- (IBAction)backButtonTap:(id)sender {
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction)settingsBtnTap:(id)sender {
    NSLog(@"settings tap");
}

- (void) showBottomElement {
    [self setBottomMenu:0];
    [self.personalDataLabel hp_tuneForUserListCellPointText];
}

#pragma mark - constraint
- (void) fixUserCardConstraint
{
    if (![UIDevice hp_isWideScreen])
    {
        
        NSArray* cons = self.view.constraints;
        for (NSLayoutConstraint* consIter in cons)
        {
            if ((consIter.firstAttribute == NSLayoutAttributeHeight) &&
                (consIter.firstItem == self.currentUserCollectionView))
                consIter.constant = CONSTRAINT_HEIGHT_FOR_COLLECTIONVIEW;
            
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == self.bottomView))
                consIter.constant = CONSTRAINT_TOP_FOR_BOTTOM_VIEW;
        }
    }
}



#pragma mark - uicollection view

#pragma mark - UICollectionView Datasource
// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return 2;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        cellPoint = [cv dequeueReusableCellWithReuseIdentifier:@"CurrentUserPointIdentif" forIndexPath:indexPath];
        cellPoint.delegate = self;
        [cellPoint configureCell];
        return cellPoint;
    } else  {
        cellUser = [cv dequeueReusableCellWithReuseIdentifier:@"CurrentUserCollectionCell" forIndexPath:indexPath];
        [cellUser configureCell:currentUser];
        return cellUser;
    }
}

/*- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (![UIDevice hp_isWideScreen])
    {
        if ((indexPath.row == 1) || (indexPath.row == 0) ) {
            return CGSizeMake(320, 375);
        } else {
            return CGSizeMake(320, 375);
        }
    } else {
        if ((indexPath.row == 1) || (indexPath.row == 0)) {
            return CGSizeMake(320, 458);
        } else {
            return CGSizeMake(320, 418);
        }
    }
}


- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float index = scrollView.contentOffset.x/320.0;
    self.pageController.currentPage = (int)index;
    [self setBottomMenu:(int)index];
}

#pragma mark - bottom menu

- (void) setBottomMenu : (int) index {
    if (index == 0) {
        self.personalDataLabel.text = NSLocalizedString(@"YOUR_POINT_LIKES", nil);
        self.personalDataDownImgView.hidden = YES;
    } else {
        self.personalDataLabel.text = NSLocalizedString(@"YOUR_PHOTO_ALBUM_AND_DATA", nil);
        self.personalDataDownImgView.hidden = NO;
    }
}


#pragma mark - user info

- (IBAction)bottomTap:(id)sender {
    if (self.pageController.currentPage == 0) {
        HPPointLikesViewController* plController = [[HPPointLikesViewController alloc] initWithNibName: @"HPPointLikesViewController" bundle: nil];
        [self.navigationController pushViewController:plController animated:YES];
    } else {
        [self showCurrentUserProfile];
    }
}
- (void) showCurrentUserProfile {
    /*
     UIImage *captureImg = [Utils captureView:self.carousel.currentItemView withArea:CGRectMake(0, 0, self.carousel.currentItemView.frame.size.width, self.carousel.currentItemView.frame.size.height)];
     
     self.carousel.translatesAutoresizingMaskIntoConstraints = NO;
     
     self.captView = [[UIImageView alloc] initWithImage:captureImg];
     CGRect rect = self.carousel.currentItemView.frame;
     
     CGRect result = [self.view convertRect:self.carousel.currentItemView.frame fromView:self.carousel];
     
     self.captView.frame = result;
     
     self.carousel.hidden = YES;
     [self.view addSubview:self.captView];
     
     
     
     
     [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
     
     self.captView.frame = CGRectMake(self.captView.frame.origin.x, self.captView.frame.origin.y - 450.0, self.captView.frame.size.width, self.captView.frame.size.height);
     
     
     } completion:^(BOOL finished) {
     }];
     */
    HPUserProfileViewController* uiController = [[HPUserProfileViewController alloc] initWithNibName: @"HPUserProfile" bundle: nil];
    //uiController.user = [usersArr objectAtIndex:_carouselView.currentItemIndex];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:uiController];
    uiController.delegate = self;
    uiController.transitioningDelegate = self;
    uiController.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:navigationController animated:YES completion:nil];
}
#pragma mark - Transitioning Delegate (Modal)
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    _modalAnimationController.type = AnimationTypePresent;
    return _modalAnimationController;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    _modalAnimationController.type = AnimationTypeDismiss;
    return _modalAnimationController;
}


#pragma mark - delegate methods

- (void) startEditingPoint {
    
    self.currentUserCollectionView.scrollEnabled = NO;
    navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    navBar.barTintColor = [UIColor colorWithRed: 34.0 / 255.0
                                          green: 45.0 / 255.0
                                           blue: 77.0 / 255.0
                                          alpha: 1.0];
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    UIButton *doneBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.exclusiveTouch = YES;
    [doneBtn setFrame:CGRectMake(0, 0, 50, 30)];
    [doneBtn addTarget:self action:@selector(doneEditingPointTap) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setTitle:NSLocalizedString(@"DONE_BTN", nil) forState: UIControlStateNormal];
    [doneBtn setTitle:NSLocalizedString(@"DONE_BTN", nil) forState: UIControlStateHighlighted];
    [doneBtn hp_tuneFontForGreenButton];
    UIBarButtonItem *itemDone = [[UIBarButtonItem alloc]initWithCustomView:doneBtn];
    navItem.rightBarButtonItem = itemDone;
    
    UIButton *cancelBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.exclusiveTouch = YES;
    [cancelBtn setFrame:CGRectMake(0, 0, 80, 30)];
    [cancelBtn addTarget:self action:@selector(cancelPointTap) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitle:NSLocalizedString(@"CANCEL_BTN", nil) forState: UIControlStateNormal];
    [cancelBtn setTitle:NSLocalizedString(@"CANCEL_BTN", nil) forState: UIControlStateHighlighted];
    [cancelBtn hp_tuneFontForGreenButton];
    UIBarButtonItem *itemCancel = [[UIBarButtonItem alloc]initWithCustomView:cancelBtn];
    navItem.leftBarButtonItem = itemCancel;
    navBar.items = @[navItem];
    [self.view addSubview:navBar];
}

- (void) endEditingPoint {
    [navBar removeFromSuperview];
}


- (void) startDeletePoint{
    self.bottomView.hidden = YES;
    self.currentUserCollectionView.scrollEnabled = NO;
    self.closeBtn.hidden = YES;
    self.settingsBtn.hidden = YES;
    self.pageController.hidden = YES;
}
- (void) endDeletePoint{
    self.bottomView.hidden = NO;
    self.currentUserCollectionView.scrollEnabled = YES;
    self.closeBtn.hidden = NO;
    self.settingsBtn.hidden = NO;
    self.pageController.hidden = NO;
}



#pragma mark - navigation item 

- (void) doneEditingPointTap {
    [cellPoint endEditing:YES];
    [self.bottomView setHidden:YES];
    
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    
    UIButton *doneBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.exclusiveTouch = YES;
    [doneBtn setFrame:CGRectMake(0, 0, 120, 30)];
    [doneBtn addTarget:self action:@selector(sharePointTap) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setTitle:NSLocalizedString(@"PUBLISH_BTN", nil) forState: UIControlStateNormal];
    [doneBtn setTitle:NSLocalizedString(@"PUBLISH_BTN", nil) forState: UIControlStateHighlighted];
    [doneBtn hp_tuneFontForGreenButton];
    UIBarButtonItem *itemDone = [[UIBarButtonItem alloc]initWithCustomView:doneBtn];
    navItem.rightBarButtonItem = itemDone;
    
    UIButton *cancelBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.exclusiveTouch = YES;
    [cancelBtn setFrame:CGRectMake(0, 0, 80, 30)];
    [cancelBtn addTarget:self action:@selector(cancelPointTap) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitle:NSLocalizedString(@"CANCEL_BTN", nil) forState: UIControlStateNormal];
    [cancelBtn setTitle:NSLocalizedString(@"CANCEL_BTN", nil) forState: UIControlStateHighlighted];
    [cancelBtn hp_tuneFontForGreenButton];
    UIBarButtonItem *itemCancel = [[UIBarButtonItem alloc]initWithCustomView:cancelBtn];
    navItem.leftBarButtonItem = itemCancel;
    navBar.items = @[navItem];
    
    cellPoint.publishBtn.hidden = YES;
    cellPoint.pointTextView.userInteractionEnabled = NO;
    cellPoint.avatarImageView.userInteractionEnabled = NO;
    cellPoint.frame = CGRectMake(cellPoint.frame.origin.x, cellPoint.frame.origin.y, 320, 623);
    [cellPoint.pointSettingsView setHidden:NO];
}

- (void) sharePointTap {
    NSLog(@"publish tap");
    [navBar removeFromSuperview];
    self.bottomView.hidden = NO;
    [cellPoint endEditing:YES];
    [cellPoint editPointDown];
    [cellPoint.pointSettingsView setHidden:YES];
    cellPoint.publishBtn.hidden = YES;
    cellPoint.deleteBtn.hidden = NO;
    cellPoint.pointTextView.userInteractionEnabled = NO;
    cellPoint.avatarImageView.userInteractionEnabled = NO;
    self.currentUserCollectionView.scrollEnabled = YES;
}

- (void) cancelPointTap {
    [navBar removeFromSuperview];
    [cellPoint endEditing:YES];
    [cellPoint editPointDown];
    [cellPoint.pointSettingsView setHidden:YES];
    cellPoint.pointTextView.userInteractionEnabled = YES;
    cellPoint.avatarImageView.userInteractionEnabled = YES;
    cellPoint.publishBtn.hidden = NO;
    cellPoint.pointTextView.userInteractionEnabled = YES;
    cellPoint.avatarImageView.userInteractionEnabled = YES;
    self.currentUserCollectionView.scrollEnabled = YES;
}

//- (IBAction)bubbleButtonTap:(id)sender {
//    HPChatListViewController* chatList = [[HPChatListViewController alloc] initWithNibName: @"HPChatListViewController" bundle: nil];
//    [self.navigationController pushViewController:chatList animated:YES];
//}
//
//-(void) cancelTaped {
//    [currentUserCardOrPoint.pointView endEditing:YES];
//    if ((!currentUserCardOrPoint.pointView.pointOptionsView.hidden) || (!currentUserCardOrPoint.pointView.deletePointView.hidden)) {
//        [self minimizeChildContainer];
//    }
//    float deltaY = (currentUserCardOrPoint.pointView.pointOptionsView.hidden) ? 110 : 145;
//    currentUserCardOrPoint.pointView.pointOptionsView.hidden = YES;
//    currentUserCardOrPoint.pointView.publishPointBtn.hidden = NO;
//    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationCurveEaseOut
//                     animations:^{
//                         currentUserCardOrPoint.pointView.frame = CGRectMake(currentUserCardOrPoint.pointView.frame.origin.x, currentUserCardOrPoint.pointView.frame.origin.y + deltaY,currentUserCardOrPoint.pointView.frame.size.width, currentUserCardOrPoint.pointView.frame.size.height);
//                     }
//                     completion:^(BOOL finished){
//                         [self showBottomBar];
//                     }];
//    [self hideNavigationItem];
//}
//
//-(void) doneTaped {
//    [self.view endEditing:YES];
//    [self maximizeChildContainer];
//    [currentUserCardOrPointView addPointOptionsViewToCard:currentUserCardOrPoint delegate:self];
//}
//
//-(void) shareTaped {
//    [currentUserCardOrPoint.pointView endEditing:YES];
//    [self minimizeChildContainer];
//    float deltaY = (currentUserCardOrPoint.pointView.pointOptionsView.hidden) ? 110 : 145;
//    currentUserCardOrPoint.pointView.pointOptionsView.hidden = YES;
//    currentUserCardOrPoint.pointView.publishPointBtn.hidden = YES;
//    currentUserCardOrPoint.pointView.deletePointBtn.hidden = NO;
//    
//    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationCurveEaseOut
//                     animations:^{
//                         currentUserCardOrPoint.pointView.frame = CGRectMake(currentUserCardOrPoint.pointView.frame.origin.x, currentUserCardOrPoint.pointView.frame.origin.y + deltaY,currentUserCardOrPoint.pointView.frame.size.width, currentUserCardOrPoint.pointView.frame.size.height);
//                     }
//                     completion:^(BOOL finished){
//                         [self showBottomBar];
//                     }];
//    [self hideNavigationItem];
//}
//

//
//#pragma mark - navigation item configure
//
//- (void) showNavigationItem {
//    [self.navigationController setNavigationBarHidden:NO];
//}
//
//- (void) hideNavigationItem {
//    [self.navigationController setNavigationBarHidden:YES];
//}
//
//- (void) configurePublishPointNavigationItem
//{
//    UIButton *doneBtn=[UIButton buttonWithType:UIButtonTypeCustom];
//    doneBtn.exclusiveTouch = YES;
//    [doneBtn setFrame:CGRectMake(0, 0, 50, 30)];
//    [doneBtn addTarget:self action:@selector(doneTaped) forControlEvents:UIControlEventTouchUpInside];
//    [doneBtn setTitle:NSLocalizedString(@"DONE_BTN", nil) forState: UIControlStateNormal];
//    [doneBtn setTitle:NSLocalizedString(@"DONE_BTN", nil) forState: UIControlStateHighlighted];
//    [doneBtn hp_tuneFontForGreenButton];
//    UIBarButtonItem *itemDone = [[UIBarButtonItem alloc]initWithCustomView:doneBtn];
//    self.navigationItem.rightBarButtonItem = itemDone;
//
//    UIButton *cancelBtn=[UIButton buttonWithType:UIButtonTypeCustom];
//    cancelBtn.exclusiveTouch = YES;
//    [cancelBtn setFrame:CGRectMake(0, 0, 80, 30)];
//    [cancelBtn addTarget:self action:@selector(cancelTaped) forControlEvents:UIControlEventTouchUpInside];
//    [cancelBtn setTitle:NSLocalizedString(@"CANCEL_BTN", nil) forState: UIControlStateNormal];
//    [cancelBtn setTitle:NSLocalizedString(@"CANCEL_BTN", nil) forState: UIControlStateHighlighted];
//    [cancelBtn hp_tuneFontForGreenButton];
//    UIBarButtonItem *itemCancel = [[UIBarButtonItem alloc]initWithCustomView:cancelBtn];
//    self.navigationItem.leftBarButtonItem = itemCancel;
//}
//
//
//- (void) configureSendPointNavigationItem
//{
//    UIButton *doneBtn=[UIButton buttonWithType:UIButtonTypeCustom];
//    doneBtn.exclusiveTouch = YES;
//    [doneBtn setFrame:CGRectMake(0, 0, 120, 30)];
//    [doneBtn addTarget:self action:@selector(shareTaped) forControlEvents:UIControlEventTouchUpInside];
//    [doneBtn setTitle:NSLocalizedString(@"PUBLISH_BTN", nil) forState: UIControlStateNormal];
//    [doneBtn setTitle:NSLocalizedString(@"PUBLISH_BTN", nil) forState: UIControlStateHighlighted];
//    [doneBtn hp_tuneFontForGreenButton];
//    UIBarButtonItem *itemDone = [[UIBarButtonItem alloc]initWithCustomView:doneBtn];
//    self.navigationItem.rightBarButtonItem = itemDone;
//    
//    UIButton *cancelBtn=[UIButton buttonWithType:UIButtonTypeCustom];
//    cancelBtn.exclusiveTouch = YES;
//    [cancelBtn setFrame:CGRectMake(0, 0, 80, 30)];
//    [cancelBtn addTarget:self action:@selector(cancelTaped) forControlEvents:UIControlEventTouchUpInside];
//    [cancelBtn setTitle:NSLocalizedString(@"CANCEL_BTN", nil) forState: UIControlStateNormal];
//    [cancelBtn setTitle:NSLocalizedString(@"CANCEL_BTN", nil) forState: UIControlStateHighlighted];
//    [cancelBtn hp_tuneFontForGreenButton];
//    UIBarButtonItem *itemCancel = [[UIBarButtonItem alloc]initWithCustomView:cancelBtn];
//    self.navigationItem.leftBarButtonItem = itemCancel;
//}
//
//#pragma mark - bottom bar configure
//
//- (void) hideBottomBar {
//    self.bottomView.hidden = YES;
//}
//
//- (void) showBottomBar {
//    self.bottomView.hidden = NO;
//}
//
//
//#pragma mark - carousel scroll
//
//-(void) enableCarouselScroll {
//    [self.carousel setScrollEnabled:YES];
//}
//
//-(void) disableCarouselScroll {
//    [self.carousel setScrollEnabled:NO];
//}
//






//#pragma mark - iCarousel data source -
//
//- (NSUInteger)numberOfItemsInCarousel: (iCarousel*) carousel
//{
//    return 3;
//}
//
//- (UIView*)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
//{
//    
//    if (index == 0) {
//        
//        currentUserCardOrPointView = [[HPCurrentUserCardOrPointView alloc] initWithCardOrPoint: currentUserCardOrPoint delegate: self user:currentUser];
//        view = currentUserCardOrPointView;
//    }
//    if (index == 1) {
//        view = [[HPConciergeViewController alloc] initWithNibName:@"HPConciergeViewController" bundle:nil].view;
//    }
//    if (index == 2) {
//        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 264, 416)];
//        view.backgroundColor = [UIColor whiteColor];
//    }
//    return view;
//}
//
//#pragma mark - iCarousel delegate -
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
//- (CGFloat)carouselItemWidth:(iCarousel*)carousel
//{
//    return 320;
//}
//
//#pragma mark - User card delegate
//
//- (void) switchButtonPressed
//{
//    HPCurrentUserCardOrPointView* container = (HPCurrentUserCardOrPointView*)self.carousel.currentItemView;
//    [currentUserCardOrPoint switchUserPoint];
//    [UIView transitionWithView: container
//                      duration: FLIP_ANIMATION_SPEED
//                       options: UIViewAnimationOptionTransitionFlipFromRight
//                    animations: ^{
//                        [container switchSidesWithCardOrPoint: currentUserCardOrPoint
//                                                     delegate: self user:currentUser];
//                    }
//                    completion: ^(BOOL finished){
//                    }];}
//
//
//#pragma mark - child container size
//
//- (void) maximizeChildContainer {
//    NSLog(@"maximize container");
//    HPCurrentUserCardOrPointView* container = (HPCurrentUserCardOrPointView*)self.carousel.currentItemView;
//    [container.childContainerView setFrame:CGRectMake(container.childContainerView.frame.origin.x, container.childContainerView.frame.origin.y, container.childContainerView.frame.size.width,container.childContainerView.frame.size.height + 251)];
//}
//
//- (void) minimizeChildContainer {
//    NSLog(@"maximize container");
//    HPCurrentUserCardOrPointView* container = (HPCurrentUserCardOrPointView*)self.carousel.currentItemView;
//    [container.childContainerView setFrame:CGRectMake(container.childContainerView.frame.origin.x, container.childContainerView.frame.origin.y, container.childContainerView.frame.size.width,container.childContainerView.frame.size.height - 251)];
//}
//
//#pragma mark - top navigation buttons
//
//- (void) showTopNavigationItems {
//    self.closeBtn.hidden = NO;
//    self.bubbleBtn.hidden = NO;
//}
//
//- (void) hideTopNavigationItems {
//    self.closeBtn.hidden = YES;
//    self.bubbleBtn.hidden = YES;
//}
//

@end
