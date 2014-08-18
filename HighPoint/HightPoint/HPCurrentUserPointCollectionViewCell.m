//
//  HPCurrentUserPointCollectionViewCell.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 05.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPCurrentUserPointCollectionViewCell.h"
#import "UILabel+HighPoint.h"
#import "UIButton+HighPoint.h"
#import "UITextView+HightPoint.h"
#import "UIDevice+HighPoint.h"
#import "UIImage+HighPoint.h"
#import "User.h"

#define POINT_LENGTH 150
#define RED_LIGHT_POINT_COUNT 10
#define CONSTRAINT_AVATAR_TOP 10.0
#define CONSTRAINT_POINT_TOP 180.0
#define CONSTRAINT_POINT_INFO_TOP 274.0
#define CONSTRAINT_BTNS_BOTTOM_TOP 318.0
#define CONSTRAINT_VIEW_BOTTOM_TOP 318.0

@interface HPCurrentUserPointCollectionViewCell ()
//Private methods
- (void)editPointUp;

- (void)editPointDown;


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

@end

@implementation HPCurrentUserPointCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    [self fixUserPointConstraint];
    [self.pointSettingsView setHidden:YES];
    [self setImageViewBgTap];
    self.yourPointLabel.text = NSLocalizedString(@"YOUR_POINT", nil);
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 5;
    self.avatarImageView.image = [self.avatarImageView.image addBlendToPhoto];
    self.deletePointInfoLabel.text = NSLocalizedString(@"DELETE_POINT_INFO", nil);
    [self.pointTimeSlider setValue:6 animated:YES];
    [self.pointTimeSlider initOnLoad];
    self.pointTimeInfoLabel.text = NSLocalizedString(@"SET_TIME_FOR_YOUR_POINT", nil);


    RACSignal *keyboardIsShown = [[[RACSignal merge:@[
            [RACSignal return:@NO],
            [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] map:^id(id value) {
                return @YES;
            }],
            [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] map:^id(id value) {
                return @NO;
            }]
    ]] takeUntil:[self rac_willDeallocSignal]] replayLast];

    @weakify(self);

    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(NSNumber *isShown) {
        @strongify(self);
        self.editUserPointMode = YES;
    }];

    [[RACObserve(self, editUserPointMode) distinctUntilChanged] subscribeNext:^(NSNumber *editMode) {
        @strongify(self);
        if (editMode.boolValue) {
            [self editPointUp];
        }
        else {
            [self editPointDown];
        }
    }];
    [[RACSignal combineLatest:@[keyboardIsShown, RACObserve(self, editUserPointMode)]] subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        RACTupleUnpack(NSNumber *keyboardShown, NSNumber *editMode) = tuple;
        if (keyboardShown.boolValue) {
            self.delegate.navigationItem.leftBarButtonItem = [self barItemCancelEditText];
            self.delegate.navigationItem.rightBarButtonItem = [self barItemApplyEditText];
            return;
        }
        if (editMode.boolValue) {

        }
        else {
            [self.delegate resetNavigationBarButtons];
        }
    }];


    RACSignal *showCountNumber = [[RACSignal merge:@[RACObserve(self, editUserPointMode), keyboardIsShown]] replayLast];

    RAC(self.pointInfoLabel, text) = [showCountNumber flattenMap:^RACStream *(NSNumber *showCount) {
        @strongify(self);
        if (showCount.boolValue) {
            return [[self.pointTextView rac_textSignal] map:^id(NSString *value) {
                return @((NSInteger)(POINT_LENGTH - value.length)).stringValue;
            }];
        }
        else {
            return [RACSignal return:NSLocalizedString(@"YOUR_EMPTY_POINT", nil)];
        }
    }];

    RAC(self.pointInfoLabel, textColor) = [showCountNumber flattenMap:^RACStream *(NSNumber *showCount) {
        @strongify(self);
        if (showCount.boolValue) {
            return [[self.pointTextView rac_textSignal] map:^id(NSString *value) {
                if (POINT_LENGTH - value.length <= RED_LIGHT_POINT_COUNT) {
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
}


- (void)updateConstraints {
    [super updateConstraints];
}

- (UIBarButtonItem *)barItemCancelEditText {
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] init];
    leftBarItem.title = @"Отмена";
    @weakify(self);
    leftBarItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)

        // EVENT HANDLER code here
        self.editUserPointMode = NO;
        [self.pointTextView resignFirstResponder];
        // An empty signal is a signal that completes immediately.
        return [RACSignal empty];
    }];
    return leftBarItem;
}

- (UIBarButtonItem *)barItemApplyEditText {
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] init];
    leftBarItem.title = @"Опубликовать";
    @weakify(self);
    leftBarItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        [self.pointTextView resignFirstResponder];
        // An empty signal is a signal that completes immediately.
        return [RACSignal empty];
    }];
    return leftBarItem;
}

#pragma mark - symbols counting


#pragma mark - constraint

- (void)fixUserPointConstraint {
    if (![UIDevice hp_isWideScreen]) {
        NSArray *cons = self.constraints;
        for (NSLayoutConstraint *consIter in cons) {
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                    (consIter.firstItem == self.avatarImageView))
                consIter.constant = CONSTRAINT_AVATAR_TOP;

            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                    (consIter.firstItem == self.pointTextView))
                consIter.constant = CONSTRAINT_POINT_TOP;

            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                    (consIter.firstItem == self.pointInfoLabel))
                consIter.constant = CONSTRAINT_POINT_INFO_TOP;

            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                    (consIter.firstItem == self.publishBtn))
                consIter.constant = CONSTRAINT_BTNS_BOTTOM_TOP;

            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                    (consIter.firstItem == self.deleteBtn))
                consIter.constant = CONSTRAINT_BTNS_BOTTOM_TOP;

            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                    (consIter.firstItem == self.deletePointView))
                consIter.constant = CONSTRAINT_VIEW_BOTTOM_TOP;

            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                    (consIter.firstItem == self.pointSettingsView))
                consIter.constant = CONSTRAINT_VIEW_BOTTOM_TOP;
        }
    }
}


#pragma mark - animation

- (void)editPointUp {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseOut
                     animations:^{
                         weakSelf.frame = CGRectMake(weakSelf.frame.origin.x, weakSelf.frame.origin.y - 115, weakSelf.frame.size.width, weakSelf.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)editPointDown {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseOut
                     animations:^{
                         weakSelf.frame = CGRectMake(weakSelf.frame.origin.x, weakSelf.frame.origin.y + 115, weakSelf.frame.size.width, weakSelf.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                     }];

}


#pragma mark - tap

- (void)setImageViewBgTap {
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]
            initWithTarget:self action:@selector(bgTap)];
    tgr.delegate = self;
    [self.avatarImageView addGestureRecognizer:tgr];
}

- (void)bgTap {

}

- (IBAction)publishSettTap:(id)sender {
}


- (IBAction)deletePointTap:(id)sender {
    [self editPointUp];
    self.pointTextView.userInteractionEnabled = NO;
    self.avatarImageView.userInteractionEnabled = NO;
    self.publishBtn.hidden = YES;
    self.deleteBtn.hidden = YES;
    self.pointSettingsView.hidden = YES;
    self.deletePointView.hidden = NO;
}

- (IBAction)deleteSettTap:(id)sender {
    [self editPointDown];
    self.pointTextView.userInteractionEnabled = YES;
    self.avatarImageView.userInteractionEnabled = YES;
    self.deletePointView.hidden = YES;
    self.publishBtn.hidden = NO;
    self.deleteBtn.hidden = YES;
}

- (IBAction)cancelSettTap:(id)sender {
    [self editPointDown];
    self.pointTextView.userInteractionEnabled = NO;
    self.avatarImageView.userInteractionEnabled = NO;
    self.deletePointView.hidden = YES;
    self.publishBtn.hidden = YES;
    self.deleteBtn.hidden = NO;
}


@end
