//
//  HPUserProfileViewController.m
//  HighPoint
//
//  Created by Andrey Anisimov on 27.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "HPUserProfileViewController.h"
#import "UIDevice+HighPoint.h"

//==============================================================================

#define GREEN_BUTTON_BOTTOM 20
#define PHOTOS_NUMBER 4
#define SPACE_BETWEEN_PHOTOS 20

//==============================================================================

@implementation HPUserProfileViewController

//==============================================================================

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self addConstraint];
    
    [self createGreenButton];
}

//==============================================================================

- (void) addConstraint
{
    NSArray* cons = self.view.constraints;
    for (NSLayoutConstraint* consIter in cons)
    {
        NSLog(@"constraint %@", consIter);
//        if (consIter.firstAttribute == NSLayoutAttributeWidth)
//            consIter.constant = [UIScreen mainScreen].bounds.size.width;
//        if (consIter.firstAttribute == NSLayoutAttributeHeight)
//            consIter.constant = [UIScreen mainScreen].bounds.size.height - 64;
    }


//          [self.view addConstraint: [NSLayoutConstraint constraintWithItem: self.view
//                                                                 attribute: NSLayoutAttributeTop
//                                                                 relatedBy: NSLayoutRelationEqual
//                                                                    toItem: _photoScroller
//                                                                 attribute: NSLayoutAttributeTop
//                                                                multiplier: 1.0
//                                                                  constant: 0]];

//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem: self.view
//                                                                 attribute: NSLayoutAttributeHeight
//                                                                 relatedBy: NSLayoutRelationEqual
//                                                                    toItem: nil
//                                                                 attribute: NSLayoutAttributeNotAnAttribute
//                                                                multiplier: 1.0
//                                                                  constant: [UIScreen mainScreen].bounds.size.height - 64]];
}

//==============================================================================

- (void) createGreenButton
{
    HPGreenButtonVC* sendMessage = [[HPGreenButtonVC alloc] initWithNibName: @"HPGreenButtonVC" bundle: nil];
    sendMessage.view.translatesAutoresizingMaskIntoConstraints = NO;
    sendMessage.delegate = self;

    CGRect rect = sendMessage.view.frame;
    CGRect bounds = [UIScreen mainScreen].bounds;
    rect.origin.x = (bounds.size.width - rect.size.width) / 2.0f;
    rect.origin.y = bounds.size.height - rect.size.height - GREEN_BUTTON_BOTTOM;
    sendMessage.view.frame = rect;

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
}

//==============================================================================

- (void) greenButtonPressed: (HPGreenButtonVC*) button
{
    NSLog(@"Green button pressed");
}

//==============================================================================

#pragma mark - iCarousel data source -

//==============================================================================

- (NSUInteger)numberOfItemsInCarousel: (iCarousel*) carousel
{
    return PHOTOS_NUMBER;
}

//==============================================================================

- (UIView*)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{   
    NSLog(@"index %i", index);
    view = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"img_sample"]];
    CGRect rect = CGRectMake([UIScreen mainScreen].bounds.size.width,
                                0,
                                [UIScreen mainScreen].bounds.size.width,
                                _photoScroller.frame.size.height);
    view.frame = rect;

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
    return 320;
}

//==============================================================================

@end
