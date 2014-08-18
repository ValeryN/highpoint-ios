//
//  HPCurrentUserPointCollectionViewCell.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 05.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPSlider.h"

@protocol HPCurrentUserPointCollectionViewCellDelegate <NSObject>
@required

- (void) startEditingPoint;
- (void) cancelPointTap;
- (void) sharePointTap;
- (void) startDeletePoint;
- (void) endDeletePoint;

@end


@interface HPCurrentUserPointCollectionViewCell : UICollectionViewCell <UITextViewDelegate, UIGestureRecognizerDelegate>

@property (assign, nonatomic) id<HPCurrentUserPointCollectionViewCellDelegate> delegate;
@property (assign, nonatomic) BOOL isUp;

@property (weak, nonatomic) IBOutlet UILabel *yourPointLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *pointInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *publishBtn;
@property (weak, nonatomic) IBOutlet UITextView *pointTextView;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;


//point settings
@property (weak, nonatomic) IBOutlet UIView *pointSettingsView;
@property (weak, nonatomic) IBOutlet HPSlider *pointTimeSlider;
@property (weak, nonatomic) IBOutlet UILabel *pointTimeInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *publishSettBtn;


//point delete
@property (weak, nonatomic) IBOutlet UIView *deletePointView;
@property (weak, nonatomic) IBOutlet UILabel *deletePointInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *deletePointSettBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelDelBtn;

- (void) configureCell;
- (void) editPointUp;
- (void) editPointDown;

@end
