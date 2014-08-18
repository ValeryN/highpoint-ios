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



@end
