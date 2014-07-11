//
//  HPSelectTownViewController.h
//  HighPoint
//
//  Created by Andrey Anisimov on 23.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HPSelectTownViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate>


@property (weak, nonatomic) IBOutlet UITableView *townsTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *townSearchBar;


@property (nonatomic, strong) NSMutableArray *allCities;


@end
