//
//  HPFilterSettingsViewController.h
//  HighPoint
//
//  Created by Andrey Anisimov on 22.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "City.h"

@interface HPFilterSettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UserGenderType gender;
@property (nonatomic, retain) City* city;
@property (nonatomic) NSUInteger fromAge;
@property (nonatomic) NSUInteger toAge;

@end
