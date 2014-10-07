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


@interface HPUserCardUICollectionViewCell : UICollectionViewCell




@property (nonatomic, assign) id <HPUserCardViewControllerDelegate> delegate;

- (IBAction)sendMsgBtnTap:(id)sender;
- (IBAction)heartBtnTap:(id)sender;

- (void) configureCell : (User *) user ;

@end
