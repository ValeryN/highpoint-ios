//
//  HPChatListViewController.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 08.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPChatListViewController.h"
#import "UITextField+HighPoint.h"
#import "HPChatViewController.h"
#import "DataStorage.h"
#import "UIViewController+HighPoint.h"


@interface HPChatListViewController ()
@property(nonatomic, retain) NSFetchedResultsController *contactsController;
@property(nonatomic, weak) IBOutlet UITableView *tableView;
@property(nonatomic) BOOL searchMode;
@property(strong, nonatomic) UITextField *searchTextField;
@property(strong, nonatomic) UIView *coverView;
@end

@implementation HPChatListViewController {

}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableView:self.tableView withSignal:RACObserve(self, contactsController) andTemplateCell:[UINib nibWithNibName:@"HPChatTableViewCell" bundle:nil]];
    @weakify(self);
    [self.selectRowSignal subscribeNext:^(Contact *contact) {
        @strongify(self);
        HPChatViewController *chatController = [[HPChatViewController alloc] initWithNibName:@"HPChatViewController" bundle:nil];
        chatController.contact = contact;
        [self.navigationController pushViewController:chatController animated:YES];
    }];
    RAC(self,tableView.scrollEnabled) = [RACObserve(self, searchMode) not];
    [self configureSearchBar];
    [self configureNavigationBar];

}

- (void)configureSearchBar {
    @weakify(self);
    self.searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 25, 270, 30)];
    [self.searchTextField hp_tuneForSearchTextFieldInContactList:NSLocalizedString(@"SEARCH_FIELD_PLACEHOLDER", nil)];
    RAC(self, contactsController) = [self.searchTextField.rac_textSignal map:^id(NSString *value) {
        if ([value isEqualToString:@""]) {
            return [[DataStorage sharedDataStorage] getAllContactsFetchResultsController];
        }
        else {
            return [[DataStorage sharedDataStorage] getContactsByQueryFetchResultsController:value];
        }
    }];
    [RACObserve(self, searchMode) subscribeNext:^(NSNumber * x) {
        @strongify(self);
        if(x.boolValue){
            [self showCoverView];
            [self.searchTextField becomeFirstResponder];
        }
        else{
            [self hideCoverView];
            [self.searchTextField resignFirstResponder];
        }
    }];
}

- (void)configureNavigationBar {
    @weakify(self);
    UIBarButtonItem *searchButton = [self createBarButtonItemWithImage:[UIImage imageNamed:@"Lens.png"]
                                                       highlighedImage:[UIImage imageNamed:@"Lens Tap.png"]
                                                                action:nil];
    searchButton.rac_command = [[RACCommand alloc] initWithEnabled:[RACSignal return:@(YES)] signalBlock:^RACSignal *(id input) {
        @strongify(self);
        self.searchMode = YES;
        return [RACSignal empty];
    }];

    UIBarButtonItem *closeButton = [self createBarButtonItemWithImage:[UIImage imageNamed:@"Close.png"] highlighedImage:[UIImage imageNamed:@"Close Tap.png"] action:nil];
    closeButton.rac_command = [[RACCommand alloc] initWithEnabled:[RACSignal return:@(YES)] signalBlock:^RACSignal *(id input) {
        @strongify(self);
        self.searchMode = NO;
        return [RACSignal empty];
    }];

    RAC(self,navigationItem.rightBarButtonItem) = [RACObserve(self, searchMode) map:^id(NSNumber * value) {
        if(value.boolValue){
            return closeButton;
        }
        else{
            return searchButton;
        }
    }];


    UIBarButtonItem *backButton = [self createBarButtonItemWithImage:[UIImage imageNamed:@"Close.png"]
                                                     highlighedImage:[UIImage imageNamed:@"Close Tap.png"]
                                                              action:nil];
    backButton.rac_command = [[RACCommand alloc] initWithEnabled:[RACSignal return:@(YES)] signalBlock:^RACSignal *(id input) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
        return [RACSignal empty];
    }];

    RAC(self,navigationItem.leftBarButtonItem) = [RACObserve(self, searchMode) map:^id(NSNumber * value) {
        @strongify(self);
        if(value.boolValue){
            return [[UIBarButtonItem alloc] initWithCustomView:self.searchTextField];
        }
        else{
            return backButton;
        }
    }];


    RAC(self, navigationItem.title) = [RACObserve(self, searchMode) map:^id(NSNumber *value) {
        if (value.boolValue)
            return @"";
        else
            return NSLocalizedString(@"CHAT_LIST_TITLE", nil);
    }];
}

- (NSFetchedResultsController *)contactsController {
    if (!_contactsController) {
        _contactsController = [[DataStorage sharedDataStorage] getAllContactsFetchResultsController];
    }
    return _contactsController;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HPChatTableViewCell* cell = (HPChatTableViewCell *) [super tableView:tableView cellForRowAtIndexPath:indexPath];
    //Fix tableView select with scroll
    @weakify(self);
    [[[cell.tap_Gesture.rac_gestureSignal takeUntil:cell.rac_prepareForReuseSignal] takeUntil:[self rac_willDeallocSignal]] subscribeNext:^(id x) {
        @strongify(self);
        [self tableView:tableView didSelectRowAtIndexPath:indexPath];
    }];
    return cell;
}

#pragma mark - cover view

- (void)showCoverView {
    if (!self.coverView) {
        self.coverView = [[UIView alloc] initWithFrame:self.view.frame];
        self.coverView.userInteractionEnabled = YES;
        self.coverView.backgroundColor = [UIColor colorWithRed:30.0f / 255.0f
                                                         green:29.0f / 255.0f
                                                          blue:48.0f / 255.0f
                                                         alpha:1.0];
        self.coverView.alpha = 0.5;
        UITapGestureRecognizer *singleTap = [UITapGestureRecognizer new];
        @weakify(self);
        [singleTap.rac_gestureSignal subscribeNext:^(id x) {
            @strongify(self);
            self.searchMode = NO;
        }];
        [self.coverView addGestureRecognizer:singleTap];
    }
    [self.tableView.superview addSubview:self.coverView];
}

- (void)hideCoverView {
    [self.coverView removeFromSuperview];
}


@end
