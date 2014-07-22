//
//  HPUserInfoViewController.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 10.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "iCarousel.h"
#import "HPGreenButtonVC.h"
#import "HEBubbleView.h"
#import "HEBubbleViewItem.h"

@protocol  HPUserInfoViewControllerDelegate <NSObject>
- (void)profileWillBeHidden;
@end

@interface HPUserInfoViewController : UIViewController <GreenButtonProtocol, UITableViewDelegate, UITableViewDataSource, iCarouselDelegate, iCarouselDataSource, UIGestureRecognizerDelegate, HEBubbleViewDataSource, HEBubbleViewDelegate> {
    
}

@property (weak, nonatomic) IBOutlet UITableView *infoTableView;
@property (weak, nonatomic) IBOutlet iCarousel *carousel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *navSegmentedController;

@property (weak, nonatomic) IBOutlet UIView *topBarView;
@property (weak, nonatomic) IBOutlet UIView *photoCountView;

@property (nonatomic, weak) id<HPUserInfoViewControllerDelegate> delegate;
@property (strong, nonatomic) User *user;
@property (nonatomic, strong) HPGreenButtonVC* sendMessage;
@property(nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property(nonatomic, strong) NSArray *userDataSource;
@property(nonatomic, strong) NSDictionary *placeCityDataSource;
@property(nonatomic, strong) NSArray *educationDataSource;
@property(nonatomic, strong) NSArray *carrierDataSource;
@property(nonatomic, assign) BOOL tapState;
- (IBAction)segmentedControlValueDidChange:(id)sender;
- (IBAction) backbuttonTaped: (id) sender;

@end
