//
// Created by Eugene on 23.09.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPChatMsgOpenDenyCell.h"
#import "Message.h"
#import "DataStorage.h"

@interface HPChatMsgOpenDenyCell ()
@property (nonatomic, weak) IBOutlet UILabel * cellTextLabel;
@property(nonatomic, weak) Message *message;
@end

@implementation HPChatMsgOpenDenyCell

- (void)awakeFromNib {
    NSNumber *currentUserId = [[DataStorage sharedDataStorage] getCurrentUser].userId;
    RAC(self, cellTextLabel.text) = [RACObserve(self, message) map:^id(Message *value) {
        if ([value.destinationId isEqual:currentUserId]) {
            return [value.chat.user.gender isEqual:@(UserGenderFemale)] ? @"Она отказала открывать вам свое имя и фотографии" : @"Он отказал открывать вам свое имя и фотографии";
        }
        else {
            NSString *name;
            if ([value.chat.user.visibility isEqual:@(UserVisibilityVisible)]) {
                name = value.chat.user.name;
            }
            else {
                name = [value.chat.user.gender isEqual:@(UserGenderFemale)] ? @"ей" : @"ему";
            }

            return [NSString stringWithFormat:@"Вы отказали открывать %@ свое имя и фотографии", name];
        }
        return nil;
    }];
}

- (void)bindViewModel:(Message *)viewModel {
    self.message = viewModel;
}

@end