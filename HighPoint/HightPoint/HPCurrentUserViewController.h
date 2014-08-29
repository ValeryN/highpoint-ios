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
#import "HPCurrentUserUICollectionViewCell.h"

@class ModalAnimation;
@interface HPCurrentUserViewController : UIViewController < UIViewControllerTransitioningDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, HPCurrentUserPointCollectionViewCellDelegate,HPCurrentUserUICollectionViewCellDelegate>
@property(nonatomic, retain) RACSignal *avatarSignal;
@property (nonatomic, retain) RACSignal * randomUsersForLikes;
@end
