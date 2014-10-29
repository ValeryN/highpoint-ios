//
//  HPSwitchViewController.h
//  HightPoint
//
//  Created by Andrey Anisimov on 08.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//


#import <UIKit/UIKit.h>


@protocol HPSwitchProtocol
- (void) switchedToLeft;
- (void) switchedToRight;
@end


@interface HPSwitchViewController : UIViewController <UIGestureRecognizerDelegate>

- (void) positionSwitcher: (CGRect) rect;

- (IBAction) swipeRightGesture:(UISwipeGestureRecognizer *)recognizer;
- (IBAction) swipeLeftGesture:(UISwipeGestureRecognizer *)recognizer;
- (IBAction) tapGesture:(UITapGestureRecognizer *)recognizer;

- (IBAction) buttonTap:(id)sender;

@property (nonatomic, weak) NSObject<HPSwitchProtocol>* delegate;

@property (nonatomic, weak) IBOutlet UIView *switchView;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundView;

@property (nonatomic, weak) IBOutlet UIButton *leftButton;
@property (nonatomic, weak) IBOutlet UIButton *leftButtonInactive;
@property (nonatomic, weak) IBOutlet UIButton *rightButton;
@property (nonatomic, weak) IBOutlet UIButton *rightButtonInactive;

@property (nonatomic) BOOL switchState;

@end
