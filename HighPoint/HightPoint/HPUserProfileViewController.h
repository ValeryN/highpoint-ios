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
//==============================================================================

@protocol  HPUserProfileViewControllerDelegate <NSObject>
- (void)profileWillBeHidden;
@end

//==============================================================================

@interface HPUserProfileViewController : UIViewController <RACollectionViewDelegateReorderableTripletLayout, RACollectionViewReorderableTripletLayoutDataSource, UITableViewDelegate, UITableViewDataSource, HEBubbleViewDataSource, HEBubbleViewDelegate>
@property (nonatomic, weak) IBOutlet UIButton *downButton;
@property (nonatomic, weak) IBOutlet UIView *barView;
@property (nonatomic, weak) id<HPUserProfileViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITableView *infoTableView;
@property (nonatomic, strong) NSMutableArray *photosArray;
@property (strong, nonatomic) User *user;
///////////////////////
@property(nonatomic, strong) NSArray *userDataSource;
@property(nonatomic, strong) NSDictionary *placeCityDataSource;
@property(nonatomic, strong) NSArray *educationDataSource;
@property(nonatomic, strong) NSArray *carrierDataSource;
//////////////////////
- (IBAction)downButtonTap:(id)sender;
- (IBAction)segmentedControlValueDidChange:(id)sender;
@end
