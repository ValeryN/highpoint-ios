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



#define KEYBOARD_HEIGHT 216
#define MSGS_TEST_COUNT 11;


@interface HPChatViewController () {
    NSMutableArray *msgs;
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
    [self createNavigationItem];
    self.msgTextView.delegate = self;
    self.chatTableView.delegate = self;
    self.chatTableView.dataSource = self;
    [self initMsgs];
    // Do any additional setup after loading the view from its nib.
}

- (void) initMsgs {
     msgs = [[NSMutableArray alloc] init];
    for (int i = 0; i < 5; i++) {
       
        Message *msg = [[Message alloc] init];
        msg.messageBody = @"сообщение";
        if (i%2) {
            msg.messageBody = @"сообщение сообщение сообщение сообщение сообщение сообщение  сообщение сообщение сообщение сообщение  сообщение сообщение сообщение сообщение  сообщение сообщение сообщение сообщение";
        }
        
        if (i%5) {
            msg.messageBody = @"сообщение сообщение  сообщение сообщение сообщение сообщение";
        }
        
        [msgs addObject:msg];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    self.navigationItem.title = @"Анастасия";
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
    
    CGRect frame = self.msgTextView.frame;
//    CGRect oldFrame = self.msgTextView.frame;
//    CGRect viewFrame = self.msgBottomView.frame;
    
    frame.size.height = self.msgTextView.contentSize.height;
    if (self.msgTextView.frame.size.height < self.msgTextView.contentSize.height) {
        NSLog(@"up");
        frame.origin.y = frame.origin.y - 16;
    }
    
    if ((self.msgTextView.frame.size.height > self.msgTextView.contentSize.height) && (text.length < 1)) {
        NSLog(@"down");
        frame.origin.y = frame.origin.y + 16;
    }
    
//    if ((oldFrame.size.height < frame.size.height) && (self.msgTextView.frame.size.height < self.msgTextView.contentSize.height)) {
//        viewFrame.origin.y = viewFrame.origin.y - 16;
//        viewFrame.size.height = viewFrame.size.height + 16;
//        self.msgBottomView.frame = viewFrame;
//    }
//    
//    if ((oldFrame.size.height > frame.size.height) && ((self.msgTextView.frame.size.height > self.msgTextView.contentSize.height) && (text.length < 1))) {
//        viewFrame.origin.y = viewFrame.origin.y + 16;
//        viewFrame.size.height = viewFrame.size.height - 16;
//        self.msgBottomView.frame = viewFrame;
//    }
    
    self.msgTextView.frame = frame;
    
    
    
    return YES;
}


- (void)textViewDidBeginEditing:(UITextView *)textView {

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
    //TODO: send msg
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
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < msgs.count) {
        UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:18.0];
        CGSize constraintSize = CGSizeMake(250.0f, 600);
        CGSize labelSize = [((Message *)[msgs objectAtIndex:indexPath.row]).messageBody sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        return labelSize.height + 32;
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
    headerView.backgroundColor = [UIColor clearColor];
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 320, 16)];
    dateLabel.text = @"Сегодня, 25 июня";
    [dateLabel setTextAlignment:UITextAlignmentCenter];
    dateLabel.textColor = [UIColor grayColor];
    [headerView addSubview:dateLabel];
    return headerView;
}

@end
