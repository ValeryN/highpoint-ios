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

//==============================================================================

@interface HPUserCardViewController : UIViewController <iCarouselDataSource, iCarouselDelegate, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate, UserCardViewProtocol>

@property (nonatomic, strong) UIView *sendMessageButton;
@property (nonatomic, strong) UIButton *infoButton;

@property (nonatomic, strong) IBOutlet iCarousel* carouselView;
@property(nonatomic, strong) UIImageView *captView;
@property(nonatomic, strong) UIImageView *captViewLeft;
@property(nonatomic, strong) UIImageView *captViewRight;

@property (nonatomic, strong) UIView *notificationView;
@property(nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, assign) BOOL dragging;
@property (nonatomic, assign) BOOL viewState;
@property (nonatomic, assign) NSInteger prevIndex;

- (IBAction) slideLeftPressed: (id)sender;
- (IBAction) slideRightPressed: (id)sender;
- (IBAction) infoButtonPressed: (id)sender;

@end
