//
// Created by Eugene on 23.09.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPChatMsgOpenRequestCell.h"
#import "DataStorage.h"

@interface HPChatMsgOpenRequestCell ()
@property (nonatomic, weak) IBOutlet UILabel * cellTextLabel;
@property(nonatomic, weak) Message *message;
@end

@implementation HPChatMsgOpenRequestCell

- (void)awakeFromNib {
    NSNumber *currentUserId = [[DataStorage sharedDataStorage] getCurrentUser].userId;
    RAC(self, cellTextLabel.text) = [RACObserve(self, message) map:^id(Message *value) {
        if ([value.destinationId isEqual:currentUserId]) {
            NSString *name;
            if ([value.chat.user.visibility isEqual:@(UserVisibilityVisible)]) {
                name = value.chat.user.name;
            }
            else {
                name = [value.chat.user.gender isEqual:@(UserGenderFemale)] ? @"Она" : @"Он";
            }

            return [NSString stringWithFormat:@"%@ просит вас открывать свой профиль. Вы можете открытся ей или начать общаться прямо сейчас.", name];
        }
        else {
            return [value.chat.user.gender isEqual:@(UserGenderFemale)] ? @"Вы попросили открыть её имя и фотографии для вас. Когда она откроется вы получите уведомление." : @"Вы попросили открыть его имя и фотографии для вас. Когда она откроется вы получите уведомление.";
        }
        return nil;
    }];
}

- (void)bindViewModel:(Message *)viewModel {
    self.message = viewModel;
}

@end