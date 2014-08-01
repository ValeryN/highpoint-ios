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


@interface HPUserCardUICollectionViewCell : UICollectionViewCell


@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendMsgBtn;
@property (weak, nonatomic) IBOutlet UIButton *heartBtn;
@property (weak, nonatomic) IBOutlet UITextView *pointTextView;
@property (weak, nonatomic) IBOutlet UIButton *pointBtn;
@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *photoCountLabel;



- (IBAction)sendMsgBtnTap:(id)sender;
- (IBAction)heartBtnTap:(id)sender;
- (IBAction)pointBtnTap:(id)sender;

- (void) configureCell : (User *) user ;

@end
