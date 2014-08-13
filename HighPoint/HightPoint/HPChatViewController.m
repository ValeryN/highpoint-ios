//
//  HPChatViewController.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 24.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPChatViewController.h"
#import "UINavigationController+HighPoint.h"
#import "HPChatMsgTableViewCell.h"
#import "HPChatOptionsTableViewCell.h"
#import "UILabel+HighPoint.h"
#import "UITextView+HightPoint.h"
#import "UIDevice+HighPoint.h"
#import "HPBaseNetworkManager.h"
#import "DataStorage.h"
#import "HPBaseNetworkManager.h"
#import "NotificationsConstants.h"


#define KEYBOARD_HEIGHT 216
#define MSGS_TEST_COUNT 11
#define MAX_COMMENT_LENGTH 250

#define CONSTRAINT_TOP_BOTTOMVIEW 431
#define CONSTRAINT_TOP_ACTIVITYBOTTOM 400



@interface HPChatViewController () {
    NSArray *msgs;
    BOOL isFirstLoad;
}

@end

@implementation HPChatViewController

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
    isFirstLoad = YES;
    [self createNavigationItem];
    self.msgTextView.delegate = self;
    self.chatTableView.delegate = self;
    self.chatTableView.dataSource = self;
    msgs = [[NSArray alloc] init];
    self.currentUser = [[DataStorage sharedDataStorage] getCurrentUser];
    self.msgTextView.text = NSLocalizedString(@"YOUR_MSG_PLACEHOLDER", nil);
    [self.msgTextView hp_tuneForTextViewMsgText];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerNotification];
    msgs = [[[DataStorage sharedDataStorage] getChatByUserId:self.contact.user.userId].message allObjects];
    [self initElements];
    [self fixSelfConstraint];
    //[self setSwipeForTableView];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self unregisterNotification];
}

- (void) viewDidAppear:(BOOL)animated {
    if (msgs.count > 0) {
        if (self.chatTableView.contentSize.height > self.chatTableView.frame.size.height)
        {
            CGPoint offset = CGPointMake(0, self.chatTableView.contentSize.height - self.chatTableView.frame.size.height);
            [self.chatTableView setContentOffset:offset animated:YES];
        }
    }
    isFirstLoad = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrentView) name:kNeedUpdateChatView object:nil];
}


- (void) unregisterNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNeedUpdateChatView object:nil];
}


#pragma mark - update 

- (void) updateCurrentView {
    msgs = [[[DataStorage sharedDataStorage] getChatByUserId:self.contact.user.userId].message allObjects];
    [self initElements];
    [self.chatTableView reloadData];
    NSLog(@"chat updated for = %@", self.contact.user.userId);
}


#pragma mark - msgs count 
- (void) initElements {
    if (msgs.count > 0) {
        self.retryBtn.hidden = YES;
        self.chatTableView.hidden = NO;
    } else {
        self.retryBtn.hidden = NO;
        self.chatTableView.hidden = YES;
    }
}

#pragma mark - scroll for time
- (void) setSwipeForTableView {
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    recognizer.cancelsTouchesInView = NO;
    [self.chatTableView addGestureRecognizer:recognizer];
}

- (void) handlePanFrom: (UIGestureRecognizer *) recognizer {
    NSLog(@"pan");
   // CGPoint startLocation;
    
    NSArray *cells = [self.chatTableView visibleCells];
    for (HPChatMsgTableViewCell *cell in cells)
    {
        if ([cell isKindOfClass:[HPChatMsgTableViewCell class]]) {
          //   [cell scrollCellForTimeShowing];
        }
       
    }
    
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        
//        
////       startLocation = [recognizer locationInView:self.view];
//    }
//    else if (recognizer.state == UIGestureRecognizerStateEnded) {
//        
//        
////        CGPoint stopLocation = [recognizer locationInView:self.view];
////        CGFloat dx = stopLocation.x - startLocation.x;
////        CGFloat dy = stopLocation.y - startLocation.y;
////        CGFloat distance = sqrt(dx*dx + dy*dy );
////        NSLog(@"Distance: %f", distance);
//    }
}

- (void) scrollCellsForTimeShowing : (CGPoint) point {
    NSArray *cells = [self.chatTableView visibleCells];
    for (HPChatMsgTableViewCell *cell in cells)
    {
        if ([cell isKindOfClass:[HPChatMsgTableViewCell class]]) {
            [cell scrollCellForTimeShowingCell :point];
        }
        
    }

}

#pragma mark - constraints

- (void) fixSelfConstraint {
    
    if (![UIDevice hp_isWideScreen])
    {
        NSArray* cons = self.view.constraints;
        for (NSLayoutConstraint* consIter in cons)
        {
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == self.msgBottomView))
                consIter.constant = CONSTRAINT_TOP_BOTTOMVIEW;
            
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == self.bottomActivityIndicator))
                consIter.constant = CONSTRAINT_TOP_ACTIVITYBOTTOM;
            
            }
    }
}


#pragma mark - navigation bar
- (void) createNavigationItem
{
    UIBarButtonItem* backButton = [self createBarButtonItemWithImage: [UIImage imageNamed:@"Back.png"]
                                                     highlighedImage: [UIImage imageNamed:@"Back Tap.png"]
                                                              action: @selector(backbuttonTaped:)];
    self.navigationItem.leftBarButtonItem = backButton;
    UIView *avatarView = [[UIView alloc] initWithFrame:CGRectMake(0, 15, 36.0f, 36.0f)];
    avatarView.backgroundColor = [UIColor clearColor];
    self.avatar = [HPAvatarLittleView createAvatar: [UIImage imageNamed:@"img_sample1.png"]];
    [avatarView addSubview: self.avatar];
    UIBarButtonItem *avatarBarItem = [[UIBarButtonItem alloc]initWithCustomView:avatarView];
    self.navigationItem.rightBarButtonItem = avatarBarItem;
    self.navigationItem.title = self.contact.user.name;
    [self.navigationController hp_configureNavigationBar];
}


- (UIBarButtonItem*) createBarButtonItemWithImage: (UIImage*) image
                                  highlighedImage: (UIImage*) highlighedImage
                                           action: (SEL) action
{
    UIButton* newButton = [UIButton buttonWithType: UIButtonTypeCustom];
    newButton.frame = CGRectMake(0, 0, 11, 22);
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


#pragma mark - backgound tap
- (IBAction)backgroundTap:(id)sender {
    NSLog(@"bg tap");
    [self.view endEditing:YES];
}

#pragma mark - text view


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ((self.msgTextView.text.length > MAX_COMMENT_LENGTH) && (text.length > 0)) {
        return NO;
    }
    
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    float possibleHeight = screenHeight - KEYBOARD_HEIGHT - 64;
    CGRect frame = self.msgTextView.frame;
    CGRect viewFrame = self.bgBottomView.frame;
    frame.size.height = self.msgTextView.contentSize.height;
    if (textView.text.length > 0) {
        if (self.msgTextView.frame.size.height < self.msgTextView.contentSize.height) {
            NSLog(@"up");
            frame.origin.y = frame.origin.y - 20;
            viewFrame.origin.y = viewFrame.origin.y - 20;
            viewFrame.size.height = viewFrame.size.height + 20;
        }
    }
    if ((self.msgTextView.frame.size.height > self.msgTextView.contentSize.height) && (text.length < 1)) {
        NSLog(@"down");
        frame.origin.y = frame.origin.y + 20;
        viewFrame.origin.y = viewFrame.origin.y + 20;
        viewFrame.size.height = viewFrame.size.height - 20;
    }
    if (possibleHeight > viewFrame.size.height) {
        self.msgTextView.frame = frame;
        self.bgBottomView.frame = viewFrame;
    }
    return YES;
}


- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:NSLocalizedString(@"YOUR_MSG_PLACEHOLDER", nil)]) {
        textView.text = @"";
        [textView hp_tuneForTextViewMsgText];
    }
    [textView becomeFirstResponder];
    
    CGRect newFrame = self.msgBottomView.frame;
    newFrame.origin.y = newFrame.origin.y - KEYBOARD_HEIGHT;
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         self.msgBottomView.frame = newFrame;
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    if ([textView.text isEqualToString:@""]) {
        textView.text = NSLocalizedString(@"YOUR_MSG_PLACEHOLDER", nil);
        [textView hp_tuneForTextViewPlaceholderText];
    }
    [textView resignFirstResponder];
    
    CGRect newFrame = self.msgBottomView.frame;
    newFrame.origin.y = newFrame.origin.y + KEYBOARD_HEIGHT;
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         self.msgBottomView.frame = newFrame;
                     }
                     completion:^(BOOL finished){
                     }];
}


#pragma mark - button handlers
- (IBAction)addMsgTap:(id)sender {
    [self.view endEditing:YES];
    self.bgBottomView.frame = CGRectMake(0, 0, 320, 49);
    self.msgTextView.frame = CGRectMake(48, 5, 261, 34);
    self.msgTextView.text = NSLocalizedString(@"YOUR_MSG_PLACEHOLDER", nil);
    [self.msgTextView hp_tuneForTextViewMsgText];
    //TODO: send msg
}


- (IBAction)retryBtnTap:(id)sender {
    [[HPBaseNetworkManager sharedNetworkManager] getChatMsgsForUser:self.contact.user.userId :nil];
}

#pragma mark - scroll view


- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!isFirstLoad) {
        CGFloat scrollPosition = self.chatTableView.contentSize.height - self.chatTableView.frame.size.height - self.chatTableView.contentOffset.y;
        NSLog(@"scroll position = %f", scrollPosition);
        if (scrollPosition < -40)// you can set your value
        {
            if (!self.bottomActivityIndicator.isAnimating) {
                [self.bottomActivityIndicator startAnimating];
                [[HPBaseNetworkManager sharedNetworkManager] getChatMsgsForUser:self.contact.user.userId :nil];
            }
        } else {
            if (self.bottomActivityIndicator.isAnimating) {
                [self.bottomActivityIndicator stopAnimating];
                NSLog(@"scroll stop");
            }
        }
    }
}


#pragma mark - table view


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < msgs.count) {
        static NSString *msgCellIdentifier = @"ChatMsgCell";
        HPChatMsgTableViewCell *msgCell = (HPChatMsgTableViewCell *)[tableView dequeueReusableCellWithIdentifier:msgCellIdentifier];
        
        if (msgCell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HPChatMsgTableViewCell" owner:self options:nil];
            msgCell = [nib objectAtIndex:0];
        }
        msgCell.delegate = self;
        msgCell.currentUserId = self.currentUser.userId;
        [msgCell configureSelfWithMsg:[msgs objectAtIndex:indexPath.row]];
        return msgCell;
    } else {
        static NSString *msgOptCellIdentifier = @"ChatMsgOptions";
        HPChatOptionsTableViewCell *msgOptCell = (HPChatOptionsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:msgOptCellIdentifier];
        
        if (msgOptCell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HPChatOptionsTableViewCell" owner:self options:nil];
            msgOptCell = [nib objectAtIndex:0];
        }
        return msgOptCell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return msgs.count + 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < msgs.count) {
        UIFont *cellFont = [UIFont fontWithName:@"FuturaPT-Book" size:18.0];
        CGSize constraintSize = CGSizeMake(250.0f, 1000);
        CGSize labelSize = [((Message *)[msgs objectAtIndex:indexPath.row]).text sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        return labelSize.height + 40;
    } else {
        return 32;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    headerView.backgroundColor = [UIColor colorWithRed: 30.0 / 255.0
                                                 green: 29.0 / 255.0
                                                  blue: 48.0 / 255.0
                                                 alpha: 1.0];
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 320, 16)];
    dateLabel.text = @"Сегодня, 25 июня";
    [dateLabel setTextAlignment:UITextAlignmentCenter];
    dateLabel.textColor = [UIColor grayColor];
    [dateLabel hp_tuneForHeaderAndInfoInMessagesList];
    [headerView addSubview:dateLabel];
    return headerView;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}


@end
