//
//  HPSelectPopularCityViewController.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 12.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HPSelectPopularCityViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *citiesTableView;
@property (strong, nonatomic) NSMutableArray *popularCities;


@end
