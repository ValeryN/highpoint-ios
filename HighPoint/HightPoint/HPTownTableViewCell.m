//
//  HPTownTableViewCell.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 03.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPTownTableViewCell.h"

@implementation HPTownTableViewCell

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
    self.backgroundColor = [UIColor clearColor];
    self.townNameLabel.textColor = [UIColor whiteColor];
    if (city) {
        self.townNameLabel.text = city.cityName;
    } else {
        self.townNameLabel.text = NSLocalizedString(@"ADD_FILTER_CITY", nil);
    }
    
}

@end
