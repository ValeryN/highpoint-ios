//
//  HPUserProfileViewController.h
//  HighPoint
//
//  Created by Andrey Anisimov on 27.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import <UIKit/UIKit.h>
#import "RACollectionViewReorderableTripletLayout.h"
#import "HEBubbleView.h"
#import "HEBubbleViewItem.h"
#import "User.h"
#import "HPAddPhotoMenuViewController.h"
#import "iCarousel.h"
#import "HPUserProfileFirstRowTableViewCell.h"
#import "HPAddNewTownCellView.h"
#import "HPSelectTownViewController.h"
#import "HPAddEducationViewController.h"
#import "HPBubbleTextField.h"
//==============================================================================
//==============================================================================

@interface HPUserProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, iCarouselDelegate, iCarouselDataSource, HEBubbleViewDataSource, HEBubbleViewDelegate, HPAddPhotoMenuViewControllerDelegate, HPUserProfileFirstRowTableViewCellDelegate, UITextFieldDelegate, HPAddNewTownViewDelegate, HPSelectTownViewControllerDelegate, HPAddEducationViewControllerDelegate, HPBubbleTextFieldDelegate>
@property (nonatomic, weak) IBOutlet UIButton *downButton;
@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic, weak) IBOutlet UILabel *barTitle;
@property (nonatomic, weak) IBOutlet UIView *barView;

@property (weak, nonatomic) IBOutlet UITableView *infoTableView;
@property (nonatomic, strong) NSMutableArray *photosArray;
@property (strong, nonatomic) User *user;
///////////////////////
@property(nonatomic, strong) NSArray *userDataSource;
@property(nonatomic, strong) NSMutableDictionary *placeCityDataSource;
@property(nonatomic, strong) NSMutableArray *languages;
@property(nonatomic, strong) NSMutableArray *educationDataSource;
@property(nonatomic, strong) NSMutableArray *carrierDataSource;
@property(nonatomic, strong) UIView *greenButton;
@property(nonatomic, strong) UIButton* deletButton;
@property(nonatomic, strong) UIView *tappedGreenButton;
@property (nonatomic, strong) HEBubbleView *currentBubble;
@property (nonatomic, assign) NSInteger prepareForDeleteIndex;
@property (nonatomic, assign) NSInteger backSpaceTapCount;
@property (nonatomic, strong) HPBubbleTextField *currentBubbleTextField;
@property (weak, nonatomic) IBOutlet iCarousel *carousel;
@property(nonatomic, strong) HPAddPhotoMenuViewController *addPhotoViewController;
//////////////////////
- (IBAction)downButtonTap:(id)sender;
- (IBAction)backButtonTap:(id)sender;
- (IBAction)segmentedControlValueDidChange:(id)sender;
@end
