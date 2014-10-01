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
@property(weak, nonatomic) IBOutlet UIButton *sendOpenProfileButton;
@property(weak, nonatomic) IBOutlet UITextView *msgTextView;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *msgTextViewHeight;
@property(weak, nonatomic) IBOutlet UILabel *msgPlacehoderTextView;

@property(nonatomic) NSDate *minimumViewedDate;
@property(nonatomic) BOOL openingMode;
@property(nonatomic, retain) RACSignal *keyboardHeightSignal;
@end


#define NUMBER_PER_PAGE_LOAD 20
#define MIN_SCROLL_TOP_PIXEL_TO_LOAD 400.f

@implementation HPChatViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.cachedCellHeight = YES;
    [self configureInfinityTableView];
    [self.navigationController setNavigationBarHidden:NO];
    [self configureTableView:self.chatTableView withSignal:self.messagesController andTemplateCell:[UINib nibWithNibName:@"HPChatMsgTableViewCell" bundle:nil]];
    [self addTemplateCell:[UINib nibWithNibName:@"HPChatMsgOpenAllowCell" bundle:nil]];
    [self addTemplateCell:[UINib nibWithNibName:@"HPChatMsgOpenDenyCell" bundle:nil]];
    [self addTemplateCell:[UINib nibWithNibName:@"HPChatMsgOpenRequestCell" bundle:nil]];
    [self configureInputMode];
    [self configureNavigationBar];
    [self configureOffsetTableViewGesture];
    [self configureInputView];
    [self configureSendMessageOrOpenProfileButton];
}

- (NSString *)cellIdentifierForModel:(Message *)model {
    switch ((MessageType) model.messageType.unsignedIntegerValue) {
        case MessageTypePlain:
            return @"HPChatMsgTableViewCell";
        case MessageTypeOpenRequest:
            return @"HPChatMsgOpenRequestCell";
        case MessageTypeOpenAllowResponse:
            return @"HPChatMsgOpenAllowCell";
        case MessageTypeOpenDenyResponse:
            return @"HPChatMsgOpenDenyCell";
    }
    return @"";
}

- (void)configureSendMessageOrOpenProfileButton {
    @weakify(self);
    RACSignal * showSendMessageButton = [[[RACSignal merge:@[self.msgTextView.rac_textSignal, RACObserve(self, msgTextView.text)]] map:^id(NSString *value) {
        return @(value.length == 0);
    }] not];

    RAC(self, sendMessageButton.hidden) = [showSendMessageButton not];
    RAC(self, sendOpenProfileButton.hidden) = [[[RACSignal combineLatest:@[[showSendMessageButton not], [self canOpenProfileSignal]]] and] not];

    [[self.sendMessageButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self sendMessageToCurrentContactWithText:self.msgTextView.text];
        self.msgTextView.text = @"";
    }];

    [[RACObserve(self, openingMode) map:^id(NSNumber *value) {
        if (value.boolValue) {
            return @"Отмена";
        }
        return @"Открыться";
    }] subscribeNext:^(NSString* title) {
        @strongify(self);
        [self.sendOpenProfileButton setTitle:title forState:UIControlStateNormal];
    }];

    [[self.msgTextView rac_textBeginEdit] subscribeNext:^(id x) {
        @strongify(self);
        self.openingMode = NO;
    }];
    [[self.sendOpenProfileButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.msgTextView resignFirstResponder];
        self.openingMode = !self.openingMode;
    }];

}

- (void)configureInputMode {
    @weakify(self);
    RACSignal *offsetSignal = [[[RACObserve(self, openingMode) combineLatestWith:[self keyboardHeightSignal]] throttle:0.01] map:^id(RACTuple * value) {
        RACTupleUnpack(NSNumber *height, NSNumber *duration, NSNumber *options) = value[1];
        if(((NSNumber *)value[0]).boolValue){
            height = @(216);
        }
        return RACTuplePack(height,duration,options);
    }];
    [offsetSignal
     subscribeNext:^(RACTuple *x) {
        @strongify(self);
        RACTupleUnpack(NSNumber *height, NSNumber *duration, NSNumber *options) = x;
        [self.view layoutIfNeeded];

        [UIView animateWithDuration:duration.doubleValue delay:0 options:(UIViewAnimationOptions) options.unsignedIntegerValue animations:^{
            @strongify(self);
            self.bottomInputViewOffset.constant = height.floatValue;

            [self.view layoutIfNeeded];
            [self scrollTableViewToBottom];
        }                completion:^(BOOL finished) {
        }];
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
        return @(offset < MIN_SCROLL_TOP_PIXEL_TO_LOAD);;
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
    self.avatar = [HPAvatarView avatarViewWithUser:self.contact.user];
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
        if (self.chatTableView.contentOffset.y < MIN_SCROLL_TOP_PIXEL_TO_LOAD)
            self.minimumViewedDate = [self getDateOffsetAfterDate:self.minimumViewedDate andNumberPerPage:NUMBER_PER_PAGE_LOAD];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HPChatMsgTableViewCell *cell = (HPChatMsgTableViewCell *) [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if([cell respondsToSelector:@selector(setTableViewController:)])
        cell.tableViewController = self;
    return cell;
}

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

- (RACSignal *) canOpenProfileSignal
{
    return [RACSignal return:@YES];
}

@end
