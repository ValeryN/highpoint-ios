//
// Created by Eugene on 28.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPSearchCityCell.h"
#import "City.h"

@interface HPSearchCityCell()
@property (nonatomic, weak) IBOutlet UILabel * cityLabel;
@end

@implementation HPSearchCityCell

- (void)bindViewModel:(City*) cityModel {
     self.cityLabel.text = cityModel.cityName;
}

@end