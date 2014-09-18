//
//  HPChatViewController.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 24.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPChatViewController.h"
#import "DataStorage.h"
#import "UIViewController+HighPoint.h"
#import "NSManagedObjectContext+HighPoint.h"
#import "HPAvatarView.h"
#import "HPRequest.h"
#import "HPRequest+Users.h"
#import "HPChatMsgTableViewCell.h"
#import "HPHorizontalPanGestureRecognizer.h"
#import "UITextView+HPRacSignal.h"


@interface HPChatViewController ()

@property(strong, nonatomic) HPAvatarView *avatar;
@property(strong, nonatomic) UIView *avatarView;
@property(weak, nonatomic) IBOutlet UITableView *chatTableView;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *bottomInputViewOffset;
@property(weak, nonatomic) IBOutlet UIView *tableHeaderView;

//bottom view
@property(weak, nonatomic) IBOutlet UIView *msgBottomView;
@property(weak, nonatomic) IBOutlet UIButton *msgAddBtn;
@property(weak, nonatomic) IBOutlet UIButton *sendMessageButton;
@property(weak, nonatomic) IBOutlet UITextView *msgTextView;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *msgTextViewHeight;
@property(weak, nonatomic) IBOutlet UILabel *msgPlacehoderTextView;


@property(nonatomic) NSDate *minimumViewedDate;
@property(nonatomic, retain) NSMutableDictionary *sizeCacheByObjectId;
@property(nonatomic) BOOL inputMode;


@property(nonatomic, retain) RACSignal *keyboardHeightSignal;
@end


#define NUMBER_PER_PAGE_LOAD 20
#define MIN_SCROLLTOP_PIXEL_TO_LOAD 400.f

@implementation HPChatViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.cachedCellHeight = YES;
    [self configureInfinityTableView];
    [self configureTableView:self.chatTableView withSignal:self.messagesController andTemplateCell:[UINib nibWithNibName:@"HPChatMsgTableViewCell" bundle:nil]];
    [self configureInputMode];
    [self configureNavigationBar];
    [self configureOffsetTableViewGesture];
    [self configureInputView];
    [self configureSendMessageButton];
}

- (void)configureSendMessageButton {
    @weakify(self);
    RAC(self, sendMessageButton.hidden) = [[RACSignal merge:@[self.msgTextView.rac_textSignal, RACObserve(self, msgTextView.text)]] map:^id(NSString *value) {
        return @(value.length == 0);
    }];
    [[self.sendMessageButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self sendMessageToCurrentContactWithText:self.msgTextView.text];
        self.msgTextView.text = @"";
    }];
}

- (void)configureInputMode {
    @weakify(self);
    [[self keyboardHeightSignal] subscribeNext:^(RACTuple *x) {
        @strongify(self);
        RACTupleUnpack(NSNumber *height, NSNumber *duration, NSNumber *options) = x;
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:duration.doubleValue delay:0 options:(UIViewAnimationOptions) options.unsignedIntegerValue animations:^{
            @strongify(self);
            self.bottomInputViewOffset.constant = height.floatValue;
            [self.view layoutIfNeeded];
        }                completion:nil];
    }];
}

- (RACSignal *)keyboardHeightSignal {
    if (!_keyboardHeightSignal) {
        RACSignal *keyboardChangeHeight = [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillChangeFrameNotification object:nil] map:^id(NSNotification *value) {
            return [RACTuple tupleWithObjects:@([value.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height), value.userInfo[UIKeyboardAnimationDurationUserInfoKey], value.userInfo[UIKeyboardAnimationCurveUserInfoKey], nil];
        }] takeUntil:[self rac_willDeallocSignal]];
        RACSignal *keyboardHidden = [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] map:^id(NSNotification *value) {
            return [RACTuple tupleWithObjects:@(0), value.userInfo[UIKeyboardAnimationDurationUserInfoKey], value.userInfo[UIKeyboardAnimationCurveUserInfoKey], nil];
        }] takeUntil:[self rac_willDeallocSignal]];
        _keyboardHeightSignal = [[[RACSignal return:[RACTuple tupleWithObjects:@(0), @(0), @(0), nil]] concat:[RACSignal merge:@[keyboardChangeHeight, keyboardHidden]]] replayLast];
    }
    return _keyboardHeightSignal;
}

- (void)configureInputView
{
    self.msgTextView.delegate = self;
    @weakify(self);
    UISwipeGestureRecognizer *swipeGestureRecognizer = [UISwipeGestureRecognizer new];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [[swipeGestureRecognizer rac_gestureSignal] subscribeNext:^(id x) {
        @strongify(self);
        [self.msgTextView resignFirstResponder];
    }];
    [self.msgBottomView addGestureRecognizer:swipeGestureRecognizer];

    RACSignal *textChanged = [[RACSignal merge:@[[self.msgTextView rac_textSignal], RACObserve(self, msgTextView.text)]] replayLast];
    RAC(self, msgPlacehoderTextView.hidden) = [[textChanged map:^id(NSString *value) {
        return @(value.length == 0);
    }] not];

    RACSignal *heightForTextView = [[[RACSignal merge:@[[self.msgTextView rac_textSignal], RACObserve(self, msgTextView.text)]] map:^id(NSValue *value) {
        @strongify(self);
        CGFloat fixedWidth = self.msgTextView.frame.size.width;
        CGSize newSize = [self.msgTextView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        return @(ceilf(newSize.height));
    }] distinctUntilChanged];
    RAC(self, msgTextViewHeight.constant) = [heightForTextView map:^id(NSNumber *value) {
        return value.floatValue <= 70.f?value:@70.f;
    }];
    [heightForTextView subscribeNext:^(NSNumber *value) {
        @strongify(self);
        self.msgTextView.scrollEnabled = value.floatValue >= 70.f;
        self.msgTextView.frame = (CGRect) {self.msgTextView.frame.origin, self.msgTextView.frame.size.width, self.msgTextViewHeight.constant};
        self.msgTextView.contentSize = (CGSize) {self.msgTextView.frame.size.width, value.floatValue};
        [self.view layoutIfNeeded];
    }];
    [self.msgTextView.rac_textBeginEdit subscribeNext:^(id x) {
        @strongify(self);
        [self scrollTableViewToBottom];
    }];

}

- (void)scrollTableViewToBottom {
    NSInteger sectionIndex = [self numberOfSectionsInTableView:self.chatTableView] - 1;
    NSInteger rowIndex = [self tableView:self.chatTableView numberOfRowsInSection:sectionIndex] - 1;
    if (sectionIndex >= 0 && rowIndex >= 0)
        [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:rowIndex inSection:sectionIndex] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)configureOffsetTableViewGesture {
    @weakify(self);
    HPHorizontalPanGestureRecognizer *panGestureRecognizer = [[HPHorizontalPanGestureRecognizer alloc] init];
    __block CGFloat startLocation = 0;
    [[panGestureRecognizer rac_gestureSignal] subscribeNext:^(HPHorizontalPanGestureRecognizer *x) {
        @strongify(self);
        switch (x.state) {
            case UIGestureRecognizerStatePossible:
                break;
            case UIGestureRecognizerStateBegan:
                startLocation = [x locationInView:x.view].x;
                break;
            case UIGestureRecognizerStateChanged: {
                CGFloat offset = [x locationInView:x.view].x - startLocation;
                if (offset > 0) {
                    self.offsetX = offset > 50 ? 50 : offset;
                }
            }
                break;
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateFailed:
                self.offsetX = 0;
                break;
        }
    }];
    [self.chatTableView addGestureRecognizer:panGestureRecognizer];
}


- (void)configureInfinityTableView {
    @weakify(self);
//
//    self.chatTableView.contentOffset = (CGPoint){0,self.msgTextView.frame.size.height - 30};
//
    RACSignal *contentSizeSignal = [RACObserve(self.chatTableView, contentSize) replayLast];
    [[[[[contentSizeSignal skip:1] combinePreviousWithStart:[NSValue valueWithCGSize:(CGSize) {0, 0}] reduce:^id(id previous, id current) {
        CGFloat prevHeight = [previous CGSizeValue].height;
        CGFloat newHeight = [current CGSizeValue].height;
        return @(newHeight - prevHeight);
    }] filter:^BOOL(NSNumber *value) {
        return value.intValue > 0;
    }] skip:2] subscribeNext:^(NSNumber *x) {
        @strongify(self);
        //Update on frame change
        self.chatTableView.contentOffset = (CGPoint) {0, self.chatTableView.contentOffset.y + x.floatValue};
    }];


    [[[contentSizeSignal filter:^BOOL(NSValue *value) {
        return [value CGSizeValue].height > self.chatTableView.frame.size.height;
    }] take:1] subscribeNext:^(id x) {
        @strongify(self);
        //Scroll to bottom
        self.chatTableView.contentOffset = (CGPoint) {0, self.chatTableView.contentSize.height - self.chatTableView.frame.size.height};
    }];

    RACSignal *contentOffsetSignal = [RACObserve(self.chatTableView, contentOffset) replayLast];
    [[[[contentOffsetSignal map:^id(id value) {
        CGFloat offset = [value CGPointValue].y;
        return @(offset < MIN_SCROLLTOP_PIXEL_TO_LOAD);;
    }] distinctUntilChanged] filter:^BOOL(NSNumber *x) {
        return x.boolValue;
    }] subscribeNext:^(NSNumber *x) {
        @strongify(self);
        self.minimumViewedDate = [self getDateOffsetAfterDate:self.minimumViewedDate andNumberPerPage:NUMBER_PER_PAGE_LOAD];
        [self checkIfNeedLoadNewMessagesFromServer];
    }];

    [contentOffsetSignal subscribeNext:^(id x) {
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        if (menuController.menuVisible) {
            [menuController setMenuVisible:NO];
        }
    }];
}


#pragma mark - navigation bar

- (void)configureNavigationBar {
    UIBarButtonItem *backButton = [self createBarButtonItemWithImage:[UIImage imageNamed:@"Back.png"]
                                                     highlighedImage:[UIImage imageNamed:@"Back Tap.png"]
                                                              action:@selector(backButtonTaped:)];
    self.navigationItem.leftBarButtonItem = backButton;
    UIView *avatarView = [[UIView alloc] initWithFrame:CGRectMake(0, 15, 36.0f, 36.0f)];
    avatarView.backgroundColor = [UIColor clearColor];
    self.avatar = [HPAvatarView avatarViewWithUser:[[DataStorage sharedDataStorage] getCurrentUser]];
    self.avatar.frame = (CGRect) {0, 0, 36, 36};
    [avatarView addSubview:self.avatar];
    UIBarButtonItem *avatarBarItem = [[UIBarButtonItem alloc] initWithCustomView:avatarView];

    self.navigationItem.rightBarButtonItem = avatarBarItem;
    self.navigationItem.title = self.contact.user.name;
}


- (void)backButtonTaped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (RACSignal *)messagesController {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    @weakify(self);
    return [[RACObserve(self, minimumViewedDate) flattenMap:^id(NSDate *minDate) {
        return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
            @strongify(self);
            [context performBlock:^{
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
                [request setEntity:entity];
                NSMutableArray *sortDescriptors = [NSMutableArray array]; //@"averageRating"
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:YES];
                [sortDescriptors addObject:sortDescriptor];
                [request setSortDescriptors:sortDescriptors];
                request.fetchBatchSize = 20;

                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bindedUserId = %@ AND createdAt >= %@", self.contact.user.userId, minDate ?: [NSDate date]];
                [request setPredicate:predicate];

                NSFetchedResultsController *messagesController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:@"createdAtDaySection" cacheName:nil];

                NSError *error = nil;
                if (![messagesController performFetch:&error]) {
                    [subscriber sendNext:error];
                }
                [subscriber sendNext:messagesController];
                [subscriber sendCompleted];
            }];
            return nil;
        }];
    }] replayLast];

}

- (NSDate *)getDateOffsetAfterDate:(NSDate *)date andNumberPerPage:(NSUInteger)numberPerPage {
    if (date == nil) {
        date = [NSDate date];
    }
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    [request setEntity:entity];
    NSMutableArray *sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    request.fetchBatchSize = 1;
    request.fetchLimit = numberPerPage;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bindedUserId = %@ and createdAt < %@", self.contact.user.userId, date];
    [request setPredicate:predicate];

    NSFetchedResultsController *messagesController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    NSError *error = nil;
    if (![messagesController performFetch:&error]) {
        NSLog(@"error get date");
    }

    if (messagesController.fetchedObjects.count > 0) {
        return ((Message *) messagesController.fetchedObjects.lastObject).createdAt;
    }

    return date;
}

- (void)checkIfNeedLoadNewMessagesFromServer {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    [request setEntity:entity];
    NSMutableArray *sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:YES];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    request.fetchLimit = 1;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bindedUserId = %@", self.contact.user.userId];
    [request setPredicate:predicate];

    Message *minMessageFromServer;
    NSArray *resultArray = [context executeFetchRequest:request error:nil];
    if (resultArray.count > 0) {
        minMessageFromServer = resultArray[0];
    }
    @weakify(self);
    self.chatTableView.tableHeaderView = self.tableHeaderView;
    [[HPRequest getMessagesForUser:self.contact.user afterMessage:minMessageFromServer] subscribeCompleted:^{
        @strongify(self);
        if (self.chatTableView.contentOffset.y < MIN_SCROLLTOP_PIXEL_TO_LOAD)
            self.minimumViewedDate = [self getDateOffsetAfterDate:self.minimumViewedDate andNumberPerPage:NUMBER_PER_PAGE_LOAD];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HPChatMsgTableViewCell *cell = (HPChatMsgTableViewCell *) [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.tableViewController = self;
    return cell;
}


//- (NSMutableDictionary *)calculateHeightBeforeLoading:(NSFetchedResultsController *)resultsController {
//    NSMutableDictionary *newSizesDict = [NSMutableDictionary new];
//    BOOL lastMessageMine = NO;
//    User *currentUser = [[DataStorage sharedDataStorage] getCurrentUser];
//    for (Message *message in resultsController.fetchedObjects) {
//        BOOL messageByMine = [((Message *) [message moveToContext:[NSManagedObjectContext threadContext]]).sourceId isEqualToNumber:currentUser.userId];
//        NSManagedObjectID *objectID = message.objectID;
//        if (!self.sizeCacheByObjectId[objectID]) {
//            self.sizeCacheByObjectId[objectID] = @([HPChatMsgTableViewCell heightForRowWithModel:message]);
//        }
//        NSString *key = [self.class stringRepresentationIndexPath:[resultsController indexPathForObject:message]];
//        if (lastMessageMine == messageByMine) {
//            newSizesDict[key] = self.sizeCacheByObjectId[objectID];
//        }
//        else {
//            lastMessageMine = messageByMine;
//            newSizesDict[key] = @(((NSNumber *) self.sizeCacheByObjectId[objectID]).floatValue + 10);
//        }
//    }
//    return newSizesDict;
//}


- (void)sendMessageToCurrentContactWithText:(NSString *)text {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    [[DataStorage sharedDataStorage] createAndSaveMessage:@{@"id" : @(arc4random() % 50000), @"createdAt" : [df stringFromDate:[NSDate date]], @"destinationId" : self.contact.user.userId, @"sourceId" : [[DataStorage sharedDataStorage] getCurrentUser].userId, @"text" : text} forUserId:self.contact.user.userId andMessageType:HistoryMessageType withComplation:^(Message *object) {
        [[DataStorage sharedDataStorage] setAndSaveMessageStatus:MessageStatusSending forMessage:object];
        [self performSelector:@selector(markMessage:) withObject:object afterDelay:5];
    }];
}

- (void)markMessage:(Message *)message {
    [[DataStorage sharedDataStorage] setAndSaveMessageStatus:MessageStatusSendFailed forMessage:message];
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

/*
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self registerNotification];
    msgs = [.message allObjects];
    [self initElements];
    [self fixSelfConstraint];
    [self sortMessages];
    //[self setSwipeForTableView];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self unregisterNotification];
    [self.chatTableView setContentOffset:CGPointZero];
}

- (void) viewDidAppear:(BOOL)animated {
    if (msgs.count > 0) {
        if (self.chatTableView.contentSize.height > self.chatTableView.frame.size.height)
        {
            CGPoint offset = CGPointMake(0, self.chatTableView.contentSize.height - self.chatTableView.frame.size.height);
            [self.chatTableView setContentOffset:offset animated:NO];
        }
    }
    isFirstLoad = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - notifications

- (void) registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrentView) name:kNeedUpdateChatView object:nil];
}


- (void) unregisterNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNeedUpdateChatView object:nil];
}

#pragma mark - msgs sorting
- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:inputDate];
    return [calendar dateFromComponents:components];
}

- (void) sortMessages {
    self.sections = [NSMutableDictionary dictionary];
    for (Message *msg in msgs)
    {
        NSDate *dateRepresentingThisDay = msg.createdAt;
        NSLog(@"message list object = %@ %@ %@",msg.text, msg.sourceId, msg.createdAt);
        NSMutableArray *msgsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
        if (msgsOnThisDay == nil) {
            msgsOnThisDay = [NSMutableArray array];
            [self.sections setObject:msgsOnThisDay forKey:dateRepresentingThisDay];
        }
        [msgsOnThisDay addObject:msg];
    }
    NSArray *unsortedDays = [self.sections allKeys];
    self.sortedDays = [unsortedDays sortedArrayUsingSelector:@selector(compare:)];

    NSLog(@"sections = %@", self.sections);
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MMM-dd HH:mm:ss"];
    for (NSDate *date in self.sortedDays) {
        NSString *strFromDate = [formatter stringFromDate:date];
        NSLog(@"%@", strFromDate);
    }
}



#pragma mark - update 

- (void) updateCurrentView {
    msgs = [[[DataStorage sharedDataStorage] getChatByUserId:self.contact.user.userId].message allObjects];
    [self initElements];
    [self sortMessages];
    [self.chatTableView reloadData];
    NSLog(@"chat contains %d elements", msgs.count);
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


- (void)showUserInfo :(UITapGestureRecognizer *)recognizer
{
    NSLog(@"show user info");
    User * usr = [[DataStorage sharedDataStorage] getUserForId:self.contact.user.userId];
    if(usr) {
        [[HPBaseNetworkManager sharedNetworkManager] makeReferenceRequest:[[DataStorage sharedDataStorage] prepareParamFromUser:usr]];
    }
    HPUserInfoViewController* uiController = [[HPUserInfoViewController alloc] initWithNibName: @"HPUserInfoViewController" bundle: nil];
    uiController.delegate = self;
    uiController.user = usr;
    [self.navigationController pushViewController:uiController animated:YES];
}

- (void) backButtonTaped: (id) sender
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
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         weakSelf.msgBottomView.frame = newFrame;
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
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         weakSelf.msgBottomView.frame = newFrame;
                     }
                     completion:^(BOOL finished){
                     }];
}

#pragma mark - date string
- (NSString *) getDateString : (NSDate *) date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSInteger day = [components day];
    NSInteger month = [components month];
    NSInteger year = [components year];
    return [NSString stringWithFormat:@"%d %@ %d", day, [months objectAtIndex:month-1], year];
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
        //NSLog(@"scroll position = %f", scrollPosition);
        if (scrollPosition < -40)
        {
            if (!self.bottomActivityIndicator.isAnimating) {
                [self.bottomActivityIndicator startAnimating];
                [[HPBaseNetworkManager sharedNetworkManager] getChatMsgsForUser:self.contact.user.userId :nil];
            }
        } else {
            if (self.bottomActivityIndicator.isAnimating) {
                [self.bottomActivityIndicator stopAnimating];
            }
        }
    }
}


#pragma mark - table view


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row < msgs.count) {
//
        static NSString *msgCellIdentifier = @"ChatMsgCell";
        HPChatMsgTableViewCell *msgCell = (HPChatMsgTableViewCell *)[tableView dequeueReusableCellWithIdentifier:msgCellIdentifier];
        
        if (msgCell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HPChatMsgTableViewCell" owner:self options:nil];
            msgCell = [nib objectAtIndex:0];
        }
        NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:indexPath.section];
        NSArray *msgsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
        Message *msg = [msgsOnThisDay objectAtIndex:indexPath.row];
        //msgCell.delegate = self;
        msgCell.currentUserId = self.currentUser.userId;
        [msgCell configureSelfWithMsg:msg];
        return msgCell;
//    } else {
//        static NSString *msgOptCellIdentifier = @"ChatMsgOptions";
//        HPChatOptionsTableViewCell *msgOptCell = (HPChatOptionsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:msgOptCellIdentifier];
//        
//        if (msgOptCell == nil)
//        {
//            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HPChatOptionsTableViewCell" owner:self options:nil];
//            msgOptCell = [nib objectAtIndex:0];
//        }
//        return msgOptCell;
//    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:section];
    NSArray *msgsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
    NSLog(@"count msgs for section  = %d", msgsOnThisDay.count);
    return [msgsOnThisDay count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:indexPath.section];
    NSArray *msgsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
    Message *msg = [msgsOnThisDay objectAtIndex:indexPath.row];
    UIFont *cellFont = [UIFont fontWithName:@"FuturaPT-Book" size:18.0];
    CGSize constraintSize = CGSizeMake(250.0f, 1000.0f);
    CGRect textRect = [msg.text boundingRectWithSize:constraintSize
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:cellFont}
                                             context:nil];
    CGSize labelSize = textRect.size;
    return labelSize.height + 40;
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
    
    
    dateLabel.text = [self getDateString:[self.sortedDays objectAtIndex:section]];
    [dateLabel setTextAlignment:NSTextAlignmentCenter];
    dateLabel.textColor = [UIColor grayColor];
    [dateLabel hp_tuneForHeaderAndInfoInMessagesList];
    [headerView addSubview:dateLabel];
    return headerView;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

*/
@end
