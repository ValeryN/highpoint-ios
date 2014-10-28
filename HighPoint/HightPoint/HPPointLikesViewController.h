//
//  HPPointLikesViewController.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 21.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RACFetchedTableViewController.h"

@class User;

@interface HPPointLikesViewController : RACFetchedTableViewController <NSFetchedResultsControllerDelegate>
@property (nonatomic, retain) User* user;
@end
