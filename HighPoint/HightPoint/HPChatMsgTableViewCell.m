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
@property(weak, nonatomic) Message *message;
@end

@implementation HPChatMsgTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    User* currentUser = [[DataStorage sharedDataStorage] getCurrentUser];
    RACSignal *messageSignal = RACObserve(self, message);
    RACSignal *offsetSignal = RACObserve(self, tableViewController.offsetX);
    RACSignal *isCurrentUserMessage = [messageSignal map:^id(Message* value) {
        return @([value.sourceId isEqualToNumber:currentUser.userId]);
    }];
    @weakify(self);
    RAC(self,textMessageLabel.frame) = [isCurrentUserMessage flattenMap:^RACStream *(NSNumber * value) {
        @strongify(self);
        if(value.boolValue) {
            return [[[offsetSignal map:^id(NSNumber * offset) {
                return @(offset.floatValue + 10.f);
            }] map:^id(NSNumber * left) {
                @strongify(self);
                CGRect rect = (CGRect){left.floatValue,self.textMessageLabel.frame.origin.y,self.textMessageLabel.frame.size};
                return [NSValue valueWithCGRect:rect];
            }] takeUntil:[self rac_prepareForReuseSignal]];
        }
        else{
            return [[[messageSignal map:^id(Message* message) {
                return @(310 - [HPChatMsgTableViewCell sizeOfTextInModel:message].width);
            }]  map:^id(NSNumber * left) {
                @strongify(self);
                CGRect rect = (CGRect){left.floatValue,self.textMessageLabel.frame.origin.y,self.textMessageLabel.frame.size};
                return [NSValue valueWithCGRect:rect];
            }] takeUntil:[self rac_prepareForReuseSignal]];
        }
    }];
    RAC(self,textMessageLabel.text) = [messageSignal map:^id(Message * value) {
        return value.text;
    }];
}


- (void)bindViewModel:(Message *)viewModel {
    self.message = viewModel;
}

+ (CGFloat)heightForRowWithModel:(Message *)model {
    return [self sizeOfTextInModel:model].height + 25;
}

+ (CGSize) sizeOfTextInModel:(Message *)model {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    return [((Message *) [model moveToContext:context]).text boundingRectWithSize:(CGSize) {245, 9999} options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont fontWithName:@"FuturaPT-Book" size:18.0]} context:nil].size;
}

@end

