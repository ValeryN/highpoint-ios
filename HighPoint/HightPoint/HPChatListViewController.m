//
//  HPChatListViewController.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 08.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPChatListViewController.h"
#import "HPChatTableViewCell.h"
#import "UITextField+HighPoint.h"
#import "HPChatViewController.h"
#import "HPBaseNetworkManager.h"
#import "NotificationsConstants.h"
#import "DataStorage.h"


@interface HPChatListViewController ()

@end

@implementation HPChatListViewController {
    NSArray *contacts;
}

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
    contacts = [[NSArray alloc] init];
    [self.navigationController setNavigationBarHidden:NO];
    [self createNavigationItem];
    
    self.chatListTableView.delegate = self;
    self.chatListTableView.dataSource = self;
    //[[HPBaseNetworkManager sharedNetworkManager] getContactsRequest];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerNotification];
    [self updateCurrentView];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterNotification];
}

#pragma mark - notifications
- (void) registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrentView) name:kNeedUpdateContactListViews object:nil];
}

- (void) unregisterNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNeedUpdateContactListViews object:nil];
}

- (void) updateCurrentView {
    contacts = [[[DataStorage sharedDataStorage] getAllContactsFetchResultsController] fetchedObjects];
    NSLog(@"update contacts count = %lu", (unsigned long)contacts.count);
    [self.chatListTableView reloadData];
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
    self.navigationItem.title = NSLocalizedString(@"CHAT_LIST_TITLE", nil);
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
    self.navigationItem.title = @"";
    self.searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 25, 270, 30)];
    [self.searchTextField hp_tuneForSearchTextFieldInContactList :NSLocalizedString(@"SEARCH_FIELD_PLACEHOLDER", nil)];
    [self.navigationItem.leftBarButtonItem initWithCustomView:self.searchTextField];
    [self showCoverView];
    [self.searchTextField becomeFirstResponder];
    self.searchTextField.delegate = self;
    UIBarButtonItem* closeButton = [self createBarButtonItemWithImage: [UIImage imageNamed:@"Close.png"] highlighedImage: [UIImage imageNamed:@"Close Tap.png"] action: @selector(closeSearchTaped:)];
    self.navigationItem.rightBarButtonItem = closeButton;
}

- (void) closeSearchTaped: (id) sender
{
    [self hideSearchFieldElements];
}

- (void) hideSearchFieldElements {
    [self createNavigationItem];
    [self hideCoverView];
    [self.searchTextField removeFromSuperview];
    self.searchTextField = nil;
}


#pragma mark - delete chat
- (void)deleteChat:(TLSwipeForOptionsCell *)cell {
    [[HPBaseNetworkManager sharedNetworkManager] deleteContactRequest:((Contact *)[contacts objectAtIndex:cell.tag]).user.userId];
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
    
    [chatCell setDelegate:self];
    
    if (indexPath.row == 3) {
        [chatCell.avatar privacyLevel];
    }
    if(indexPath.row %3) {
        chatCell.msgCountView.hidden = YES;
    } else {
        chatCell.msgCountView.hidden = NO;
    }
    chatCell.currentMsgLabel.text = ((Contact *)[contacts objectAtIndex:indexPath.row]).lastmessage.text;
    chatCell.currentUserMsgLabel.text = ((Contact *)[contacts objectAtIndex:indexPath.row]).lastmessage.text;
    [chatCell fillCell: [contacts objectAtIndex:indexPath.row]];
    chatCell.tag = indexPath.row;
    return chatCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"count contacts = %lu", (unsigned long)contacts.count);
    return contacts.count;
    
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

- (void)cellDidTap:(TLSwipeForOptionsCell *)cell{
    NSLog(@"tap cell");
    HPChatViewController* chatController = [[HPChatViewController alloc] initWithNibName: @"HPChatViewController" bundle: nil];
    [self.navigationController pushViewController:chatController animated:YES];
}


#pragma mark - search text field
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (string.length > 0) {
        textField.text = [NSString stringWithFormat:@"%@%@", textField.text,string];
    } else {
        if (textField.text.length > 1) {
            textField.text = [NSString stringWithFormat:@"%@", [textField.text substringToIndex:[textField.text length] - 1 ]];
        } else {
            textField.text = @"";
        }
    }
    if (textField.text.length > 0) {
        contacts = [[[DataStorage sharedDataStorage] getContactsByQueryFetchResultsController:textField.text] fetchedObjects];
        NSLog(@"update contacts query count = %lu", (unsigned long)contacts.count);
        [self.chatListTableView reloadData];
    } else {
        contacts = [[[DataStorage sharedDataStorage] getAllContactsFetchResultsController] fetchedObjects];
        NSLog(@"update contacts all count = %lu", (unsigned long)contacts.count);
        [self.chatListTableView reloadData];
    }
    NSLog(@"changed");
    return NO;
}

#pragma mark - cover view
- (void) showCoverView {
    if (!self.coverView) {
        self.coverView = [[UIView alloc] initWithFrame:self.view.frame];
        self.coverView.backgroundColor = [UIColor colorWithRed: 30.0 / 255.0
                                                         green: 29.0 / 255.0
                                                          blue: 48.0 / 255.0
                                                         alpha: 1.0];
        self.coverView.alpha = 0.5;
        UITapGestureRecognizer *singleTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleCoverViewTap:)];
        [self.view addGestureRecognizer:singleTap];
    }
    [self.view addSubview:self.coverView];
}

- (void) hideCoverView {
    [self.coverView removeFromSuperview];
}

- (void)handleCoverViewTap:(UITapGestureRecognizer *)recognizer {
    [self hideSearchFieldElements];
}

@end
