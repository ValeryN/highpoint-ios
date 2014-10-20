//
//  HPChatTableViewCell.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 08.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPChatTableViewCell.h"
#import "User.h"
#import "Message.h"
#import "City.h"
#import "DataStorage.h"
#import "NSManagedObject+HighPoint.h"
#import "NSManagedObjectContext+HighPoint.h"
#import "HPBaseNetworkManager+Contacts.h"

@interface HPChatTableViewCell ()

@property(nonatomic, weak) Contact *contact;
@property(weak, nonatomic) IBOutlet UIScrollView *scrollView;

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCUnusedPropertyInspection"
//Need by superclass, IBOutlet to xib
@property(weak, nonatomic) IBOutlet UIView *scrollViewButtonView;
#pragma clang diagnostic pop

@property(weak, nonatomic) IBOutlet HPAvatarView *avatarView;

@property(weak, nonatomic) IBOutlet UIView *msgToYouView;
@property(weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property(weak, nonatomic) IBOutlet UILabel *userAgeAndLocationLabel;
@property(weak, nonatomic) IBOutlet UILabel *currentMsgLabel;

@property(weak, nonatomic) IBOutlet UIView *msgCountView;
@property(weak, nonatomic) IBOutlet UILabel *msgCountLabel;

@property(weak, nonatomic) IBOutlet HPAvatarView *myAvatar;
@property(weak, nonatomic) IBOutlet UIView *msgFromMyself;
@property(weak, nonatomic) IBOutlet UILabel *currentUserMsgLabel;

@property(weak, nonatomic) IBOutlet UIView *sepTop;
@property(weak, nonatomic) IBOutlet UIView *sepBottom;

@end

@implementation HPChatTableViewCell

- (void)awakeFromNib {
    self.scrollView.delegate = self;
    self.tap_Gesture = [UITapGestureRecognizer new];
    [self.scrollView addGestureRecognizer:self.tap_Gesture];
    [self configureSeparatorLines];
    [self configureCellView];
}

- (void)configureCellView {
    @weakify(self);

    RACSignal *contactUserSignal = [RACObserve(self, contact.user) replayLast];
    RACSignal *contactUserIdSignal = [[contactUserSignal map:^id(User* value) {
        return value.userId;
    }] distinctUntilChanged];
    RACSignal *lastMessageSignal = [RACObserve(self, contact.lastmessage.text) replayLast];
    RACSignal *ageSignal = [contactUserSignal map:^id(User*user) {
        return user.age;
    }];
    RACSignal *myMessageLastSignal = [[[RACSignal combineLatest:@[contactUserIdSignal, [RACObserve(self, contact.lastmessage.destinationId) distinctUntilChanged]]] map:^id(RACTuple *value) {
        RACTupleUnpack(NSNumber *contactId, NSNumber *messageDestinationId) = value;
        return @([contactId isEqualToNumber:messageDestinationId ?: @(0)]);
    }] replayLast];
    RACSignal * unreadMessageCountSignal = [[[RACObserve(self, contact.lastmessage) distinctUntilChanged] flattenMap:^RACStream *(id value) {
        @strongify(self);
        return [[[[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
            @strongify(self);
            [subscriber sendNext:@(0)];
            [subscriber sendNext:@([[DataStorage sharedDataStorage] allUnreadMessagesCount:[self.contact.user moveToContext:[NSManagedObjectContext threadContext]]])];
            [subscriber sendCompleted];
            return nil;
        }] subscribeOn:[RACScheduler scheduler]] deliverOn:[RACScheduler mainThreadScheduler]] takeUntil:[self rac_prepareForReuseSignal]];
    }] replayLast];


    self.myAvatar.user = [[DataStorage sharedDataStorage] getCurrentUser];
    RAC(self, msgCountView.hidden) = [unreadMessageCountSignal map:^id(NSNumber *value) {
        return @(value.integerValue == 0);
    }];
    RAC(self, msgCountLabel.text) = [unreadMessageCountSignal map:^id(NSNumber *value) {
        return value.stringValue;
    }];
    RAC(self, avatarView.user) = contactUserSignal;
    RAC(self, userNameLabel.text) = [contactUserSignal map:^id(User* user) {
        return user.name;
    }];
    RAC(self, userAgeAndLocationLabel.text) = [[RACSignal combineLatest:@[[RACObserve(self, contact.user.city.cityName) distinctUntilChanged], [ageSignal distinctUntilChanged]]] map:^id(RACTuple *value) {
        RACTupleUnpack(NSString *city, NSString *age) = value;
        return [NSString stringWithFormat:@"%@ лет, %@", age, city ?: NSLocalizedString(@"UNKNOWN_CITY_ID", nil)];;
    }];
    RAC(self, currentMsgLabel.hidden) = myMessageLastSignal;
    RAC(self, msgFromMyself.hidden) = [myMessageLastSignal not];
    RAC(self, currentMsgLabel.text) = lastMessageSignal;
    RAC(self, currentUserMsgLabel.text) = lastMessageSignal;
}

- (void)configureSeparatorLines {
    RACSignal *showSeparatorLinesSignal = [RACObserve(self, scrollView.contentOffset) map:^id(NSValue *value) {
        CGPoint size = [value CGPointValue];
        return @(size.x > 0);
    }];
    RAC(self, sepTop.hidden) = [showSeparatorLinesSignal not];
    RAC(self, sepBottom.hidden) = [showSeparatorLinesSignal not];
}

- (int)returnCatchWidth {
    return 120;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    if (self.scrollView.contentOffset.x != 0) {
        [self.scrollView setContentOffset:CGPointZero animated:NO];
    }
}

- (void)bindViewModel:(Contact *)contact {
    self.contact = contact;
}


- (IBAction)deleteBtnTap:(id)sender {
    [[HPBaseNetworkManager sharedNetworkManager] deleteContactRequest:self.contact.user.userId];
}
@end
