//
//  HPCurrentUserPointCollectionViewCell.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 05.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPCurrentUserPointCollectionViewCell.h"
#import "UIDevice+HighPoint.h"
#import "UIImage+HighPoint.h"
#import "User.h"
#import "UITextView+HPRacSignal.h"
#import "Avatar.h"
#import "UserPoint.h"
#import "HPCurrentUserViewController.h"
#import <Smartling.i18n/SLLocalization.h>

#define POINT_LENGTH 140
#define MIN_POINT_LENGTH 5
#define RED_LIGHT_POINT_COUNT 10


@interface HPCurrentUserPointCollectionViewCell ()


//Private properties
@property(weak, nonatomic) IBOutlet UILabel *yourPointLabel;
@property(weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property(weak, nonatomic) IBOutlet UILabel *pointInfoLabel;
@property(weak, nonatomic) IBOutlet UIButton *publishBtn;
@property(weak, nonatomic) IBOutlet UITextView *pointTextView;
@property(weak, nonatomic) IBOutlet UIButton *deleteBtn;
//point settings
@property(weak, nonatomic) IBOutlet UIView *pointSettingsView;
@property(weak, nonatomic) IBOutlet HPSlider *pointTimeSlider;
@property(weak, nonatomic) IBOutlet UILabel *pointTimeInfoLabel;
@property(weak, nonatomic) IBOutlet UIButton *publishSettBtn;
//point delete
@property(weak, nonatomic) IBOutlet UIView *deletePointView;
@property(weak, nonatomic) IBOutlet UILabel *deletePointInfoLabel;
@property(weak, nonatomic) IBOutlet UIButton *deletePointSettBtn;
@property(weak, nonatomic) IBOutlet UIButton *cancelDelBtn;

@property (nonatomic, strong) IBOutletCollection(NSLayoutConstraint ) NSArray *constraintFor4inch;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *keyboardOffsetConstraints;


@property(nonatomic, retain) RACSignal *topApplyButtonPressed;
@property(nonatomic, retain) RACSignal *keyboardApplyButtonPressed;
@property(nonatomic, retain) RACSignal *keyboardHeightSignal;
@end

@implementation HPCurrentUserPointCollectionViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
    [self remove4InchConstraint];

    self.deletePointInfoLabel.text = NSLocalizedString(@"DELETE_POINT_INFO", nil);
    [self.pointTimeSlider setValue:6 animated:YES];
    [self.pointTimeSlider initOnLoad];
    self.pointTimeInfoLabel.text = NSLocalizedString(@"SET_TIME_FOR_YOUR_POINT", nil);


    @weakify(self);
    [[self textViewIsEditing] subscribeNext:^(NSNumber *isEdit) {
        @strongify(self);
        if (isEdit.boolValue) {
            self.editUserPointMode = YES;
        }
    }];


    [self configureMainView];
    [self configureAvatarImageView];
    [self configurePointLabel];
    [self configurePointTextView];
    [self configurePointInfoLabel];
    [self configureNavigationBar];
    [self configurePointSettingsView];
    [self configurePublishButton];
    [self configureFinisPublishButton];
    [self configureDeletePointButton];
    [self configureDeletePointView];
    [self configureFinisDeleteButton];
    [self configureCancelDeleteButton];
}


#pragma mark - constraint

- (void) remove4InchConstraint{
    if(![UIDevice hp_isWideScreen]) {
        for (NSLayoutConstraint *constraint in self.constraintFor4inch) {
            constraint.priority = 1;
        }
    }
}

#pragma mark Configuring UIElements

- (void)configureMainView {
    @weakify(self);
    CGFloat startY = self.frame.origin.y;
    CGFloat startHeight = self.frame.size.height;

    [[RACSignal combineLatest:@[[RACObserve(self, editUserPointMode) distinctUntilChanged],[self keyboardHeightSignal]]] subscribeNext:^(RACTuple* tuple) {
        NSNumber *editMode = tuple[0];
        RACTuple* x = tuple[1];
        RACTupleUnpack(NSNumber *height, NSNumber *duration, NSNumber *options) = x;
        @strongify(self);
        if(height.floatValue > 0) {
            [UIView animateWithDuration:duration.floatValue == 0 ? 0.3 : duration.floatValue delay:0.0 options:(UIViewAnimationOptions) options.unsignedIntegerValue
                             animations:^{
                                 @strongify(self);
                                 self.frame = CGRectMake(self.frame.origin.x, startY - (height.floatValue - 115), self.frame.size.width, self.frame.size.height);
                                 self.keyboardOffsetConstraints.constant = height.floatValue - 115;
                             }
                             completion:^(BOOL finished) {
                             }];
        }
        else if(editMode.boolValue){
            [UIView animateWithDuration:duration.floatValue == 0 ? 0.3 : duration.floatValue delay:0.0 options:(UIViewAnimationOptions) options.unsignedIntegerValue
                             animations:^{
                                 @strongify(self);
                                 self.frame = CGRectMake(self.frame.origin.x, startY - 115, self.frame.size.width, startHeight + 115);
                                 self.keyboardOffsetConstraints.constant = 1;
                             }
                             completion:^(BOOL finished) {
                             }];
        }
        else{
            [UIView animateWithDuration:duration.floatValue == 0 ? 0.3 : duration.floatValue delay:0.0 options:(UIViewAnimationOptions) options.unsignedIntegerValue
                             animations:^{
                                 @strongify(self);
                                 self.frame = CGRectMake(self.frame.origin.x, startY, self.frame.size.width, startHeight);
                                 self.keyboardOffsetConstraints.constant = 1;
                             }
                             completion:^(BOOL finished) {
                             }];
        }
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

//Counter of symbols in textView
- (void)configurePointInfoLabel {
    @weakify(self);
    RACSignal *showCountNumber = [[RACSignal merge:@[RACObserve(self, editUserPointMode), [self textViewIsEditing]]] replayLast];

    RAC(self.pointInfoLabel, text) = [[RACSignal combineLatest:@[RACObserve(self, editUserPointMode), showCountNumber, RACObserve(self, currentUser.point)]]
            flattenMap:^RACStream *(RACTuple *x) {
                RACTupleUnpack(NSNumber *editMode, NSNumber *showCount, UserPoint* point) = x;
                @strongify(self);
                if(point){
                    int hourActive = self.pointTimeSlider.value;
                    NSString* stringFormat = SLPluralizedString(@"POINT_WILL_ACTIVE",hourActive, nil);
                    return [RACSignal return:[NSString stringWithFormat:stringFormat, hourActive]];

                }
                else {
                    if (showCount.boolValue || editMode.boolValue) {
                        return [[self.pointTextView rac_textSignal] map:^id(NSString *value) {
                            return @((NSInteger) (POINT_LENGTH - value.length)).stringValue;
                        }];
                    }
                    else {
                        return [RACSignal return:NSLocalizedString(@"NO_ACTIVE_POINT", nil)];
                    }
                }
            }];

    RAC(self.pointInfoLabel, textColor) = [showCountNumber flattenMap:^RACStream *(NSNumber *showCount) {
        @strongify(self);
        if (showCount.boolValue) {
            return [self.pointTextView.rac_textSignal map:^id(NSString *value) {
                @strongify(self);
                if (![self symbolsInPostIsWarningToPost]) {
                    return [UIColor colorWithRed:255.f / 255.f green:102.f / 255.f blue:112.f / 255.f alpha:1];
                }
                else {
                    return [UIColor colorWithRed:230.f / 255.f green:236.f / 255.f blue:242.f / 255.f alpha:1];
                }
            }];
        }
        else {
            return [RACSignal return:[UIColor colorWithRed:230.f / 255.f green:236.f / 255.f blue:242.f / 255.f alpha:1]];
        }
    }];

    [[[self applyTextPressedInPointTextView] filter:^BOOL(id value) {
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
                CGPointMake([self.pointInfoLabel center].x - 10.0f, [self.pointInfoLabel center].y)]];
        [animation setToValue:[NSValue valueWithCGPoint:
                CGPointMake([self.pointInfoLabel center].x + 10.0f, [self.pointInfoLabel center].y)]];
        [[self.pointInfoLabel layer] addAnimation:animation forKey:@"position"];

    }];
}

//Configure buttons of navigation bar
- (void)configureNavigationBar {
    @weakify(self);
    [[RACSignal combineLatest:@[[self textViewIsEditing], RACObserve(self, editUserPointMode), RACObserve(self, currentUser.point)]] subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        RACTupleUnpack(NSNumber *textViewEditing, NSNumber *editMode, UserPoint * point) = tuple;
        if (textViewEditing.boolValue) {
            self.delegate.navigationItem.leftBarButtonItem = [self barItemCancelEditText];
            self.delegate.navigationItem.rightBarButtonItem = [self barItemApplyEditText];
            return;
        }
        if (editMode.boolValue) {
            if(point!=nil) {
                self.delegate.navigationItem.leftBarButtonItem = [self barItemCancelEditText];
                self.delegate.navigationItem.rightBarButtonItem = [self barItemDeletePoint];
            }
            else{
                self.delegate.navigationItem.leftBarButtonItem = [self barItemCancelEditText];
                self.delegate.navigationItem.rightBarButtonItem = [self barItemFinishPublish];
            }
        }
        else {
            [self.delegate resetNavigationBarButtons];
        }
    }];
}

//Visibility of point settings
- (void)configurePointSettingsView {
    RAC(self.pointSettingsView, hidden) = [[RACSignal combineLatest:@[RACObserve(self, editUserPointMode),RACObserve(self, currentUser.point)]] map:^id(RACTuple * value) {
        RACTupleUnpack(NSNumber * editMode, UserPoint * point) = value;
        return @(!(editMode.boolValue&&(point==nil)));
    }];
}

//Configure placeholde
- (void)configurePointTextView {
    UIColor *placeHolderColor = [UIColor colorWithRed:230.f / 255.f green:236.f / 255.f blue:243.f / 255.f alpha:0.6];
    self.pointTextView.text = NSLocalizedString(@"YOUR_EMPTY_POINT", nil);
    self.pointTextView.textColor = placeHolderColor;
    @weakify(self);



    [[RACSignal combineLatest:@[[self textViewIsEditing], [RACObserve(self.pointTextView, text) distinctUntilChanged], RACObserve(self, currentUser.point)]] subscribeNext:^(RACTuple *x) {
        @strongify(self);
        RACTupleUnpack(NSNumber *isEdit, NSString *text,UserPoint * userPoint) = x;
        if (isEdit.boolValue) {
            if ([self.pointTextView.text isEqualToString:NSLocalizedString(@"YOUR_EMPTY_POINT", nil)]) {
                self.pointTextView.text = @"";
            }
            self.pointTextView.textColor = [UIColor whiteColor];
        }
        else {
            if(userPoint)
            {
                self.pointTextView.text = userPoint.pointText;
                self.pointTextView.textColor = [UIColor whiteColor];
            }
            else {
                if ([self.pointTextView.text isEqualToString:@""]) {
                    self.pointTextView.text = NSLocalizedString(@"YOUR_EMPTY_POINT", nil);
                    self.pointTextView.textColor = placeHolderColor;
                }
            }
        }
    }];

    [[RACObserve(self, currentUser.point) filter:^BOOL(id value) {
        return value==nil;
    }] subscribeNext:^(id x) {
        @strongify(self);
        self.pointTextView.text = @"";
    }];

    RAC(self.pointTextView,userInteractionEnabled) = [RACObserve(self, currentUser.point) map:^id(UserPoint *value) {
        return @(value == nil);
    }];

    self.pointTextView.delegate = self;
}

- (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound) {
        return YES;
    }

    self.keyboardApplyButtonPressed = [RACSignal return:@YES];
    if (txtView.text.length >= MIN_POINT_LENGTH && txtView.text.length <= POINT_LENGTH) {
        [txtView resignFirstResponder];
    }
    return NO;
}

- (void)configurePointLabel {
    self.yourPointLabel.text = NSLocalizedString(@"YOUR_POINT", nil);
    if (![UIDevice hp_isWideScreen]) {
        [self.yourPointLabel removeFromSuperview];
    }
}

- (void)configureAvatarImageView {
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 5;
    self.avatarImageView.image = [UIImage imageNamed:@"no_image.png"];
    @weakify(self);

    RAC(self.avatarImageView, image) = [[[RACObserve(self, delegate.avatarSignal).flatten  deliverOn:[RACScheduler scheduler]] map:^id(UIImage *avatarImage) {
        return [avatarImage addBlendToPhoto];
    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (void)configurePublishButton {
    RAC(self.publishBtn, hidden) = [[RACSignal combineLatest:@[RACObserve(self, editUserPointMode), RACObserve(self, currentUser.point)]] map:^id(RACTuple * value) {
        RACTupleUnpack(NSNumber* editMode, UserPoint * currentPoint) = value;
        return @(editMode.boolValue||(currentPoint != nil));
    }];

    @weakify(self);
    [[self.publishBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.pointTextView becomeFirstResponder];
    }];
}

- (void)configureFinisPublishButton {
    @weakify(self);
    [[self.publishSettBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self createUserPointWithCurrentData];
    }];
}

- (void)configureDeletePointButton {
    RAC(self.deleteBtn, hidden) = [[RACSignal combineLatest:@[RACObserve(self, editUserPointMode),RACObserve(self, currentUser.point)]] map:^id(RACTuple * value) {
        RACTupleUnpack(NSNumber * editMode, UserPoint * point) = value;
        return @(!(!editMode.boolValue&&(point!=nil)));
    }];
    @weakify(self);
    [[self.deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        self.editUserPointMode = YES;
    }];
}

- (void)configureDeletePointView {
    RAC(self.deletePointView, hidden) = [[RACSignal combineLatest:@[RACObserve(self, editUserPointMode),RACObserve(self, currentUser.point)]] map:^id(RACTuple * value) {
        RACTupleUnpack(NSNumber * editMode, UserPoint * point) = value;
        return @(!(editMode.boolValue&&(point!=nil)));
    }];
}

- (void)configureCancelDeleteButton {
    @weakify(self);
    [[self.cancelDelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        self.editUserPointMode = NO;
    }];
}

- (void)configureFinisDeleteButton {
    @weakify(self);
    [[self.deletePointSettBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self deleteCurrentUserPoint];
    }];
}

#pragma mark Actions

- (void)createUserPointWithCurrentData {
    if ([self.delegate respondsToSelector:@selector(createPointWithPointText:andTime:forUser:)]) {
        [self.delegate createPointWithPointText:self.pointTextView.text andTime:@(self.pointTimeSlider.value) forUser:self.currentUser];
    }
    self.editUserPointMode = NO;
    self.pointTextView.text = @"";
}


- (void)deleteCurrentUserPoint
{
    if ([self.delegate respondsToSelector:@selector(deleteCurrentUserPointForUser:)]) {
        [self.delegate deleteCurrentUserPointForUser:self.currentUser];
    }
    self.editUserPointMode = NO;
}
#pragma mark Signals

- (RACSignal *)textViewIsEditing {
    return [[[RACSignal merge:@[
            [[self.pointTextView rac_textBeginEdit] map:^id(id value) {
                return @YES;
            }],
            [[self.pointTextView rac_textEndEdit] map:^id(id value) {
                return @NO;
            }]
    ]] takeUntil:[self rac_willDeallocSignal]] replayLast];
}

- (BOOL)symbolsInPostIsWarningToPost {
    if ([self.pointTextView.text isEqualToString:NSLocalizedString(@"YOUR_EMPTY_POINT", nil)]) {
        return NO;
    }
    if (self.pointTextView.text.length < MIN_POINT_LENGTH)
        return NO;
    return ((NSInteger) ((POINT_LENGTH - RED_LIGHT_POINT_COUNT) - self.pointTextView.text.length) >= 0);

}

- (BOOL)symbolsInPostIsAvailableToPost {
    if ([self.pointTextView.text isEqualToString:NSLocalizedString(@"YOUR_EMPTY_POINT", nil)]) {
        return NO;
    }
    if (self.pointTextView.text.length < MIN_POINT_LENGTH)
        return NO;
    return ((NSInteger) (POINT_LENGTH - self.pointTextView.text.length) >= 0);
}

- (RACSignal *)applyTextPressedInPointTextView {
    return [RACSignal merge:@[[RACObserve(self, topApplyButtonPressed) flatten], [RACObserve(self, keyboardApplyButtonPressed) flatten]]];
}


#pragma mark UIElements

- (UIBarButtonItem *)barItemCancelEditText {
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] init];
    leftBarItem.title = @"Отмена";
    [leftBarItem setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"FuturaPT-Light" size:18]} forState:UIControlStateNormal];
    @weakify(self);
    leftBarItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        self.editUserPointMode = NO;
        [self.pointTextView resignFirstResponder];
        return [RACSignal empty];
    }];
    return leftBarItem;
}

- (UIBarButtonItem *)barItemApplyEditText {
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] init];
    rightBarItem.title = @"Готово";
    @weakify(self);
    [rightBarItem setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"FuturaPT-Book" size:18]} forState:UIControlStateNormal];
    [rightBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:80.f / 255.f green:227.f / 255.f blue:194.f / 255.f alpha:0.4]} forState:UIControlStateDisabled];

    RACSignal *enableSignal = [self.pointTextView.rac_textSignal map:^id(id value) {
        @strongify(self)
        return @([self symbolsInPostIsAvailableToPost]);
    }];

    rightBarItem.rac_command = [[RACCommand alloc] initWithEnabled:enableSignal signalBlock:^RACSignal *(id input) {
        @strongify(self)
        self.topApplyButtonPressed = [RACSignal return:@YES];
        [self.pointTextView resignFirstResponder];
        return [RACSignal empty];
    }];
    return rightBarItem;
}

- (UIBarButtonItem *)barItemFinishPublish {
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

- (UIBarButtonItem *)barItemDeletePoint {
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] init];
    rightBarItem.title = @"Удалить";
    @weakify(self);
    [rightBarItem setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"FuturaPT-Book" size:18]} forState:UIControlStateNormal];
    [rightBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:80.f / 255.f green:227.f / 255.f blue:194.f / 255.f alpha:0.4]} forState:UIControlStateDisabled];
    rightBarItem.rac_command = [[RACCommand alloc] initWithEnabled:[RACSignal return:@YES] signalBlock:^RACSignal *(id input) {
        @strongify(self)
        [self deleteCurrentUserPoint];
        return [RACSignal empty];
    }];
    return rightBarItem;
}

#pragma mark - animation

- (void)animateMainViewToTop {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         weakSelf.frame = CGRectMake(weakSelf.frame.origin.x, weakSelf.frame.origin.y - 115, weakSelf.frame.size.width, weakSelf.frame.size.height + 115);
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)animateMainViewToBottom {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         weakSelf.frame = CGRectMake(weakSelf.frame.origin.x, weakSelf.frame.origin.y + 115, weakSelf.frame.size.width, weakSelf.frame.size.height - 115);
                     }
                     completion:^(BOOL finished) {
                     }];

}
@end
