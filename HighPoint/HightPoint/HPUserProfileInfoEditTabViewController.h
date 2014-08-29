//
// Created by Eugene on 22.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPUserProfileFirstRowTableViewCell.h"

@class User;


@interface HPUserProfileInfoEditTabViewController : UITableViewController <NSFetchedResultsControllerDelegate>
@property(strong, nonatomic) User *user;
@end
