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
#import "UIImageView+WebCache.h"
#import "Avatar.h"

#define POINT_LENGTH 140
#define MIN_POINT_LENGTH 5
#define RED_LIGHT_POINT_COUNT 10


@interface HPCurrentUserPointCollectionViewCell ()
//Private methods
- (void)animateMainViewToTop;

- (void)animateMainViewToBottom;


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
}


#pragma mark - constraint

- (void)updateConstraints {
    [super updateConstraints];
}

#pragma mark Configuring UIElements

- (void)configureMainView {
    @weakify(self);
    [[RACObserve(self, editUserPointMode) distinctUntilChanged] subscribeNext:^(NSNumber *editMode) {
        @strongify(self);
        if (editMode.boolValue) {
            [self animateMainViewToTop];
        }
        else {
            [self animateMainViewToBottom];
        }
    }];
}


//Counter of symbols in textView
- (void)configurePointInfoLabel {
    @weakify(self);
    RACSignal *showCountNumber = [[RACSignal merge:@[RACObserve(self, editUserPointMode), [self textViewIsEditing]]] replayLast];

    RAC(self.pointInfoLabel, text) = [[RACSignal combineLatest:@[RACObserve(self, editUserPointMode), showCountNumber]]
            flattenMap:^RACStream *(RACTuple *x) {
                RACTupleUnpack(NSNumber *editMode, NSNumber *showCount) = x;
                @strongify(self);
                if (showCount.boolValue || editMode.boolValue) {
                    return [[self.pointTextView rac_textSignal] map:^id(NSString *value) {
                        return @((NSInteger) (POINT_LENGTH - value.length)).stringValue;
                    }];
                }
                else {
                    return [RACSignal return:NSLocalizedString(@"NO_ACTIVE_POINT", nil)];
                }
            }];

    RAC(self.pointInfoLabel, textColor) = [showCountNumber flattenMap:^RACStream *(NSNumber *showCount) {
        @strongify(self);
        if (showCount.boolValue) {
            return [[self.pointTextView rac_textSignal] map:^id(NSString *value) {
                if ((NSInteger) (POINT_LENGTH - value.length) <= RED_LIGHT_POINT_COUNT) {
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

//Configure buttons of navigation bar
- (void)configureNavigationBar {
    @weakify(self);
    [[RACSignal combineLatest:@[[self textViewIsEditing], RACObserve(self, editUserPointMode)]] subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        RACTupleUnpack(NSNumber *textViewEditing, NSNumber *editMode) = tuple;
        if (textViewEditing.boolValue) {
            self.delegate.navigationItem.leftBarButtonItem = [self barItemCancelEditText];
            self.delegate.navigationItem.rightBarButtonItem = [self barItemApplyEditText];
            return;
        }
        if (editMode.boolValue) {
            self.delegate.navigationItem.leftBarButtonItem = [self barItemCancelEditText];
            self.delegate.navigationItem.rightBarButtonItem = [self barItemFinishPublish];
        }
        else {
            [self.delegate resetNavigationBarButtons];
        }
    }];

}

//Visibility of point settings
- (void)configurePointSettingsView {
    RAC(self.pointSettingsView, hidden) = [RACObserve(self, editUserPointMode) not];
}

//Configure placeholde
- (void)configurePointTextView {
    UIColor *placeHolderColor = [UIColor colorWithRed:230.f / 255.f green:236.f / 255.f blue:243.f / 255.f alpha:0.6];
    self.pointTextView.text = NSLocalizedString(@"YOUR_EMPTY_POINT", nil);
    self.pointTextView.textColor = placeHolderColor;
    @weakify(self);
    [[RACSignal combineLatest:@[[self textViewIsEditing], RACObserve(self.pointTextView, text)]] subscribeNext:^(RACTuple *x) {
        @strongify(self);
        RACTupleUnpack(NSNumber *isEdit, NSString *text) = x;
        if (isEdit.boolValue) {
            if ([self.pointTextView.text isEqualToString:NSLocalizedString(@"YOUR_EMPTY_POINT", nil)]) {
                self.pointTextView.text = @"";
            }
            self.pointTextView.textColor = [UIColor whiteColor];
        }
        else {
            if ([self.pointTextView.text isEqualToString:@""]) {
                self.pointTextView.text = NSLocalizedString(@"YOUR_EMPTY_POINT", nil);
                self.pointTextView.textColor = placeHolderColor;
            }
        }
    }];

    self.pointTextView.delegate = self;
}

- (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound) {
        return YES;
    }
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
    [RACObserve(self, currentUser) subscribeNext:^(User *currentUser) {
        @strongify(self);
        [self.avatarImageView setImageWithURL:[NSURL URLWithString:currentUser.avatar.squareImageSrc ?: currentUser.avatar.originalImageSrc] placeholderImage:[UIImage imageNamed:@"no_image.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            @strongify(self);
            self.avatarImageView.image = [image addBlendToPhoto];
        }];
    }];
}

- (void)configurePublishButton {
    RAC(self.publishBtn, hidden) = RACObserve(self, editUserPointMode);
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

#pragma mark Actions

- (void)createUserPointWithCurrentData {
    if ([self.delegate respondsToSelector:@selector(createPointWithPointText:andTime:forUser:)]) {
        [self.delegate createPointWithPointText:self.pointTextView.text andTime:@(self.pointTimeSlider.value) forUser:self.currentUser];
    }
    self.editUserPointMode = NO;
    self.pointTextView.text = @"";
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

- (RACSignal *)symbolsInPostIsAvailableToPost {
    return [[self.pointTextView rac_textSignal] map:^id(NSString *value) {
        if ([self.pointTextView.text isEqualToString:NSLocalizedString(@"YOUR_EMPTY_POINT", nil)]) {
            return @(NO);
        }
        if (value.length < MIN_POINT_LENGTH)
            return @(NO);
        return @((NSInteger) (POINT_LENGTH - value.length) >= 0);
    }];
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
    rightBarItem.rac_command = [[RACCommand alloc] initWithEnabled:[self symbolsInPostIsAvailableToPost] signalBlock:^RACSignal *(id input) {
        @strongify(self)
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
    rightBarItem.rac_command = [[RACCommand alloc] initWithEnabled:[self symbolsInPostIsAvailableToPost] signalBlock:^RACSignal *(id input) {
        @strongify(self)
        [self createUserPointWithCurrentData];
        return [RACSignal empty];
    }];
    return rightBarItem;
}

#pragma mark - animation

- (void)animateMainViewToTop {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseOut
                     animations:^{
                         weakSelf.frame = CGRectMake(weakSelf.frame.origin.x, weakSelf.frame.origin.y - 115, weakSelf.frame.size.width, weakSelf.frame.size.height + 115);
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)animateMainViewToBottom {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseOut
                     animations:^{
                         weakSelf.frame = CGRectMake(weakSelf.frame.origin.x, weakSelf.frame.origin.y + 115, weakSelf.frame.size.width, weakSelf.frame.size.height - 115);
                     }
                     completion:^(BOOL finished) {
                     }];

}
@end
