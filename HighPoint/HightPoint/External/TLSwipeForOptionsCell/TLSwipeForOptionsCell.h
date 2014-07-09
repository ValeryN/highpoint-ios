//
//  TLSwipeForOptionsCell.h
//  UITableViewCell-Swipe-for-Options
//
//  Created by Ash Furrow on 2013-07-29.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TLSwipeForOptionsCell;

@protocol TLSwipeForOptionsCellDelegate <NSObject>
@optional
- (void)signToInvoice:(TLSwipeForOptionsCell *)cell;
- (void)addToTemplate:(TLSwipeForOptionsCell *)cell;
- (void)cellDidTap:(TLSwipeForOptionsCell *)cell;
- (void)cellWillSwipe:(TLSwipeForOptionsCell *)cell;
@end

extern NSString *const TLSwipeForOptionsCellEnclosingTableViewDidBeginScrollingNotification;

@interface TLSwipeForOptionsCell : UITableViewCell

@property (nonatomic, weak) id<TLSwipeForOptionsCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *costTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *costSumlabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconBg;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIView *colorCellView;
//@property(nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, weak) UIView *scrollViewContentView;
@property (nonatomic, weak) UIScrollView *scrollView;

//The cell content (like the label) goes in this view.
@property (nonatomic, weak) UIView *scrollViewButtonView;       //Contains our two buttons

@property (nonatomic, weak) UILabel *scrollViewLabel;

-(void)resetCell;
@end
