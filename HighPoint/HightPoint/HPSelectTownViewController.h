//
//  HPSelectTownViewController.h
//  HighPoint
//
//  Created by Andrey Anisimov on 23.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "City.h"

@protocol  HPSelectTownViewControllerDelegate <NSObject>
- (void) newTownSelected:(City*) town;
@end

@interface HPSelectTownViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate>


@property (weak, nonatomic) IBOutlet UITableView *townsTableView;
@property (weak, nonatomic) IBOutlet UITextField *townSearchBar;
@property (nonatomic, weak) id<HPSelectTownViewControllerDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *selectedPath;
@property (nonatomic, strong) NSMutableArray *allCities;


@end
