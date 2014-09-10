//
// Created by Eugene on 10.09.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPRequest+Users.h"
#import "User.h"
#import "Message.h"
#import "URLs.h"
#import "Constants.h"
#import "HPMessageValidator.h"
#import "DataStorage.h"


@implementation HPRequest (Users)

+ (RACSignal*)getMessagesForUser:(User *)user afterMessage:(Message *)message {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kUserMessagesRequest];
    url = [NSString stringWithFormat:url,user.userId];
    NSDictionary *param;
    if(message){
        param = @{@"afterMessageId" : message.id_};
    }

    RACSignal *dataFromServer = [self getDataFromServerWithUrl:url andParameters:param];

    RACSignal *validatedServerData = [self validateServerMessagesArray:dataFromServer];

    RACSignal *savedDataToDataBase = [self saveServerMessagesArray:validatedServerData];

    return savedDataToDataBase;
}


+ (RACSignal *)validateServerMessagesArray:(RACSignal *)signal {
    return [[signal flattenMap:^RACStream *(NSDictionary *value) {
        //Проверяем масив городов что он есть, и является массивом
        if ([value isKindOfClass:[NSDictionary class]]) {
            if ([value[@"data"] isKindOfClass:[NSDictionary class]]) {
                if ([value[@"data"][@"messages"] isKindOfClass:[NSArray class]]) {
                    return [RACSignal return:value[@"data"][@"messages"]];
                }
            }
            if ([value[@"data"] isKindOfClass:[NSNull class]]) {
                return [RACSignal empty];
            }
        }

        return [RACSignal error:[NSError errorWithDomain:@"Not valid json data" code:400 userInfo:value]];
    }] map:^id(NSArray *value) {
        return [value.rac_sequence filter:^BOOL(NSDictionary *validatedDictionary) {
            return [HPMessageValidator validateDictionary:validatedDictionary];
        }].array;
    }];
}

+ (RACSignal *)saveServerMessagesArray:(RACSignal *)signal {
    NSNumber * currentUserId = [[DataStorage sharedDataStorage] getCurrentUser].userId;
    return [[signal map:^NSArray *(NSArray *value) {
        return [value.rac_sequence map:^id(NSDictionary *cityDict) {
            return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
                //Могли бы сами позаботится из dict определить какому юзеру связывать, бред какойто
                NSNumber *userId = [cityDict[@"destinationId"] isEqual:currentUserId]?cityDict[@"sourceId"]:cityDict[@"destinationId"];
                //Записывем каждый элемент
                [[DataStorage sharedDataStorage] createAndSaveMessage:cityDict forUserId:userId andMessageType:HistoryMessageType withComplation:^(id object) {
                    if (object) {
                        //Пробрасываем дальнейшие данные не JSON а уже City
                        [subscriber sendNext:object];
                        [subscriber sendCompleted];
                    }
                    else {
                        [subscriber sendNext:[NSError errorWithDomain:@"CoreData fault" code:500 userInfo:nil]];
                    }
                }];
                [[DataStorage sharedDataStorage] createAndSaveCity:cityDict popular:NO withComplation:^(City *object) {

                }];
                return nil;
            }];
        }].array;
    }] flattenMap:^RACStream *(NSArray *value) {
        //Обеденяем все элементы и сохраняем
        return [RACSignal zip:value];
    }];
}
@end