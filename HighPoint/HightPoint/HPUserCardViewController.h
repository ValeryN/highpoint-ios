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

//==============================================================================

@protocol UserImageStartAnimationDelegate <NSObject>
- (void) startAnimation:(UIImageView*) image;
@end

//==============================================================================

@interface HPUserCardViewController : UIViewController <iCarouselDataSource, iCarouselDelegate, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate, HPUserProfileViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIButton *profileButton;
@property (nonatomic, weak) IBOutlet UIButton *messageButton;
@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, strong) UIImageView *userImage;
@property (nonatomic, strong) UIView *notificationView;
@property (nonatomic, strong) UIView *messButtonView;
@property (nonatomic, strong) UIButton *infoButton;
@property (nonatomic, assign) BOOL dragging;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;
@property (nonatomic, assign) BOOL viewState;
@property (nonatomic, assign) NSInteger prevIndex;
@property (nonatomic, strong) IBOutlet iCarousel *carouselView;
@property (nonatomic, weak) id <UserImageStartAnimationDelegate> delegate;
@property(nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property(nonatomic, strong) UIImageView *captView;
@property(nonatomic, strong) UIImageView *captViewLeft;
@property(nonatomic, strong) UIImageView *captViewRight;

@end
