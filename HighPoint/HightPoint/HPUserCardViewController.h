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
#import "RACFetchedCollectionViewController.h"

@protocol HPUserCardViewControllerDelegate <NSObject>
- (void) openChatControllerWithUser : (User*) user;
@end


@interface HPUserCardViewController : RACFetchedCollectionViewController <UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, HPUserCardViewControllerDelegate, UIScrollViewDelegate>
- (void) initWithPosition:(NSInteger) position;

@property (nonatomic, retain) NSFetchedResultsController* searchController;
@property (nonatomic, retain) RACSubject* changeViewedUserCard;

@end
