//
//  HPChatMsgTableViewCell.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 24.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPChatMsgTableViewCell.h"
#import "NSManagedObjectContext+HighPoint.h"
#import "NSManagedObject+HighPoint.h"
#import "DataStorage.h"
#import "PSMenuItem.h"
#import "HPChatBubbleView.h"

@interface HPChatMsgTableViewCell ()
@property(weak, nonatomic) IBOutlet UILabel *textMessageLabel;
@property(weak, nonatomic) IBOutlet HPChatBubbleView *backgroundOfMessage;
@property(weak, nonatomic) IBOutlet UILabel *timeLabel;
@property(weak, nonatomic) IBOutlet UIImageView *spinnerView;
@property(weak, nonatomic) IBOutlet UIImageView *doneImageView;
@property(weak, nonatomic) IBOutlet UIImageView *failedImageView;

@property(weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *timeConstraint;
@property(weak, nonatomic) Message *message;
@end

@implementation HPChatMsgTableViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
    [PSMenuItem installMenuHandlerForObject:self];
    User *currentUser = [[DataStorage sharedDataStorage] getCurrentUser];
    NSDateFormatter * timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"hh:mm"];
    RACSignal *messageSignal = [RACObserve(self, message) replayLast];
    RACSignal *offsetSignal = [RACObserve(self, tableViewController.offsetX) replayLast];
    RACSignal *isCurrentUserMessage = [[[messageSignal filter:^BOOL(id value) {
        return value!=nil;
    }] map:^id(Message *value) {
        return @([value.sourceId isEqualToNumber:currentUser.userId]);
    }] replayLast];

    //Configure position of bubble
    @weakify(self);
    RAC(self, leftConstraint.constant) = [isCurrentUserMessage flattenMap:^RACStream *(NSNumber *value) {
        @strongify(self);
        if (value.boolValue) {
            return [[messageSignal map:^id(Message *message) {
                return @(290 - 8 - [HPChatMsgTableViewCell sizeOfTextInModel:message].width);
            }] takeUntil:[self rac_prepareForReuseSignal]];
        }
        else {
            return [[offsetSignal map:^id(NSNumber *offset) {
                return @(offset.floatValue + 4.f);
            }] takeUntil:[self rac_prepareForReuseSignal]];
        }
    }];

    [[RACObserve(self, leftConstraint.constant) distinctUntilChanged] subscribeNext:^(id x) {
        @strongify(self);
        [self setNeedsUpdateConstraints];
    }];

    RACSignal *messageStatusSignal = RACObserve(self, message.status);
    //Configure color of bubble
    RAC(self, backgroundOfMessage.backgroundColor) = [[RACSignal combineLatest:@[isCurrentUserMessage,messageStatusSignal]] map:^id(RACTuple * tuple) {
        RACTupleUnpack(NSNumber *currentUser, NSNumber * messageStatus) = tuple;
        if(currentUser.boolValue){
            if(messageStatus.intValue == MessageStatusSendFailed) {
                return [UIColor colorWithRed:255.f / 255.f green:80.f / 255.f blue:60.f / 255.f alpha:1];
            }
            else{
                return [UIColor colorWithRed:80.f / 255.f green:227.f / 255.f blue:194.f / 255.f alpha:1];
            }
        }
        else{
            return [UIColor colorWithRed:230.f/255.f green:236.f/255.f blue:242.f/255.f alpha:1];
        }
    }];

    RAC(self, backgroundOfMessage.bubbleType) = [[isCurrentUserMessage distinctUntilChanged] map:^id(NSNumber * value) {
        if(value.boolValue)
            return @(BubbleTypeMine);
        else
            return @(BubbleTypeOther);
    }];

    //Configure bubble text
    RAC(self, textMessageLabel.text) = [messageSignal map:^id(Message *value) {
        return value.text;
    }];

    //Configure time label
    RAC(self, timeConstraint.constant) = [offsetSignal map:^id(NSNumber * value) {
        return @(value.floatValue-30);
    }];
    RAC(self, timeLabel.text) = [messageSignal map:^id(Message* value) {
        return [timeFormatter stringFromDate:value.createdAt];
    }];

    [self configureTapGestureWithMenu];
    [self configureSpinnerWithMessageStatusSignal:messageStatusSignal];
    [self configureFailedIconWithMessageStatusSignal:messageStatusSignal];
    [self configureDoneIconWithMessageStatusSignal:messageStatusSignal];
}


- (void)configureTapGestureWithMenu {
    @weakify(self);
    UITapGestureRecognizer *tapGestureRecognizer = [UITapGestureRecognizer new];
    [[tapGestureRecognizer rac_gestureSignal] subscribeNext:^(id x) {
        @strongify(self);
        [self becomeFirstResponder];
        UIMenuController * menuController = [UIMenuController sharedMenuController];
        [menuController setTargetRect:self.backgroundOfMessage.frame inView:self];
        NSMutableArray *buttonsArray = [NSMutableArray new];

        PSMenuItem *actionDelete = [[PSMenuItem alloc] initWithTitle:@"Delete" block:^{
            @strongify(self);
            [[DataStorage sharedDataStorage] deleteAndSaveEntity:self.message];
        }];
        [buttonsArray addObject:actionDelete];
        PSMenuItem *actionCopy = [[PSMenuItem alloc] initWithTitle:@"Copy" block:^{
            @strongify(self);
            UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
            [pasteBoard setString:self.message.text];
        }];
        [buttonsArray addObject:actionCopy];

        if(self.message.status.intValue == MessageStatusSendFailed){
            PSMenuItem *actionRetry = [[PSMenuItem alloc] initWithTitle:@"Retry" block:^{
                @strongify(self);
                [[DataStorage sharedDataStorage] setAndSaveMessageStatus:MessageStatusSending forMessage:self.message];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [[DataStorage sharedDataStorage] setAndSaveMessageStatus:MessageStatusSent forMessage:self.message];
                });
            }];
            [buttonsArray addObject:actionRetry];
        }
        [menuController setMenuItems:buttonsArray];

        menuController.arrowDirection = UIMenuControllerArrowDown;
        [menuController setMenuVisible:YES animated:YES];
    }];
    [self addGestureRecognizer:tapGestureRecognizer];
}

- (void)configureSpinnerWithMessageStatusSignal:(RACSignal *)messageStatusSignal {
    @weakify(self);
    RACSignal * spinnerShowSignal = [messageStatusSignal map:^id(NSNumber * value) {
        return @(value.intValue == MessageStatusSending);
    }];
    RAC(self,spinnerView.hidden) = [spinnerShowSignal not];

    [[[messageStatusSignal combinePreviousWithStart:@(-1) reduce:^id(id previous, id current) {
        return [RACTuple tupleWithObjects:previous, current, nil];
    }] filter:^BOOL(id value) {
        RACTupleUnpack(NSNumber * from, NSNumber * toValue) = value;
        return from.intValue == MessageStatusUnknown && toValue.intValue == MessageStatusSending;
    }] subscribeNext:^(id x) {
        @strongify(self);
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.fromValue = @(0);
        animation.toValue = @(1);
        animation.duration = 0.5f;
        [self.spinnerView.layer addAnimation:animation forKey:@"opacityAnimation"];
    }];

    [[[spinnerShowSignal distinctUntilChanged] filter:^BOOL(NSNumber * value) {
        return value.boolValue;
    }] subscribeNext:^(id x) {
        @strongify(self);
        CABasicAnimation* rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.fromValue = @0.0;
        rotationAnimation.toValue = @(M_PI * 2.0f);
        rotationAnimation.duration = 3.0f;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = 10;
        [self.spinnerView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    }];

    [[[spinnerShowSignal distinctUntilChanged] filter:^BOOL(NSNumber * value) {
        return !value.boolValue;
    }] subscribeNext:^(id x) {
        @strongify(self);
        [self.spinnerView.layer removeAnimationForKey:@"rotationAnimation"];
    }];
}

- (void)configureDoneIconWithMessageStatusSignal:(RACSignal *)signal {
    self.doneImageView.layer.opacity = 0;
    @weakify(self);
    [[[signal combinePreviousWithStart:@(-1) reduce:^id(id previous, id current) {
        return [RACTuple tupleWithObjects:previous, current, nil];
    }] filter:^BOOL(id value) {
        RACTupleUnpack(NSNumber * from, NSNumber * toValue) = value;
        return from.intValue == MessageStatusSending & toValue.intValue == MessageStatusSent;
    }] subscribeNext:^(id x) {
        @strongify(self);
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.fromValue = @(1);
        animation.toValue = @(0);
        animation.duration = 1.f;
        [self.doneImageView.layer addAnimation:animation forKey:@"opacityAnimation"];
    }];

    [self.rac_prepareForReuseSignal subscribeNext:^(id x) {
        @strongify(self);
        [self.doneImageView.layer removeAllAnimations];
        self.doneImageView.layer.opacity = 0;
    }];
}

- (void)configureFailedIconWithMessageStatusSignal:(RACSignal *)signal {
   RAC(self,failedImageView.hidden) = [signal map:^id(NSNumber * value) {
       return @(value.intValue != MessageStatusSendFailed);
   }];
}

- (void)bindViewModel:(Message *)viewModel {
    self.message = viewModel;
}

+ (CGFloat)heightForRowWithModel:(Message *)model {
    return [self sizeOfTextInModel:model].height + 15;
}

+ (CGSize)sizeOfTextInModel:(Message *)model {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    return [((Message *) [model moveToContext:context]).text boundingRectWithSize:(CGSize) {225, 9999} options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont fontWithName:@"FuturaPT-Book" size:18.0]} context:nil].size;
}

@end

