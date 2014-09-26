//
//  HPUserCardViewController.h
//  HightPoint
//
//  Created by Andrey Anisimov on 13.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "iCarousel.h"
#import "HPUserProfileViewController.h"
#import "HPGreenButtonVC.h"
#import "HPUserInfoViewController.h"
@class ModalAnimation;


@protocol HPUserCardViewControllerDelegate <NSObject>

- (void) syncronizePosition : (NSInteger) currentPosition;
- (void) openChatControllerWithUser : (NSInteger) userIndex;

@end


@interface HPUserCardViewController : UIViewController <UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate, HPUserInfoViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, HPUserCardViewControllerDelegate, UIScrollViewDelegate>
{
    NSArray *usersArr;
    ModalAnimation *_modalAnimationController;
    
}
@property (nonatomic, strong) UIView *notificationView;
@property (nonatomic, assign) BOOL onlyWithPoints;
@property (nonatomic, assign) int current;
@property (weak, nonatomic) IBOutlet UICollectionView *usersCollectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bottomActivityView;
@property (assign, nonatomic) id <HPUserCardViewControllerDelegate> delegate;
@property (assign, nonatomic) int currentIndex;


@end
