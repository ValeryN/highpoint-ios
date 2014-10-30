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
#import "RACCollectionViewController.h"

@protocol HPUserCardViewControllerDelegate <NSObject>
- (void) openChatControllerWithUser : (User*) user;
@end


@interface HPUserCardViewController : RACCollectionViewController <UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, HPUserCardViewControllerDelegate, UIScrollViewDelegate>
- (instancetype) initWithTableArraySignal:(RACSignal*) tableArray andSelectedUser:(User*) user;

@property (nonatomic, retain) RACSubject* changeViewedUserCard;
@property (nonatomic, retain) RACSubject* needLoadNextPage;

@end
