//
//  HPUserCardViewController.m
//  HightPoint
//
//  Created by Andrey Anisimov on 13.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "HPUserCardViewController.h"
#import "Utils.h"
#import "UIImage+HighPoint.h"
#import "UINavigationController+HighPoint.h"
#import "UIViewController+HighPoint.h"
#import "UILabel+HighPoint.h"
#import "UIView+HighPoint.h"
#import "HPUserCardView.h"
#import "HPUserCardOrPointView.h"
#import "UIDevice+HighPoint.h"

//==============================================================================

#define ICAROUSEL_ITEMS_COUNT 20
#define ICAROUSEL_ITEMS_WIDTH 264.0
#define GREENBUTTON_BOTTOM_SHIFT 50
#define SPACE_BETWEEN_GREENBUTTON_AND_INFO 40
#define FLIP_ANIMATION_SPEED 0.5
#define CONSTRAINT_TOP_FOR_CAROUSEL 32
#define CONSTRAINT_HEIGHT_FOR_CAROUSEL 340

//==============================================================================

@implementation HPUserCardViewController

//==============================================================================

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initObjects];
}

//==============================================================================

- (void) initObjects
{
    [self createNavigationItem];
    [self initCarousel];
    
    [self fixUserCardConstraint];
    [self createGreenButton];
}

//==============================================================================

- (void) fixUserCardConstraint
{
    if (![UIDevice hp_isWideScreen])
    {
        NSArray* cons = self.view.constraints;
        for (NSLayoutConstraint* consIter in cons)
        {
            if ((consIter.firstAttribute == NSLayoutAttributeBottom) &&
                (consIter.firstItem == self.view) &&
                (consIter.secondItem == _carouselView))
                consIter.constant = CONSTRAINT_TOP_FOR_CAROUSEL;
        }
        
        cons = _carouselView.constraints;
        for (NSLayoutConstraint* consIter in cons)
        {
            if ((consIter.firstAttribute == NSLayoutAttributeHeight) &&
                (consIter.firstItem == _carouselView))
                consIter.constant = CONSTRAINT_HEIGHT_FOR_CAROUSEL;
        }
    }
}

//==============================================================================

- (void) createGreenButton
{
    HPGreenButtonVC* sendMessage = [[HPGreenButtonVC alloc] initWithNibName: @"HPGreenButtonVC" bundle: nil];
    sendMessage.view.translatesAutoresizingMaskIntoConstraints = NO;
    sendMessage.delegate = self;

    CGRect rect = sendMessage.view.frame;
    rect.origin.x = _infoButton.frame.origin.x + _infoButton.frame.size.width + SPACE_BETWEEN_GREENBUTTON_AND_INFO;
    rect.origin.y = _infoButton.frame.origin.y;
    sendMessage.view.frame = rect;

    sendMessage.delegate = self;
    [self addChildViewController: sendMessage];
    [self.view addSubview: sendMessage.view];

    [self createGreenButtonsConstraint: sendMessage];
}

//==============================================================================

- (void) createGreenButtonsConstraint: (HPGreenButtonVC*) sendMessage
{
    [sendMessage.view addConstraint:[NSLayoutConstraint constraintWithItem: sendMessage.view
                                                                 attribute: NSLayoutAttributeWidth
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: nil
                                                                 attribute: NSLayoutAttributeNotAnAttribute
                                                                multiplier: 1.0
                                                                  constant: sendMessage.view.frame.size.width]];

    [sendMessage.view addConstraint:[NSLayoutConstraint constraintWithItem: sendMessage.view
                                                                 attribute: NSLayoutAttributeHeight
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: nil
                                                                 attribute: NSLayoutAttributeNotAnAttribute
                                                                multiplier: 1.0
                                                                  constant: sendMessage.view.frame.size.height]];

    NSArray* cons = self.view.constraints;
    for (NSLayoutConstraint* consIter in cons)
    {
        if ((consIter.firstAttribute == NSLayoutAttributeBottom) &&
            (consIter.firstItem == self.view) &&
            (consIter.secondItem == _infoButton))
            {
               [self.view addConstraint:[NSLayoutConstraint constraintWithItem: self.view
                                                                     attribute: NSLayoutAttributeBottom
                                                                     relatedBy: NSLayoutRelationEqual
                                                                        toItem: sendMessage.view
                                                                     attribute: NSLayoutAttributeBottom
                                                                    multiplier: 1.0
                                                                      constant: consIter.constant]];
            }
    }
}

//==============================================================================

- (void) initCarousel
{
    _cardOrPoint = [NSMutableArray array];
    for (NSInteger i = 0; i < ICAROUSEL_ITEMS_COUNT; i++)
        _cardOrPoint[i] = [HPUserCardOrPoint new];

    _carouselView.type = iCarouselTypeRotary;
    _carouselView.decelerationRate = 0.7;
    _carouselView.scrollEnabled = YES;
    _carouselView.exclusiveTouch = YES;
}

//==============================================================================

- (void) createNavigationItem
{
    UIBarButtonItem* chatlistButton = [self createBarButtonItemWithImage: [UIImage imageNamed:@"Bubble"]
                                                        highlighedImage: [UIImage imageNamed:@"Bubble Tap"]
                                                                 action: @selector(chatsListTaped:)];
    self.notificationView = [Utils getNotificationViewForText:@"8"];
    [chatlistButton.customView addSubview: _notificationView];
    self.navigationItem.rightBarButtonItem = chatlistButton;
    
    UIBarButtonItem* backButton = [self createBarButtonItemWithImage: [UIImage imageNamed:@"Close.png"]
                                                        highlighedImage: [UIImage imageNamed:@"Close Tap.png"]
                                                                 action: @selector(backbuttonTaped:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.navigationItem.title = @"Октябрина";
}

//==============================================================================

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

//==============================================================================

#pragma mark - Tap events -

//==============================================================================

- (void) chatsListTaped: (id) sender
{
    NSLog(@"ChatsList taped");
}

//==============================================================================

- (void) backbuttonTaped: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

//==============================================================================

#pragma mark - iCarousel data source -

//==============================================================================

- (NSUInteger)numberOfItemsInCarousel: (iCarousel*) carousel
{
    return ICAROUSEL_ITEMS_COUNT;
}

//==============================================================================

- (UIView*)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
   if (view == nil)
    {
        if (_cardOrPoint == nil)
            NSAssert(YES, @"no description for carousel item");
        view = [[HPUserCardOrPointView alloc] initWithCardOrPoint: _cardOrPoint[index]
                                                         delegate: self];
    }
    
    return view;
}

//==============================================================================

#pragma mark - iCarousel delegate -

//==============================================================================

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

//==============================================================================

- (void)carouselDidEndDragging: (iCarousel *)carousel willDecelerate: (BOOL)decelerate
{
//    self.dragging = YES;
}

//==============================================================================

- (void) carouselDidEndScrollingAnimation: (iCarousel*) carousel
{
//    [self removeImageViewFromItemWithIndex: self.prevIndex
//                                  andImage: NO];
//    
//    UIView* animV = [self createUserCard];
//    if (self.dragging)
//    {
//        self.dragging = NO;
//        [UIView transitionWithView: [self navigationController].view
//                          duration: 0.2
//                           options: UIViewAnimationOptionTransitionCrossDissolve //any animation
//                        animations: ^{
//                            [self.carouselView.currentItemView addSubview: animV];
//                        }
//                        completion: ^(BOOL finished){
//                        }];
//    }
//    else
//    {
//        [self.carouselView.currentItemView addSubview: animV];
//    }
//    
//    self.prevIndex = self.carouselView.currentItemIndex;
//    if (self.tapGesture == nil)
//    {
//        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(tapGesture:)];
//        [self.tapGesture setDelegate: self];
//        [self.carouselView.currentItemView addGestureRecognizer: self.tapGesture];
//    }
}

//==============================================================================

- (CGFloat)carouselItemWidth:(iCarousel*)carousel
{
    return ICAROUSEL_ITEMS_WIDTH;
}

//==============================================================================

#pragma mark - Slide buttons -

//==============================================================================

- (IBAction) slideLeftPressed: (id)sender
{
    NSInteger currentItemIndex = _carouselView.currentItemIndex;
    NSInteger itemIndexToScrollTo = _carouselView.currentItemIndex - 1;
    if (currentItemIndex == 0)
        itemIndexToScrollTo = _carouselView.numberOfItems - 1;
    
    [_carouselView scrollToItemAtIndex: itemIndexToScrollTo animated: YES];
}

//==============================================================================

- (IBAction) slideRightPressed: (id)sender
{
    NSInteger currentItemIndex = _carouselView.currentItemIndex;
    NSInteger itemIndexToScrollTo = _carouselView.currentItemIndex + 1;
    if (currentItemIndex >= _carouselView.numberOfItems)
        itemIndexToScrollTo = 0;
    
    [_carouselView scrollToItemAtIndex: itemIndexToScrollTo animated: YES];
}

//==============================================================================

#pragma mark - Buttons pressed -

//==============================================================================

- (void) greenButtonPressed: (HPGreenButtonVC*) button
{
    NSLog(@"Green button pressed");
}

//==============================================================================

- (IBAction) infoButtonPressed: (id)sender
{
    NSLog(@"info button pressed");
}

//==============================================================================

#pragma mark - User card delegate -

//==============================================================================

- (void) switchButtonPressed
{
    HPUserCardOrPointView* container = (HPUserCardOrPointView*)self.carouselView.currentItemView;
    
    [UIView transitionWithView: container
                      duration: FLIP_ANIMATION_SPEED
                       options: UIViewAnimationOptionTransitionFlipFromRight
                    animations: ^{
                        [container switchSidesWithCardOrPoint: _cardOrPoint[_carouselView.currentItemIndex]
                                                     delegate: self];
                    }
                    completion: ^(BOOL finished){
                }];
}

//==============================================================================

#pragma mark - TRESHAK -

//==============================================================================
/*
- (void) messButtonPressedStart:(UIButton *)sender
{
    [self recreateSendMessageButton];
    [self.carouselView.currentItemView insertSubview: self.sendMessageButton
                                        belowSubview: sender];
}

//==============================================================================

- (void) messButtonPressedStop:(UIButton *)sender
{
    [self recreateSendMessageButton];
    [self.carouselView.currentItemView insertSubview: self.sendMessageButton
                                        belowSubview: sender];
}

//==============================================================================

- (void) recreateSendMessageButton
{
    [self.sendMessageButton removeFromSuperview];
    
    self.sendMessageButton = nil;
    self.sendMessageButton = [Utils getViewForGreenButtonForText:@"Написать ей" andTapped:NO];
    self.sendMessageButton.frame = CGRectMake(
                                            self.carouselView.currentItemView.frame.size.width / 2 - self.sendMessageButton.frame.size.width / 2,
                                            312,
                                            self.sendMessageButton.frame.size.width,
                                            self.sendMessageButton.frame.size.height);
}

//==============================================================================

- (void) showReceiptViewController:(NSString*) articleName {
    
}

//==============================================================================

- (void) removeImageViewFromItemWithIndex: (NSInteger) index andImage: (BOOL) clear
{
    UIView* prevView = [self.carouselView itemViewAtIndex: index];
    
    [prevView removeGestureRecognizer: self.tapGesture];
    self.tapGesture = nil;
    
    NSArray *subviews = [prevView subviews];
    for (UIView* v in subviews)
    {
        if (!clear)
        {
            if (![v isKindOfClass: [UIImageView class] ])
                [v removeFromSuperview];
        }
        else
        {
            [v removeFromSuperview];
        }
    }
}

//==============================================================================

- (UIImageView*) avatarView;
{
    HPUserCardView* cardView = (HPUserCardView*)_carouselView.currentItemView;
    return cardView.backgroundAvatar;
}

//==============================================================================

- (void)tapGesture: (UIPanGestureRecognizer *)recognizer
{
    [self animationViewsUp];
}

//==============================================================================

- (void)profileWillBeHidden
{
    [self animationViewsDown];
}

//==============================================================================

- (void) animationViewsUp
{
    CGRect rect = CGRectMake(0, 0, self.carouselView.currentItemView.frame.size.width, self.carouselView.currentItemView.frame.size.height);
    UIImage *captureImg = [Utils captureView: self.carouselView.currentItemView
                                    withArea: rect];
    
    //need get cell from left and right
    UIView* leftView;
    UIView* rightView;

    if ((self.carouselView.currentItemIndex > 0) &&
        (self.carouselView.currentItemIndex < self.carouselView.numberOfItems) &&
        (self.carouselView.currentItemIndex != self.carouselView.numberOfItems - 1))
    {
        leftView = [self.carouselView itemViewAtIndex: self.carouselView.currentItemIndex - 1];
        rightView = [self.carouselView itemViewAtIndex: self.carouselView.currentItemIndex + 1];
    }
    else
    {
        if (self.carouselView.currentItemIndex == 0)
        {
            leftView = [self.carouselView itemViewAtIndex: self.carouselView.numberOfItems - 1];
            rightView = [self.carouselView itemViewAtIndex: self.carouselView.currentItemIndex + 1];
        }
        else
        {
            if (self.carouselView.currentItemIndex == self.carouselView.numberOfItems - 1)
            {
                leftView = [self.carouselView itemViewAtIndex: self.carouselView.numberOfItems - 2];
                rightView = [self.carouselView itemViewAtIndex: 0];
            }
        }
    }
    
    rect = CGRectMake(0, 0, leftView.frame.size.width, leftView.frame.size.height);
    UIImage *captureImgLeft = [Utils captureView:leftView withArea: rect];
    
    rect = CGRectMake(0, 0, rightView.frame.size.width, rightView.frame.size.height);
    UIImage *captureImgRight = [Utils captureView:rightView withArea: rect];
    
    self.captView = [[UIImageView alloc] initWithImage: captureImg];
    self.captViewLeft = [[UIImageView alloc] initWithImage: captureImgLeft];
    self.captViewRight = [[UIImageView alloc] initWithImage: captureImgRight];
    
    CGRect result = [self.view convertRect: self.carouselView.currentItemView.frame
                                  fromView: self.carouselView.currentItemView];
    CGRect resultLeft = [self.view convertRect: leftView.frame
                                      fromView: leftView];
    CGRect resultRight = [self.view convertRect: rightView.frame
                                       fromView: rightView];
    self.captView.frame = result;
    self.captViewLeft.frame = resultLeft;
    self.captViewRight.frame = resultRight;
    self.carouselView.hidden = YES;
    [self.view addSubview:self.captView];
    [self.view addSubview:self.captViewLeft];
    [self.view addSubview:self.captViewRight];
    
    CGRect originalFrame = self.captViewLeft.frame;
    self.captViewLeft.layer.anchorPoint = CGPointMake(0.0, 1.0);
    self.captViewLeft.frame = originalFrame;
    
    originalFrame = self.captViewRight.frame;
    self.captViewRight.layer.anchorPoint = CGPointMake(1.0, 1.0);
    self.captViewRight.frame = originalFrame;
    
    [UIView animateWithDuration: 0.7
                          delay: 0
                        options: UIViewAnimationOptionTransitionNone
                     animations: ^
                                {
                                    CGRect captviewRect = CGRectMake(self.captView.frame.origin.x,
                                                                     self.captView.frame.origin.y - 450.0,
                                                                     self.captView.frame.size.width,
                                                                     self.captView.frame.size.height);
                                    self.captView.frame = captviewRect;
                                    self.captViewLeft.transform = CGAffineTransformMakeRotation(M_PI * 1.5);
                                    self.captViewRight.transform = CGAffineTransformMakeRotation(M_PI * -1.5);
                                }
                     completion: ^(BOOL finished)
                                {
                                }];

    HPUserProfileViewController *modal = [[HPUserProfileViewController alloc] initWithNibName: @"HPUserProfile" bundle: nil];
    modal.delegate = self;
    [self.navigationController hp_presentViewController: modal];
}

//==============================================================================

- (void) animationViewsDown
{
    [UIView animateWithDuration: 0.7
                          delay: 0
                        options: UIViewAnimationOptionTransitionNone
                     animations: ^
                        {
                            self.captView.frame = CGRectMake(self.captView.frame.origin.x,
                                                             self.captView.frame.origin.y + 450.0,
                                                             self.captView.frame.size.width,
                                                             self.captView.frame.size.height);
                            self.captViewLeft.transform = CGAffineTransformIdentity;
                            self.captViewRight.transform = CGAffineTransformIdentity;
                        }
                     completion:^(BOOL finished)
                        {
                            [self.captView removeFromSuperview];
                            [self.captViewLeft removeFromSuperview];
                            [self.captViewRight removeFromSuperview];
                            self.captView = nil;
                            self.captViewLeft  = nil;
                            self.captViewRight =  nil;
                            self.carouselView.hidden = NO;
                        }];
    [self.navigationController hp_popViewController];
}

//==============================================================================

- (void) messageButtonPressedStart:(UIButton *)sender
{

}

//==============================================================================

- (void) backButtonPressedStart:(id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

//==============================================================================

- (void) pointButtonTap:(id) sender
{
    self.viewState = !self.viewState;
    if(self.viewState) {
        //flip from right
        
        UIView *container = self.carouselView.currentItemView;
        UIView *viewToShow = [self createUserAnketa];
        
        [UIView transitionWithView:container
                          duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            
                            [self removeImageViewFromItemWithIndex:self.carouselView.currentItemIndex andImage:YES];
                            [self.carouselView.currentItemView addSubview:viewToShow];
                            
                        }
                        completion:^(BOOL finished){
                    }];

    } else {
        //flip from right
        UIView *container = self.carouselView.currentItemView;
        UIView *viewToShow = [self createUserCard];
        
        [UIView transitionWithView:container
                          duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{
                            
                            [self removeImageViewFromItemWithIndex:self.carouselView.currentItemIndex andImage:YES];
                            [self.carouselView.currentItemView addSubview: viewToShow];
                            
                        }
                        completion:^(BOOL finished){
                            
                        }];
        
    }
    
    [self.carouselView.currentItemView hp_roundViewWithRadius: 3];
}

//==============================================================================

- (UIView*) createUserCard
{
    UIButton* infoButton = [[UIButton alloc] initWithFrame:CGRectMake(12.0, 312, 32.0, 32.0)];
    [infoButton setImage:[UIImage imageNamed:@"Info Tap"] forState:UIControlStateHighlighted];
    [infoButton setImage:[UIImage imageNamed:@"Info"] forState:UIControlStateNormal];
    
    UIButton *pointButton = [[UIButton alloc] initWithFrame:CGRectMake(220.0, 12, 32.0, 32.0)];
    [pointButton setImage:[UIImage imageNamed:@"Point Tap"] forState:UIControlStateHighlighted];
    [pointButton setImage:[UIImage imageNamed:@"Point"] forState:UIControlStateNormal];
    [pointButton addTarget:self action:@selector(pointButtonTap:) forControlEvents:UIControlEventTouchUpInside];

    [self recreateSendMessageButton];
    
    UIButton *messButton = [[UIButton alloc] initWithFrame:self.sendMessageButton.frame];
    [messButton addTarget:self action:@selector(messButtonPressedStart:) forControlEvents: UIControlEventTouchDown];
    [messButton addTarget:self action:@selector(messButtonPressedStop:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView* temp = [[UIView alloc] initWithFrame:self.carouselView.currentItemView.frame];
    temp.backgroundColor = [UIColor clearColor];
    [temp addSubview: infoButton];
    [temp addSubview: pointButton];
    [temp addSubview: messButton];
    [temp addSubview: self.sendMessageButton];
    return temp;
}

//==============================================================================

- (UIView*) createUserAnketa
{
    UIView *temp = [[UIView alloc] initWithFrame:self.carouselView.currentItemView.frame];
    temp.backgroundColor = [UIColor clearColor];

    UIImage* scaledImage = [Utils scaleImage:[self avatarView].image toSize:CGSizeMake(264.0 + 90, 356.0 + 90)];
    UIImage *blureImg = [scaledImage hp_applyBlurWithRadius: 30.0];
    UIImageView *blureImgView = [[UIImageView alloc] initWithImage:blureImg];
    blureImgView.frame = CGRectMake(0, 0, 264.0, 356.0);
    blureImgView.contentMode = UIViewContentModeScaleToFill;

    [temp addSubview:blureImgView];
    UIImage *img =[UIImage imageNamed:@"img_sample1"];
    
    UIImage *img_ = [img hp_maskImageWithPattern: [UIImage imageNamed:@"Userpic Mask.png"]];
    UIImageView *avaImg = [[UIImageView alloc] initWithImage:img_];
    avaImg.frame = CGRectMake(84.0, 52, 92.0, 92.0);    //image size
    UIImageView *borderImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Userpic Shape Green"]];
    borderImg.frame = CGRectMake(2, 2, 88.0, 88.0);     //border size
    avaImg.autoresizingMask = UIViewAutoresizingNone;
    borderImg.autoresizingMask = UIViewAutoresizingNone;
    [avaImg addSubview:borderImg];
    [temp addSubview:avaImg];
    
    
    UILabel *pointLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.carouselView.currentItemView.frame.size.width/2.0 - 200/2, 130, 200, 100.0)];
    pointLabel.backgroundColor = [UIColor clearColor];
    pointLabel.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0f];
    pointLabel.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
    pointLabel.text = @"Предпочитаю вкладывать деньги в акции, нефть, газ, и разведение хомячков";
    pointLabel.numberOfLines = 5;
    pointLabel.textAlignment = NSTextAlignmentCenter;
    [temp addSubview:pointLabel];
    
    UILabel *timeMarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.carouselView.currentItemView.frame.size.width/2.0 - 100/2, 7, 100, 25.0)];
    timeMarkLabel.backgroundColor = [UIColor clearColor];
    timeMarkLabel.font = [UIFont fontWithName:@"FuturaPT-Light" size:16.0f];
    timeMarkLabel.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
    timeMarkLabel.text = @"Год назад:";
    timeMarkLabel.numberOfLines = 5;
    timeMarkLabel.textAlignment = NSTextAlignmentCenter;
    [temp addSubview:timeMarkLabel];
    
    
    UIButton *heartButton = [[UIButton alloc] initWithFrame:CGRectMake(self.carouselView.currentItemView.frame.size.width/2.0 - 12, 250.0, 24.0, 20.0)];
    [heartButton setImage:[UIImage imageNamed:@"Heart Tap"] forState:UIControlStateHighlighted];
    [heartButton setImage:[UIImage imageNamed:@"Heart"] forState:UIControlStateNormal];
    [temp addSubview:heartButton];
    
    
    UIButton *infoButton = [[UIButton alloc] initWithFrame:CGRectMake(12.0, 312, 32.0, 32.0)];
    [infoButton setImage:[UIImage imageNamed:@"Info Tap"] forState:UIControlStateHighlighted];
    [infoButton setImage:[UIImage imageNamed:@"Info"] forState:UIControlStateNormal];
    [temp addSubview:infoButton];
    
    UIButton *pointButton = [[UIButton alloc] initWithFrame:CGRectMake(220.0, 12, 32.0, 32.0)];
    [pointButton setImage:[UIImage imageNamed:@"Point Tap"] forState:UIControlStateHighlighted];
    [pointButton setImage:[UIImage imageNamed:@"Point"] forState:UIControlStateNormal];
    [pointButton addTarget:self action:@selector(pointButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    
    [self recreateSendMessageButton];
    
    UIButton *messButton = [[UIButton alloc] initWithFrame:self.sendMessageButton.frame];
    [messButton addTarget:self action:@selector(messButtonPressedStart:) forControlEvents: UIControlEventTouchDown];
    [messButton addTarget:self action:@selector(messButtonPressedStop:) forControlEvents:UIControlEventTouchUpInside];
    [temp addSubview:messButton];
    
    [temp addSubview:pointButton];
    [temp addSubview: self.sendMessageButton];
    
    return temp;
}

//==============================================================================

*/
@end
