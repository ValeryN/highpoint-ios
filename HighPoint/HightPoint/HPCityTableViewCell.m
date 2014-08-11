//
//  HPCityTableViewCell.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 07.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPCityTableViewCell.h"

@implementation HPCityTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void) configureCell : (City *) city {
    self.cityNameLabel.font = [UIFont fontWithName:@"FuturaPT-Light" size:18.0 ];
    self.cityNameLabel.textAlignment = NSTextAlignmentLeft;
    self.cityNameLabel.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
    if (city) {
        self.cityNameLabel.text = city.cityName;
    } else {
        self.cityNameLabel.text = NSLocalizedString(@"ADD_FILTER_CITY", nil);
    }
}

@end
