//
//  HPChatListViewController.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 08.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HPChatListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>


@property (weak, nonatomic) IBOutlet UITableView *chatListTableView;
@property (strong, nonatomic) UISearchBar *searchBar;

@end