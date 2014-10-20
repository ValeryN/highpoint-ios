//
//  HPUserProfileViewController.h
//  HighPoint
//
//  Created by Andrey Anisimov on 27.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//


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


@interface HPUserProfileViewController : UIViewController
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentControl;
@property (strong, nonatomic) User *user;


@end
