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

#define ICAROUSEL_ITEMS_COUNT 50
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

- (void) fixUserPointConstraint
{
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
    NSLog(@"index %i", index);
    if (_cardOrPoint == nil)
        NSAssert(YES, @"no description for carousel item");
    view = [[HPUserCardOrPointView alloc] initWithCardOrPoint: _cardOrPoint[index]
                                                     delegate: self];

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
    [_cardOrPoint[_carouselView.currentItemIndex] switchUserPoint];
    
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

- (void) heartTapped
{
    NSLog(@"heart tapped");
}

//==============================================================================

@end
