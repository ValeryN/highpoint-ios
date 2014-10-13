//
//  HPUserCardUICollectionViewCell.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 01.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "City.h"
#import "UserPoint.h"
#import "HPUserCardViewController.h"
#import "RACTableViewController.h"

@interface HPUserCardUICollectionViewCell : UICollectionViewCell <RACTableViewCellProtocol>
@property (nonatomic, assign) id <HPUserCardViewControllerDelegate> delegate;

- (IBAction)sendMsgBtnTap:(id)sender;
- (IBAction)heartBtnTap:(id)sender;

- (void) bindViewModel:(id)viewModel;

@end
