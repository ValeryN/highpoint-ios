//
//  HPPointLikeCollectionViewCell.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 21.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPAvatarView.h"
#import "RACFetchedCollectionViewController.h"

@class User;

@interface HPPointLikeCollectionViewCell : UICollectionViewCell<RACCollectionViewCellProtocol>
- (void)bindViewModel:(User *)viewModel;
@end
