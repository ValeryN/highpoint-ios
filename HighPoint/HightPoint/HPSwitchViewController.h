//
//  HPSwitchViewController.h
//  HightPoint
//
//  Created by Andrey Anisimov on 08.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import <UIKit/UIKit.h>

//==============================================================================

@interface HPSwitchViewController : UIViewController <UIGestureRecognizerDelegate>
@property (nonatomic, weak) IBOutlet UIView *switchView;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundView;
@property (nonatomic, weak) IBOutlet UIImageView *centerPart;

@property (nonatomic, weak) IBOutlet UILabel *leftLabel;
@property (nonatomic, weak) IBOutlet UILabel *rightLabel;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGesture;

@property (nonatomic, assign) BOOL switchState;

@end
