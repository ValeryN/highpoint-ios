//
//  HPPointLikesViewController.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 21.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RACFetchedCollectionViewController.h"

@class User;

@interface HPPointLikesViewController : RACFetchedCollectionViewController <NSFetchedResultsControllerDelegate>
@property (nonatomic, retain) User* user;
@end
