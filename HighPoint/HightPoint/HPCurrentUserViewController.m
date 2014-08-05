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


#define CONSTRAINT_TOP_FOR_BOTTOM_VIEW 432
#define CONSTRAINT_HEIGHT_FOR_COLLECTIONVIEW 375


@interface HPCurrentUserViewController ()

@end

@implementation HPCurrentUserViewController {
    User *currentUser;
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
    [self.currentUserCollectionView registerNib:[UINib nibWithNibName:@"HPUserCardUICollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"UserCardIdentif"];
    [self.currentUserCollectionView registerNib:[UINib nibWithNibName:@"HPCurrentUserUICollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CurrentUserCollectionCell"];
    self.currentUserCollectionView.delegate = self;
    self.currentUserCollectionView.dataSource = self;

    self.pageController.currentPage = 0;
    [self fixUserCardConstraint];
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

- (void) showUserAlbumAndInfo {
    self.personalDataLabel.text = NSLocalizedString(@"YOUR_PHOTO_ALBUM_AND_DATA", nil);
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
    return 3;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        HPCurrentUserUICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"CurrentUserCollectionCell" forIndexPath:indexPath];
        [cell configureCell:currentUser];
        return cell;
    } else {
        HPUserCardUICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"UserCardIdentif" forIndexPath:indexPath];
        [cell configureCell: nil];
        return cell;
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
        if (indexPath.row == 1) {
            return CGSizeMake(320, 375);
        } else {
            return CGSizeMake(320, 375);
        }
    } else {
        if (indexPath.row == 1) {
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
}

#pragma mark - user info

- (IBAction)bottomTap:(id)sender {
    [self showCurrentUserProfile];
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
    uiController.delegate = self;
    uiController.transitioningDelegate = self;
    uiController.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:uiController animated:YES completion:nil];
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
