//
//  HPUserCardViewController.h
//  HightPoint
//
//  Created by Andrey Anisimov on 13.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import <UIKit/UIKit.h>

#import "iCarousel.h"
#import "HPUserProfileViewController.h"
#import "HPUserCardView.h"
#import "HPGreenButtonVC.h"

//==============================================================================

@interface HPUserCardViewController : UIViewController <iCarouselDataSource, iCarouselDelegate, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate, UserCardViewProtocol, GreenButtonProtocol>

@property (nonatomic, strong) UIView *sendMessageButton;
@property (nonatomic, strong) IBOutlet iCarousel* carouselView;
@property (nonatomic, strong) IBOutlet UIButton* infoButton;
@property (nonatomic, strong) UIView *notificationView;

- (IBAction) slideLeftPressed: (id)sender;
- (IBAction) slideRightPressed: (id)sender;
- (IBAction) infoButtonPressed: (id)sender;

@end
