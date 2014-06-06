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

@protocol HPSwitchProtocol
- (void) switchedToLeft;
- (void) switchedToRight;
@end

//==============================================================================

@interface HPSwitchViewController : UIViewController <UIGestureRecognizerDelegate>

- (IBAction) swipeRightGesture:(UISwipeGestureRecognizer *)recognizer;
- (IBAction) swipeLeftGesture:(UISwipeGestureRecognizer *)recognizer;
- (IBAction) tapGesture:(UITapGestureRecognizer *)recognizer;

@property (nonatomic, weak) NSObject<HPSwitchProtocol>* delegate;

@property (nonatomic, weak) IBOutlet UIView *switchView;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundView;
@property (nonatomic, weak) IBOutlet UIImageView *centerPart;

@property (nonatomic, weak) IBOutlet UILabel *leftLabel;
@property (nonatomic, weak) IBOutlet UILabel *rightLabel;

@property (nonatomic, assign) BOOL switchState;

@end
