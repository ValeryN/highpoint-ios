//
//  HPCurrentUserViewController.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 10.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPCurrentUserViewController.h"
#import "DataStorage.h"
#import "UIDevice+HighPoint.h"
#import "HPPointLikesViewController.h"
#import "Utils.h"
#import "HPSettingsViewController.h"
#import "HPAvatarView.h"
#import "UINavigationBar+HighPoint.h"
#import "HPRequest.h"
#import "HPRequest+Points.h"
#import "User+UserImage.h"
#import "HPCurrentUserPrivacyViewController.h"
#import "UIViewController+HighPoint.h"
#import "UITextView+HPRacSignal.h"
#import "UITextView+HightPoint.h"
#import <Smartling.i18n/SLLocalization.h>

#define POINT_LENGTH 140
#define MIN_POINT_LENGTH 5
#define RED_LIGHT_POINT_COUNT 10

@interface HPCurrentUserViewController ()

@property(nonatomic, retain) User *currentUser;
@property(nonatomic) RACSignal* currentUserSignal;

@property (nonatomic,weak) IBOutlet HPAvatarView* avatarView;
@property (nonatomic,weak) IBOutlet UIScrollView* mainScroll;
@property (nonatomic,weak) IBOutlet UIView* contentView;
@property (nonatomic,weak) IBOutlet UILabel* nameLabel;
@property (nonatomic,weak) IBOutlet UILabel* userInfoLabel;
@property (nonatomic,weak) IBOutlet UITextView* pointTextField;
@property (nonatomic, weak) IBOutlet UILabel* placeholderLabel;
@property (nonatomic,weak) IBOutlet UILabel* pointStatus;
@property (nonatomic,weak) IBOutlet UILabel* pointCountLabel;
@property (nonatomic,weak) IBOutlet UILabel* pointWillActiveTimeLabel;
@property (nonatomic, weak) IBOutlet UIButton* openPrivacyButton;
@property (nonatomic, weak) IBOutlet UIButton* openPhotoAlbumButton;
@property (nonatomic, weak) IBOutlet UIButton* openConciergeButton;

@property (nonatomic, weak) IBOutlet UIView* viewForNoPoint;
@property (nonatomic, weak) IBOutlet UIView* viewForPoint;
@property (nonatomic, weak) IBOutlet UIView* viewForCreatePoint;
@property (nonatomic, weak) IBOutlet UIView* buttonsView;
@property (nonatomic, weak) IBOutlet UIView* selectTimeView;
@property(weak, nonatomic) IBOutlet HPSlider *pointTimeSlider;

@property (nonatomic,weak) IBOutlet UIView* likesView;
@property (nonatomic,weak) IBOutlet UIView* likesSubView;
@property (nonatomic,weak) IBOutlet UILabel* likesLabel;

@property (nonatomic) BOOL pointMode;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint * totalContentViewHeightConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint * textViewHeightConstraint;

@property (nonatomic, retain) RACSignal* moveUpAvatarSignal;
@property (nonatomic, retain) RACSignal* keyboardIsOpen;
@property (nonatomic, retain) RACSubject* applyPointTextPress;
@property (nonatomic, retain) RACSignal* pointSignal;
@property (nonatomic, retain) RACSignal* pointTimeLeftSignal;
@property (nonatomic, retain) RACSignal* usersLikeYourPost;
@end

@implementation HPCurrentUserViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.currentUser = [[DataStorage sharedDataStorage] getCurrentUser];
    self.automaticallyAdjustsScrollViewInsets = YES;
    [self configureBlurView];
    [self configureUserInfo];
    [self configureButtons];
    [self configureSelectTimeView];
    [self configureTextView];
    [self configureOffsetInEditMode];
    [self configurePointInfoView];
    [self configureLeftBarButton];
    [self configureRightBarButton];
    [self configureLikesView];
}

#pragma mark Configures
- (void) configureBlurView{
    self.view.backgroundColor = [UIColor clearColor];
    UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:self.view.frame];
    toolbar.barStyle = UIBarStyleBlack;
    toolbar.translucent = YES;
    [self.view insertSubview:toolbar atIndex:0];
}

- (void) configureButtons{
    @weakify(self);
    RAC(self,buttonsView.hidden) = RACObserve(self, pointMode);
    [[self.openPrivacyButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        HPCurrentUserPrivacyViewController* privacyVc = [[HPCurrentUserPrivacyViewController alloc] initWithNibName:@"HPCurrentUserPrivacyViewController" bundle:nil];
        privacyVc.currentUser = self.currentUser;
        [self.navigationController pushViewController:privacyVc animated:YES];
    }];
    
    [[self.openPhotoAlbumButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        HPUserProfileViewController* profile = [[HPUserProfileViewController alloc] initWithNibName:@"HPUserProfile" bundle:nil];
        profile.user = self.currentUser;
        [self.navigationController pushViewController:profile animated:YES];
    }];
    
    [[self.openConciergeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [[[UIAlertView alloc] initWithTitle:@"Not implemented" message:@"No design" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
    }];
}

- (void) configureTextView{
    @weakify(self);
    RACSignal* havePointSignal = [[self pointSignal] map:^id(UserPoint* value) {
        if(value)
            return @(YES);
        else
            return @(NO);
    }];
    
    [self.pointTextField.rac_textBeginEdit subscribeNext:^(id x) {
        @strongify(self);
        self.pointMode = YES;
    }];
    
    RAC(self, pointTextField.userInteractionEnabled) = [havePointSignal not];
    RAC(self, placeholderLabel.hidden) = RACObserve(self, pointMode);
    RAC(self, placeholderLabel.text) = [[self pointSignal] map:^id(UserPoint* value) {
        if(!value){
            return NSLocalizedString(@"YOUR_EMPTY_POINT", nil);
        }
        else{
            return value.pointText;
        }
    }];
    
    [[self moveUpAvatarSignal] subscribeNext:^(NSNumber* x) {
        @strongify(self);
        if(x.boolValue){
            [self.pointTextField addConstraint:self.textViewHeightConstraint];
        }
        else{
            [self.pointTextField removeConstraint:self.textViewHeightConstraint];
        }
    }];    
}

- (void) configureSelectTimeView{
    [self.pointTimeSlider setValue:6 animated:YES];
    [self.pointTimeSlider initOnLoad];
    RAC(self,selectTimeView.hidden) = [[[RACSignal combineLatest:@[RACObserve(self, pointMode),[[self keyboardIsOpen] not]]] and] not];
}

- (void) configureUserInfo{
    RAC(self.nameLabel,text) = [[self currentUserSignal] map:^id(User* value) {
        return value.name;
    }];
    
    RAC(self.userInfoLabel,text) = [[self currentUserSignal] map:^id(User* value) {
        NSString *cityName = value.city.cityName ? value.city.cityName : NSLocalizedString(@"UNKNOWN_CITY_ID", nil);
        return [NSString stringWithFormat:@"%@ лет, %@", value.age,cityName];
    }];
    
    RAC(self.avatarView, user) = [self currentUserSignal];
}

- (void) configureLeftBarButton{
    @weakify(self);
    RAC(self,navigationItem.leftBarButtonItem) = [RACObserve(self, pointMode) map:^id(NSNumber* value) {
        @strongify(self);
        if(value.boolValue){
            return [self closePointEditBarButton];
        }
        else{
            return [self closeCurrentUserViewControolerBarButton];
        }
    }];
}

- (void) configureOffsetInEditMode{
    @weakify(self);
    [[self moveUpAvatarSignal] subscribeNext:^(NSNumber* x) {
        @strongify(self);
        if(!x.boolValue){
            [self.contentView removeConstraint:self.totalContentViewHeightConstraint];
            [self.mainScroll layoutIfNeeded];
            [self.mainScroll setContentOffset:(CGPoint){0,0} animated:YES];
        }
        else{
            self.totalContentViewHeightConstraint.constant = self.view.frame.size.height+120;
            [self.contentView addConstraint:self.totalContentViewHeightConstraint];
            self.mainScroll.bounces = NO;
            [self.mainScroll layoutIfNeeded];
            [UIView animateWithDuration:0.25 animations:^{
                 @strongify(self);
                 [self.mainScroll setContentOffset:(CGPoint){0,120}];
                 [self.mainScroll layoutIfNeeded];
            }];
        }
    }];
    RAC(self, mainScroll.bounces) = [[self moveUpAvatarSignal] not];
    RAC(self, mainScroll.scrollEnabled) = [[self moveUpAvatarSignal] not];
}

- (RACSignal*) currentUserSignal{
    if(!_currentUserSignal){
        _currentUserSignal = [[RACObserve(self, currentUser) distinctUntilChanged] replayLast];
    }
    return _currentUserSignal;
}

- (void) configurePointInfoView{
    @weakify(self);
    RACSignal* havePointSignal = [[self pointSignal] map:^id(UserPoint* value) {
        if(value)
            return @(YES);
        else
            return @(NO);
    }];
    
    RAC(self,viewForNoPoint.hidden) = [[[RACSignal combineLatest:@[[[self moveUpAvatarSignal] not],[havePointSignal not]]] and] not];
    RAC(self,viewForPoint.hidden) = [[[RACSignal combineLatest:@[[[self moveUpAvatarSignal] not],havePointSignal]] and] not];
    RAC(self,viewForCreatePoint.hidden) = [[self moveUpAvatarSignal] not];
    
    RAC(self,pointCountLabel.text) = [self.pointTextField.rac_textSignal map:^id(NSString* value) {
        return [NSString stringWithFormat:@"Осталось символов: %d",POINT_LENGTH - value.length];
    }];
    
    RAC(self,pointCountLabel.textColor) = [self.pointTextField.rac_textSignal map:^id(NSString* value) {
        @strongify(self);
        if([self symbolsInPostIsWarningToPost]){
            return [UIColor colorWithRed:230.f/255.f green:236.f/255.f blue:242.f/255.f alpha:1];
        }
        else{
            return [UIColor colorWithRed:255.f / 255.f green:102.f / 255.f blue:112.f / 255.f alpha:1];
        }
    }];
    
    RAC(self,pointWillActiveTimeLabel.text) = [[self pointTimeLeftSignal] map:^id(NSNumber* value) {
        int hourActive = ceilf(value.floatValue/60.f/60.f);
        NSString* stringFormat = SLPluralizedString(@"POINT_WILL_ACTIVE",hourActive, nil);
        return [RACSignal return:[NSString stringWithFormat:stringFormat, hourActive]];
    }];
    
    [[[self applyPointTextPress] filter:^BOOL(id value) {
        @strongify(self);
        return ![self symbolsInPostIsAvailableToPost];
    }] subscribeNext:^(id x) {
        @strongify(self);
        CABasicAnimation *animation =
        [CABasicAnimation animationWithKeyPath:@"position"];
        [animation setDuration:0.05];
        [animation setRepeatCount:4];
        [animation setAutoreverses:YES];
        [animation setFromValue:[NSValue valueWithCGPoint:
                                 CGPointMake([self.pointCountLabel center].x - 10.0f, [self.pointCountLabel center].y)]];
        [animation setToValue:[NSValue valueWithCGPoint:
                               CGPointMake([self.pointCountLabel center].x + 10.0f, [self.pointCountLabel center].y)]];
        [[self.pointCountLabel layer] addAnimation:animation forKey:@"position"];
    }];
}

- (void) configureRightBarButton{
    @weakify(self);
    RAC(self, navigationItem.rightBarButtonItem) = [[RACSignal combineLatest:@[[self moveUpAvatarSignal],[self keyboardIsOpen]]] map:^id(RACTuple* value) {
        @strongify(self);
        if(!((NSNumber*)value.first).boolValue){
            return [self preferencesBarButton];
        }
        else if(((NSNumber*)value.second).boolValue){
            return [self closeKeyboardBarButton];
        }
        else{
            return [self publishPointBarButton];
        }
    }];
}

- (void) configureLikesView{
    @weakify(self);
    
    RACSignal *yourHavePoint = [RACObserve(self.currentUser, point) map:^id(id value) {
        return @(value!=nil);
    }];
    //По умолчанию никто не любит твой пост, как мило =)
    RACSignal *nobodyLikeYourPost = [[RACSignal return:@YES] concat:[self.usersLikeYourPost map:^id(NSArray *value) {
        return @(value.count == 0);
    }]];
    
    RAC(self, likesLabel.text) = [nobodyLikeYourPost map:^id(NSNumber* value) {
        if(value.boolValue){
            return @"Никто пока не оценил ваш пост";
        }
        else{
            return @"Оценили ваш поинт";
        }
    }];
    
    RACSignal* havePointSignal = [[self pointSignal] map:^id(UserPoint* value) {
        if(value)
            return @(YES);
        else
            return @(NO);
    }];
    RAC(self,likesView.hidden) = [havePointSignal not];
    
    [self.usersLikeYourPost subscribeNext:^(RACTuple *usersTuple) {
        @strongify(self);
        for (UIView *view in [self.likesSubView subviews])
            [view removeFromSuperview];
        if (usersTuple.count > 0) {
            NSArray *arraySlice = [usersTuple.allObjects subarrayWithRange:NSMakeRange(0, usersTuple.count > 3 ? 3 : usersTuple.count)];
            
            @strongify(self);
            NSMutableDictionary *constraintViewDictionary = @{}.mutableCopy;
            for (User *user in arraySlice) {
                HPAvatarView *avatarView = [HPAvatarView avatarViewWithUser:user];
                avatarView.frame = (CGRect) {0, 0, 33, 33};
                avatarView.translatesAutoresizingMaskIntoConstraints = NO;
                constraintViewDictionary[[NSString stringWithFormat:@"avatarView_%d", rand() % 100000]] = avatarView;
                [self.likesSubView addSubview:avatarView];
            }
            if (constraintViewDictionary.count) {
                NSMutableString *horizontalConstraintFormat = @"H:".mutableCopy;
                
                for (NSString *key in constraintViewDictionary) {
                    [self.likesSubView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[%@(32)]", key]
                                                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                                                 metrics:nil
                                                                                                   views:constraintViewDictionary]];
                    [horizontalConstraintFormat appendFormat:@"[%@(32)]-(4)-", key];
                    
                    
                }
                [horizontalConstraintFormat appendString:@"|"];
                [self.likesSubView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horizontalConstraintFormat
                                                                                             options:0
                                                                                             metrics:nil
                                                                                               views:constraintViewDictionary]];
            }
            
        }
        
        
    }];
}

#pragma mark Elements

- (UIBarButtonItem*) closeCurrentUserViewControolerBarButton{
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] init];
    if ([UIDevice hp_isIOS6]) {
        leftBarItem.image = [UIImage imageNamed:@"Close"];
    }
    else {
        leftBarItem.image = [[UIImage imageNamed:@"Close"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    @weakify(self);
    leftBarItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        self.navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [UIView animateWithDuration:0.3 animations:^{
            @strongify(self);
            self.navigationController.view.alpha = 0;
        } completion:^(BOOL finished) {
            @strongify(self);
            [self.navigationController dismissViewControllerAnimated:NO completion:nil];
        }];
        return [RACSignal empty];
    }];
    return leftBarItem;
}


- (UIBarButtonItem*) closePointEditBarButton{
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] init];
    if ([UIDevice hp_isIOS6]) {
        leftBarItem.image = [UIImage imageNamed:@"Close"];
    }
    else {
        leftBarItem.image = [[UIImage imageNamed:@"Close"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    @weakify(self);
    leftBarItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        self.pointTextField.text = @"";
        [self.pointTextField resignFirstResponder];
        self.pointMode = NO;
        return [RACSignal empty];
    }];
    return leftBarItem;
}

- (UIBarButtonItem*) preferencesBarButton{
    return nil;
}

- (UIBarButtonItem*) closeKeyboardBarButton{

    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] init];
    rightBarItem.title = @"Готово";
    @weakify(self);
    [rightBarItem setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"FuturaPT-Book" size:18]} forState:UIControlStateNormal];
    [rightBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:80.f / 255.f green:227.f / 255.f blue:194.f / 255.f alpha:0.4]} forState:UIControlStateDisabled];
    
    RACSignal *enableSignal = [self.pointTextField.rac_textSignal map:^id(id value) {
        @strongify(self)
        return @([self symbolsInPostIsAvailableToPost]);
    }];
    
    rightBarItem.rac_command = [[RACCommand alloc] initWithEnabled:enableSignal signalBlock:^RACSignal *(id input) {
        @strongify(self);
        [self.applyPointTextPress sendNext:@(YES)];
        [self.pointTextField resignFirstResponder];
        return [RACSignal empty];
    }];
    return rightBarItem;
}
                                
- (UIBarButtonItem*) publishPointBarButton{
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] init];
    rightBarItem.title = @"Опубликовать";
    @weakify(self);
    [rightBarItem setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"FuturaPT-Book" size:18]} forState:UIControlStateNormal];
    [rightBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:80.f / 255.f green:227.f / 255.f blue:194.f / 255.f alpha:0.4]} forState:UIControlStateDisabled];
    rightBarItem.rac_command = [[RACCommand alloc] initWithEnabled:[RACSignal return:@([self symbolsInPostIsAvailableToPost])] signalBlock:^RACSignal *(id input) {
        @strongify(self)
        [self createUserPointWithCurrentData];
        return [RACSignal empty];
    }];
    return rightBarItem;
}

#pragma mark Validators                                
- (BOOL) symbolsInPostIsAvailableToPost{
    return ((NSInteger)(POINT_LENGTH - self.pointTextField.text.length) >= 0 && self.pointTextField.text.length > MIN_POINT_LENGTH);
}
- (BOOL) symbolsInPostIsWarningToPost{
    return ((NSInteger)(POINT_LENGTH - self.pointTextField.text.length) >= RED_LIGHT_POINT_COUNT && self.pointTextField.text.length > MIN_POINT_LENGTH);
}
#pragma mark Signals
- (RACSignal *)pointSignal{
    if(!_pointSignal){
        RACSignal* pointSignal = [RACObserve(self, currentUser.point) replayLast];
        RACSignal* dateSignal = [[RACSignal return:@(YES)] takeUntilReplacement:[RACSignal interval:5.f onScheduler:[RACScheduler schedulerWithPriority:RACSchedulerPriorityDefault]]];
        _pointSignal = [[[RACSignal combineLatest:@[pointSignal,dateSignal]] map:^id(RACTuple* value) {
            UserPoint* point = value.first;
            if(!point || (point.pointValidTo.timeIntervalSince1970 - [[NSDate date] timeIntervalSince1970]) < 0)
                return nil;
            else{
                return point;
            }
            
        }] replayLast];
    }
    return _pointSignal;
}

- (RACSignal *)pointTimeLeftSignal{
    if(_pointTimeLeftSignal){
        _pointTimeLeftSignal = [[self pointSignal] map:^id(UserPoint* value) {
            if(value){
                return @(value.pointValidTo.timeIntervalSince1970 - [[NSDate date] timeIntervalSince1970]);
            }
            return @(-1);
        }];
    }
    return _pointTimeLeftSignal;
}

- (RACSignal*) applyPointTextPress
{
    if(!_applyPointTextPress){
        _applyPointTextPress = [RACSubject subject];
    }
    return _applyPointTextPress;
}

- (RACSignal*) moveUpAvatarSignal {
    if(!_moveUpAvatarSignal){
        _moveUpAvatarSignal = [[[RACSignal combineLatest:@[RACObserve(self, pointMode),[self keyboardIsOpen]]] or] replayLast];
    }
    return _moveUpAvatarSignal;
}

- (RACSignal*) keyboardIsOpen{
    if(!_keyboardIsOpen){
        _keyboardIsOpen = [[self.pointTextField rac_isEditing] replayLast];
    }
    return _keyboardIsOpen;
}

- (RACSignal *)usersLikeYourPost {
    if(!_usersLikeYourPost) {
        @weakify(self);
        RACSignal * getLikesFromServer  = [[[HPRequest getLikedUserOfPoint:self.currentUser.point] deliverOn:[RACScheduler scheduler]] flattenMap:^RACStream *(id value) {
            if (value)
                return [RACSignal return:value];
            else
                return [RACSignal empty];
        }];
        
        _usersLikeYourPost = [[[[[[[[RACObserve(self, currentUser.point.pointId) deliverOn:[RACScheduler scheduler]] filter:^BOOL(id value) {
            return (value != nil);
        }] take:1] map:^id(id value) {
            @strongify(self);
            return self.currentUser.point.likedBy;
        }] concat:getLikesFromServer] deliverOn:[RACScheduler mainThreadScheduler]] replayLast] catchTo:[RACSignal empty]];
    }
    return _usersLikeYourPost;
}

#pragma mark Actions

- (void)createUserPointWithCurrentData {
    @weakify(self);
    int hourActive = self.pointTimeSlider.value;
    
    [[HPRequest createPointWithText: self.pointTextField.text dueDate:[NSDate dateWithTimeIntervalSinceNow:hourActive*60*60] forUser:self.currentUser] subscribeNext:^(id x) {
        @strongify(self);
        self.pointMode = NO;
        self.pointTextField.text = @"";
    }];
    
}

- (void)deleteCurrentUserPoint
{
    [[HPRequest deletePoint:self.currentUser.point] subscribeNext:^(id x) {
        
    }];
}

#pragma mark IBAction
- (IBAction) startCreatePointPressed:(id)sender{
    [self.pointTextField becomeFirstResponder];
}

- (IBAction) publicButtonPressed:(id)sender{
    [self createUserPointWithCurrentData];
}

- (IBAction) deletePointPressed:(id)sender{
    [self deleteCurrentUserPoint];
}



#pragma mark Delegates
- (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound) {
        return YES;
    }
    
    [[self applyPointTextPress] sendNext:@YES];
    if ([self symbolsInPostIsAvailableToPost]) {
        [txtView resignFirstResponder];
    }
    return NO;
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    if(self.view.window == nil){
        self.view = nil;
    }
}

@end