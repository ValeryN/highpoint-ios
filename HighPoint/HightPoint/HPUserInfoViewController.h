//
//  HPUserInfoViewController.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 10.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface HPUserInfoViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    UISegmentedControl *navSegmentedController;
}

@property (weak, nonatomic) IBOutlet UITableView *infoTableView;
@property (strong, nonatomic) User *user;

@end
