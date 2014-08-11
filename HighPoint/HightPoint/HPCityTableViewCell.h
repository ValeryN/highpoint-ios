//
//  HPCityTableViewCell.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 07.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "City.h"


@interface HPCityTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *cityNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowRigthImgVIew;


- (void) configureCell : (City *) city;

@end
