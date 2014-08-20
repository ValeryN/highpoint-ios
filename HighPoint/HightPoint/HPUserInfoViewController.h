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

@interface HPUserInfoViewController : UIViewController <GreenButtonProtocol, UITableViewDelegate, UITableViewDataSource, iCarouselDelegate, iCarouselDataSource, UIGestureRecognizerDelegate, HEBubbleViewDataSource, HEBubbleViewDelegate, NSFetchedResultsControllerDelegate> {
    
}

@property (weak, nonatomic) IBOutlet UITableView *infoTableView;
@property (weak, nonatomic) IBOutlet iCarousel *carousel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *navSegmentedController;

@property (weak, nonatomic) IBOutlet UIView *topBarView;
@property (weak, nonatomic) IBOutlet UIView *photoCountView;

@property (nonatomic, weak) id<HPUserInfoViewControllerDelegate> delegate;
@property (strong, nonatomic) User *user;
@property (weak, nonatomic) IBOutlet UILabel *profileHiddenLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentController;
@property (nonatomic, strong) HPGreenButtonVC* sendMessage;
@property(nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property(nonatomic, strong) NSArray *userDataSource;
@property(nonatomic, strong) NSMutableDictionary *placeCityDataSource;
@property(nonatomic, strong) NSMutableArray *educationDataSource;
@property(nonatomic, strong) NSMutableArray *carrierDataSource;
@property(nonatomic, strong) NSMutableArray *languages;
@property (nonatomic, strong) NSFetchedResultsController *selectedUser;


//privacy
@property (weak, nonatomic) IBOutlet UIImageView *lockImgView;
@property (weak, nonatomic) IBOutlet UILabel *privacyInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *openReqBtn;
@property (weak, nonatomic) IBOutlet UIButton *goToChat;




@property(nonatomic, assign) BOOL tapState;
- (IBAction)segmentedControlValueDidChange:(id)sender;
- (IBAction) backbuttonTaped: (id) sender;

@end
