//
//  HPCurrentUserPointCollectionViewCell.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 05.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HPCurrentUserPointCollectionViewCellDelegate <NSObject>
@required

- (void) startEditingPoint;
- (void) cancelPointTap;
- (void) sharePointTap;

@end


@interface HPCurrentUserPointCollectionViewCell : UICollectionViewCell <UITextViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) id<HPCurrentUserPointCollectionViewCellDelegate> delegate;
@property (assign, nonatomic) BOOL isUp;

@property (weak, nonatomic) IBOutlet UILabel *yourPointLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *pointInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *publishBtn;
@property (weak, nonatomic) IBOutlet UITextView *pointTextView;



//point settings
@property (weak, nonatomic) IBOutlet UIView *pointSettingsView;
@property (weak, nonatomic) IBOutlet UISlider *pointTimeSlider;
@property (weak, nonatomic) IBOutlet UILabel *pointTimeInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *publishSettBtn;


- (void) configureCell;
- (void) editPointUp;
- (void) editPointDown;

@end
