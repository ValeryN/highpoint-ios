//
//  HPTownTableViewCell.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 03.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "City.h"

@interface HPTownTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *townNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *isSelectedImgView;

- (void) configureCell : (City *) city;

@end
