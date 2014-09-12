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

@interface HPChatMsgTableViewCell ()
@property(weak, nonatomic) IBOutlet UILabel *textMessageLabel;
@property(weak, nonatomic) IBOutlet UIView *backgroundOfMessage;
@property(weak, nonatomic) IBOutlet UILabel *timeLabel;

@property(weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *timeConstraint;
@property(weak, nonatomic) Message *message;
@end

@implementation HPChatMsgTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
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

    //Configure color of bubble
    RAC(self, backgroundOfMessage.backgroundColor) = [isCurrentUserMessage map:^id(NSNumber * value) {
        if(value.boolValue){
            return [UIColor colorWithRed:80.f/255.f green:227.f/255.f blue:194.f/255.f alpha:1];
        }
        else{
            return [UIColor colorWithRed:230.f/255.f green:236.f/255.f blue:242.f/255.f alpha:1];
        }
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
}


- (void)bindViewModel:(Message *)viewModel {
    self.message = viewModel;
}

+ (CGFloat)heightForRowWithModel:(Message *)model {
    return [self sizeOfTextInModel:model].height + 10;
}

+ (CGSize)sizeOfTextInModel:(Message *)model {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    return [((Message *) [model moveToContext:context]).text boundingRectWithSize:(CGSize) {225, 9999} options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont fontWithName:@"FuturaPT-Book" size:18.0]} context:nil].size;
}

@end

