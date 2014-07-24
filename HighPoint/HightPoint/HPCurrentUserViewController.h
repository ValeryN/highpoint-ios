//
//  HPCurrentUserViewController.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 10.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "UserCardOrPointProtocol.h"
#import "HPUserProfileViewController.h"
@class ModalAnimation;
@interface HPCurrentUserViewController : UIViewController <iCarouselDataSource, iCarouselDelegate, UserCardOrPointProtocol, UIViewControllerTransitioningDelegate,HPUserProfileViewControllerDelegate> {
    ModalAnimation *_modalAnimationController;
}

- (IBAction)backButtonTap:(id)sender;
- (IBAction)bubbleButtonTap:(id)sender;

@property (weak, nonatomic) IBOutlet iCarousel *carousel;


@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIButton *bubbleBtn;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIImageView *personalDataDownImgView;
@property (weak, nonatomic) IBOutlet UILabel *personalDataLabel;
@property (weak, nonatomic) IBOutlet UIButton *bottomBtn;
@property (nonatomic, strong) UIImageView *captView;
- (void) configurePublishPointNavigationItem;

@end
