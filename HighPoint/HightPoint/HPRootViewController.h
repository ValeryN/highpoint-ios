//
//  HPRootViewController.h
//  HighPoint
//
//  Created by Andrey Anisimov on 22.04.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "HPSwitchViewController.h"
#import "HPFilterSettingsViewController.h"
#import "ScaleAnimation.h"
#import "CrossDissolveAnimation.h"
#import "HPUserCardViewController.h"
#import "HPSpinnerView.h"
#import "RACTableViewController.h"


@interface HPRootViewController : RACTableViewController <UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate>
{
    
}


@end
