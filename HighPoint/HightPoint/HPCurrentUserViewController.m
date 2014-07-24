//
//  HPCurrentUserViewController.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 10.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPCurrentUserViewController.h"
#import "HPChatListViewController.h"
#import "HPCurrentUserPointView.h"
#import "HPCurrentUserCardView.h"
#import "HPConciergeViewController.h"
#import "HPCurrentUserCardOrPointView.h"
#import "HPUserInfoViewController.h"
#import "DataStorage.h"
#import "UILabel+HighPoint.h"
#import "UIDevice+HighPoint.h"
#import "UIButton+HighPoint.h"
#import "HPBaseNetworkManager.h"
#import "HPPointLikesViewController.h"
#import "ModalAnimation.h"
#import "Utils.h"

#define FLIP_ANIMATION_SPEED 0.5
#define CONSTRAINT_TOP_FOR_CAROUSEL 30
#define CONSTRAINT_WIDE_TOP_FOR_CAROUSEL 80
#define CONSTRAINT_HEIGHT_FOR_CAROUSEL 340
#define CONSTRAINT_TOP_FOR_BOTTOM_VIEW 432


@interface HPCurrentUserViewController ()

@end

@implementation HPCurrentUserViewController {
    HPCurrentUserPointView *userPointView;
    HPCurrentUserCardOrPoint *currentUserCardOrPoint;
    HPCurrentUserCardOrPointView *currentUserCardOrPointView;
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
    self.carousel.dataSource = self;
    self.carousel.delegate = self;
    [self fixUserCardConstraint];
    currentUserCardOrPoint = [HPCurrentUserCardOrPoint new];
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

- (IBAction)bubbleButtonTap:(id)sender {
    HPChatListViewController* chatList = [[HPChatListViewController alloc] initWithNibName: @"HPChatListViewController" bundle: nil];
    [self.navigationController pushViewController:chatList animated:YES];
}

-(void) cancelTaped {
    [currentUserCardOrPoint.pointView endEditing:YES];
    if ((!currentUserCardOrPoint.pointView.pointOptionsView.hidden) || (!currentUserCardOrPoint.pointView.deletePointView.hidden)) {
        [self minimizeChildContainer];
    }
    float deltaY = (currentUserCardOrPoint.pointView.pointOptionsView.hidden) ? 110 : 145;
    currentUserCardOrPoint.pointView.pointOptionsView.hidden = YES;
    currentUserCardOrPoint.pointView.publishPointBtn.hidden = NO;
    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationCurveEaseOut
                     animations:^{
                         currentUserCardOrPoint.pointView.frame = CGRectMake(currentUserCardOrPoint.pointView.frame.origin.x, currentUserCardOrPoint.pointView.frame.origin.y + deltaY,currentUserCardOrPoint.pointView.frame.size.width, currentUserCardOrPoint.pointView.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [self showBottomBar];
                     }];
    [self hideNavigationItem];
}

-(void) doneTaped {
    [self.view endEditing:YES];
    [self maximizeChildContainer];
    [currentUserCardOrPointView addPointOptionsViewToCard:currentUserCardOrPoint delegate:self];
}

-(void) shareTaped {
    [currentUserCardOrPoint.pointView endEditing:YES];
    [self minimizeChildContainer];
    float deltaY = (currentUserCardOrPoint.pointView.pointOptionsView.hidden) ? 110 : 145;
    currentUserCardOrPoint.pointView.pointOptionsView.hidden = YES;
    currentUserCardOrPoint.pointView.publishPointBtn.hidden = YES;
    currentUserCardOrPoint.pointView.deletePointBtn.hidden = NO;
    
    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationCurveEaseOut
                     animations:^{
                         currentUserCardOrPoint.pointView.frame = CGRectMake(currentUserCardOrPoint.pointView.frame.origin.x, currentUserCardOrPoint.pointView.frame.origin.y + deltaY,currentUserCardOrPoint.pointView.frame.size.width, currentUserCardOrPoint.pointView.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [self showBottomBar];
                     }];
    [self hideNavigationItem];
}



#pragma mark - navigation item configure

- (void) showNavigationItem {
    [self.navigationController setNavigationBarHidden:NO];
    [self.carousel setScrollEnabled:NO];
}

- (void) hideNavigationItem {
    [self.navigationController setNavigationBarHidden:YES];
    [self.carousel setScrollEnabled:YES];
}

- (void) configurePublishPointNavigationItem
{
    UIButton *doneBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.exclusiveTouch = YES;
    [doneBtn setFrame:CGRectMake(0, 0, 50, 30)];
    [doneBtn addTarget:self action:@selector(doneTaped) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setTitle:NSLocalizedString(@"DONE_BTN", nil) forState: UIControlStateNormal];
    [doneBtn setTitle:NSLocalizedString(@"DONE_BTN", nil) forState: UIControlStateHighlighted];
    [doneBtn hp_tuneFontForGreenButton];
    UIBarButtonItem *itemDone = [[UIBarButtonItem alloc]initWithCustomView:doneBtn];
    self.navigationItem.rightBarButtonItem = itemDone;

    UIButton *cancelBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.exclusiveTouch = YES;
    [cancelBtn setFrame:CGRectMake(0, 0, 80, 30)];
    [cancelBtn addTarget:self action:@selector(cancelTaped) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitle:NSLocalizedString(@"CANCEL_BTN", nil) forState: UIControlStateNormal];
    [cancelBtn setTitle:NSLocalizedString(@"CANCEL_BTN", nil) forState: UIControlStateHighlighted];
    [cancelBtn hp_tuneFontForGreenButton];
    UIBarButtonItem *itemCancel = [[UIBarButtonItem alloc]initWithCustomView:cancelBtn];
    self.navigationItem.leftBarButtonItem = itemCancel;
}


- (void) configureSendPointNavigationItem
{
    UIButton *doneBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.exclusiveTouch = YES;
    [doneBtn setFrame:CGRectMake(0, 0, 120, 30)];
    [doneBtn addTarget:self action:@selector(shareTaped) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setTitle:NSLocalizedString(@"PUBLISH_BTN", nil) forState: UIControlStateNormal];
    [doneBtn setTitle:NSLocalizedString(@"PUBLISH_BTN", nil) forState: UIControlStateHighlighted];
    [doneBtn hp_tuneFontForGreenButton];
    UIBarButtonItem *itemDone = [[UIBarButtonItem alloc]initWithCustomView:doneBtn];
    self.navigationItem.rightBarButtonItem = itemDone;
    
    UIButton *cancelBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.exclusiveTouch = YES;
    [cancelBtn setFrame:CGRectMake(0, 0, 80, 30)];
    [cancelBtn addTarget:self action:@selector(cancelTaped) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitle:NSLocalizedString(@"CANCEL_BTN", nil) forState: UIControlStateNormal];
    [cancelBtn setTitle:NSLocalizedString(@"CANCEL_BTN", nil) forState: UIControlStateHighlighted];
    [cancelBtn hp_tuneFontForGreenButton];
    UIBarButtonItem *itemCancel = [[UIBarButtonItem alloc]initWithCustomView:cancelBtn];
    self.navigationItem.leftBarButtonItem = itemCancel;
}

#pragma mark - bottom bar configure

- (void) hideBottomBar {
    self.bottomView.hidden = YES;
}

- (void) showBottomBar {
    self.bottomView.hidden = NO;
}


#pragma mark - carousel scroll

-(void) enableCarouselScroll {
    [self.carousel setScrollEnabled:YES];
}

-(void) disableCarouselScroll {
    [self.carousel setScrollEnabled:NO];
}

#pragma mark - constraint
- (void) fixUserCardConstraint
{
    CGFloat topCarousel = CONSTRAINT_WIDE_TOP_FOR_CAROUSEL;
    if (![UIDevice hp_isWideScreen]) {
        topCarousel = CONSTRAINT_TOP_FOR_CAROUSEL;

    }

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem: self.carousel
                                                          attribute: NSLayoutAttributeTop
                                                          relatedBy: NSLayoutRelationEqual
                                                             toItem: self.view
                                                          attribute: NSLayoutAttributeTop
                                                         multiplier: 1.0
                                                           constant: topCarousel]];
    
    if (![UIDevice hp_isWideScreen])
    {
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem: self.bottomView
                                                              attribute: NSLayoutAttributeTop
                                                              relatedBy: NSLayoutRelationEqual
                                                                 toItem: self.view
                                                              attribute: NSLayoutAttributeTop
                                                             multiplier: 1.0
                                                               constant: CONSTRAINT_TOP_FOR_BOTTOM_VIEW]];
        
        NSArray* cons = self.carousel.constraints;
        for (NSLayoutConstraint* consIter in cons)
        {
            if ((consIter.firstAttribute == NSLayoutAttributeHeight) &&
                (consIter.firstItem == self.carousel))
                consIter.constant = CONSTRAINT_HEIGHT_FOR_CAROUSEL;
        }
    }
}


#pragma mark - bottom btn
- (void) showUserAlbumAndInfo {
    self.personalDataLabel.text = NSLocalizedString(@"YOUR_PHOTO_ALBUM_AND_DATA", nil);
    [self.personalDataLabel hp_tuneForUserListCellPointText];
}


#pragma mark - iCarousel data source -

- (NSUInteger)numberOfItemsInCarousel: (iCarousel*) carousel
{
    return 3;
}

- (UIView*)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    
    if (index == 0) {
        
        currentUserCardOrPointView = [[HPCurrentUserCardOrPointView alloc] initWithCardOrPoint: currentUserCardOrPoint delegate: self user:currentUser];
        view = currentUserCardOrPointView;
    }
    if (index == 1) {
        view = [[HPConciergeViewController alloc] initWithNibName:@"HPConciergeViewController" bundle:nil].view;
    }
    if (index == 2) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 264, 416)];
        view.backgroundColor = [UIColor whiteColor];
    }
    return view;
}

#pragma mark - iCarousel delegate -

- (CGFloat)carousel: (iCarousel *)carousel valueForOption: (iCarouselOption)option withDefault:(CGFloat)value
{
    switch (option)
    {
        case iCarouselOptionFadeMin:
            return -1;
        case iCarouselOptionFadeMax:
            return 1;
        case iCarouselOptionFadeRange:
            return 2.0;
        case iCarouselOptionCount:
            return 10;
        case iCarouselOptionSpacing:
            return value * 1.3;
        default:
            return value;
    }
}

- (CGFloat)carouselItemWidth:(iCarousel*)carousel
{
    return 320;
}

#pragma mark - User card delegate

- (void) switchButtonPressed
{
    HPCurrentUserCardOrPointView* container = (HPCurrentUserCardOrPointView*)self.carousel.currentItemView;
    [currentUserCardOrPoint switchUserPoint];
    [UIView transitionWithView: container
                      duration: FLIP_ANIMATION_SPEED
                       options: UIViewAnimationOptionTransitionFlipFromRight
                    animations: ^{
                        [container switchSidesWithCardOrPoint: currentUserCardOrPoint
                                                     delegate: self user:currentUser];
                    }
                    completion: ^(BOOL finished){
                    }];}


#pragma mark - child container size

- (void) maximizeChildContainer {
    NSLog(@"maximize container");
    HPCurrentUserCardOrPointView* container = (HPCurrentUserCardOrPointView*)self.carousel.currentItemView;
    [container.childContainerView setFrame:CGRectMake(container.childContainerView.frame.origin.x, container.childContainerView.frame.origin.y, container.childContainerView.frame.size.width,container.childContainerView.frame.size.height + 251)];
}

- (void) minimizeChildContainer {
    NSLog(@"maximize container");
    HPCurrentUserCardOrPointView* container = (HPCurrentUserCardOrPointView*)self.carousel.currentItemView;
    [container.childContainerView setFrame:CGRectMake(container.childContainerView.frame.origin.x, container.childContainerView.frame.origin.y, container.childContainerView.frame.size.width,container.childContainerView.frame.size.height - 251)];
}

#pragma mark - top navigation buttons

- (void) showTopNavigationItems {
    self.closeBtn.hidden = NO;
    self.bubbleBtn.hidden = NO;
}

- (void) hideTopNavigationItems {
    self.closeBtn.hidden = YES;
    self.bubbleBtn.hidden = YES;
}

#pragma mark - user info

- (IBAction)bottomTap:(id)sender {
    if ([currentUserCardOrPoint isUserPoint]) {
        HPPointLikesViewController* plController = [[HPPointLikesViewController alloc] initWithNibName: @"HPPointLikesViewController" bundle: nil];
        [self.navigationController pushViewController:plController animated:YES];
    } else {
        //HPUserInfoViewController* uiController = [[HPUserInfoViewController alloc] initWithNibName: @"HPUserInfoViewController" bundle: nil];
        //[self.navigationController pushViewController:uiController animated:YES];
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

@end
