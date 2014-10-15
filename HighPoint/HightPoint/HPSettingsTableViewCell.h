//
//  HPSettingsSwitchTableViewCell.h
//  HighPoint
//
//  Created by Eugene on 14/10/14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HPSettingsTableViewCell : UITableViewCell
@property(nonatomic, weak) IBOutlet UISwitch* switchView;
@property(nonatomic, weak) IBOutlet UILabel* propertyLabel;
@end
