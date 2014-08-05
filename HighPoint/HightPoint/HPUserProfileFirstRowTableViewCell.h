//
//  HPUserInfoFirstRowTableViewCell.h
//  HighPoint
//
//  Created by Andrey Anisimov on 21.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMRangeSlider.h"
#import "User.h"
@protocol  HPUserProfileFirstRowTableViewCellDelegate <NSObject>
- (void) sliderValueChange:(NMRangeSlider*) sender;
@end

@interface HPUserProfileFirstRowTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *cellTextLabel;
@property (nonatomic, weak) id<HPUserProfileFirstRowTableViewCellDelegate> delegate;
@property (nonatomic, weak) IBOutlet NMRangeSlider *oldRangeSlider;
@property (nonatomic, strong) User *user;
- (void) configureSlider:(BOOL) hidden;
- (IBAction)labelSliderChanged:(NMRangeSlider*)sender;

@end
