//
//  HPCurrentUserViewController.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 10.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPUserProfileViewController.h"
#import "HPCurrentUserPointCollectionViewCell.h"

@class ModalAnimation;
@interface HPCurrentUserViewController : UIViewController < UIViewControllerTransitioningDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, HPCurrentUserPointCollectionViewCellDelegate> {
    ModalAnimation *_modalAnimationController;
}

- (IBAction)backButtonTap:(id)sender;
- (IBAction)settingsBtnTap:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIButton *settingsBtn;
@property (weak, nonatomic) IBOutlet UICollectionView *currentUserCollectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageController;


@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIImageView *personalDataDownImgView;
@property (weak, nonatomic) IBOutlet UILabel *personalDataLabel;
@property (weak, nonatomic) IBOutlet UIButton *bottomBtn;
@property (nonatomic, strong) UIImageView *captView;
- (void) configurePublishPointNavigationItem;



@end
