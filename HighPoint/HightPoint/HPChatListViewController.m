//
//  HPChatListViewController.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 08.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPChatListViewController.h"
#import "HPChatTableViewCell.h"

@interface HPChatListViewController ()

@end

@implementation HPChatListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    [self createNavigationItem];
    
    self.chatListTableView.delegate = self;
    self.chatListTableView.dataSource = self;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - create navigation item 
- (void) createNavigationItem
{

    
    UIBarButtonItem* searchButton = [self createBarButtonItemWithImage: [UIImage imageNamed:@"Lens.png"]
                                                     highlighedImage: [UIImage imageNamed:@"Lens Tap.png"]
                                                              action: @selector(searchTaped:)];
    self.navigationItem.rightBarButtonItem = searchButton;
    
    
    UIBarButtonItem* backButton = [self createBarButtonItemWithImage: [UIImage imageNamed:@"Close.png"]
                                                     highlighedImage: [UIImage imageNamed:@"Close Tap.png"]
                                                              action: @selector(backbuttonTaped:)];
    self.navigationItem.leftBarButtonItem = backButton;
    self.navigationItem.title = @"Сообщения";
}


- (UIBarButtonItem*) createBarButtonItemWithImage: (UIImage*) image
                                  highlighedImage: (UIImage*) highlighedImage
                                           action: (SEL) action
{
    UIButton* newButton = [UIButton buttonWithType: UIButtonTypeCustom];
    newButton.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [newButton setBackgroundImage: image forState: UIControlStateNormal];
    [newButton setBackgroundImage: highlighedImage forState: UIControlStateHighlighted];
    [newButton addTarget: self
                  action: action
        forControlEvents: UIControlEventTouchUpInside];
    
    UIBarButtonItem* newbuttonItem = [[UIBarButtonItem alloc] initWithCustomView: newButton];
    
    return newbuttonItem;
}

- (void) backbuttonTaped: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

- (void) searchTaped: (id) sender
{
    self.navigationItem.leftBarButtonItem = nil;
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(5, 25, 280, 30)];
    self.searchBar.showsCancelButton = NO;
    self.searchBar.translucent = YES;
    self.searchBar.placeholder = @"Введите имя, возраст или город";
    [self.searchBar sizeToFit];
    self.navigationItem.titleView = self.searchBar;
    [self.searchBar becomeFirstResponder];
    self.searchBar.delegate = self;
    UIBarButtonItem* closeButton = [self createBarButtonItemWithImage: [UIImage imageNamed:@"Close.png"] highlighedImage: [UIImage imageNamed:@"Close Tap.png"] action: @selector(closeSearchTaped:)];
    self.navigationItem.rightBarButtonItem = closeButton;
}


- (void) closeSearchTaped: (id) sender
{
    [self createNavigationItem];
    [self.searchBar removeFromSuperview];
    self.searchBar = nil;
}


#pragma mark - table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *townCellIdentifier = @"chatCell";
    HPChatTableViewCell *chatCell = (HPChatTableViewCell *)[tableView dequeueReusableCellWithIdentifier:townCellIdentifier];
    
    if (chatCell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HPChatTableViewCell" owner:self options:nil];
        chatCell = [nib objectAtIndex:0];
    }
    [chatCell configureCell];
    if (indexPath.row == 3) {
        [chatCell.avatar privacyLevel];
    }
    return chatCell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 104;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - search bar 
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 0) {
        //search and find users
    } else {
        //show all
    }
}


@end
