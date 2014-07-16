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

#define FLIP_ANIMATION_SPEED 0.5
#define CONSTRAINT_TOP_FOR_CAROUSEL 76
#define CONSTRAINT_WIDE_TOP_FOR_CAROUSEL 80
#define CONSTRAINT_HEIGHT_FOR_CAROUSEL 340

@interface HPCurrentUserViewController ()

@end

@implementation HPCurrentUserViewController {
    HPCurrentUserPointView *userPointView;
    HPCurrentUserCardOrPoint *currentUserCardOrPoint;
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
    
    // Do any additional setup after loading the view from its nib.
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


- (IBAction)backButtonTap:(id)sender {
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction)bubbleButtonTap:(id)sender {
    HPChatListViewController* chatList = [[HPChatListViewController alloc] initWithNibName: @"HPChatListViewController" bundle: nil];
    [self.navigationController pushViewController:chatList animated:YES];
}



#pragma mark - constraint
- (void) fixUserCardConstraint
{
    CGFloat topCarousel = CONSTRAINT_WIDE_TOP_FOR_CAROUSEL;
    if (![UIDevice hp_isWideScreen])
        topCarousel = CONSTRAINT_TOP_FOR_CAROUSEL;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem: self.carousel
                                                          attribute: NSLayoutAttributeTop
                                                          relatedBy: NSLayoutRelationEqual
                                                             toItem: self.view
                                                          attribute: NSLayoutAttributeTop
                                                         multiplier: 1.0
                                                           constant: topCarousel]];
    
    if (![UIDevice hp_isWideScreen])
    {
        
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
    [self.personalDataLabel hp_tuneForUserCardDetails];
}


#pragma mark - iCarousel data source -

- (NSUInteger)numberOfItemsInCarousel: (iCarousel*) carousel
{
    return 3;
}

- (UIView*)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    
    if (index == 0) {
        view = [[HPCurrentUserCardOrPointView alloc] initWithCardOrPoint: currentUserCardOrPoint delegate: self user:currentUser];
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
    NSLog(@"switch press");

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


#pragma mark - user info

- (IBAction)bottomTap:(id)sender {
    HPUserInfoViewController* uiController = [[HPUserInfoViewController alloc] initWithNibName: @"HPUserInfoViewController" bundle: nil];
    [self.navigationController pushViewController:uiController animated:YES];
}

@end
