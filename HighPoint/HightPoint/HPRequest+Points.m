//
// Created by Eugene on 01.09.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPRequest+Points.h"
#import "URLs.h"
#import "Constants.h"
#import "UserPoint.h"
#import "HPCityValidator.h"
#import "DataStorage.h"
#import "HPUserValidator.h"


@implementation HPRequest (Points)

#pragma mark public

+ (RACSignal *)getLikedUserOfPoint:(UserPoint *)point {

    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:[NSString stringWithFormat:kPointLikesRequest, point.pointId]];
    RACSignal *usersJsonArrayFromServer = [self getDataFromServerWithUrl:url andParameters:nil];
    RACSignal *validUsersJsonArrayFromServer = [self validateServerUsersArray:usersJsonArrayFromServer];
    RACSignal *savedUsersArray = [self saveServerUsersArray:validUsersJsonArrayFromServer];
    RACSignal *likedUsersArray = [self setUsersArray:savedUsersArray toLikePost:point];
    return likedUsersArray;
}

#pragma mark private

+ (RACSignal *)validateServerUsersArray:(RACSignal *)signal {
    return [[signal flattenMap:^RACStream *(NSDictionary *value) {
        //Проверяем масив городов что он есть, и является массивом
        if ([value isKindOfClass:[NSDictionary class]]) {
            if ([value[@"data"] isKindOfClass:[NSDictionary class]]) {
                if ([value[@"data"][@"users"] isKindOfClass:[NSArray class]]) {
                    return [RACSignal return:value[@"data"][@"users"]];
                }
            }
            if ([value[@"data"] isKindOfClass:[NSNull class]]) {
                return [RACSignal empty];
            }
        }

        return [RACSignal error:[NSError errorWithDomain:@"Not valid json data" code:400 userInfo:value]];
    }] map:^id(NSArray *value) {
        return [value.rac_sequence filter:^BOOL(NSDictionary *validatedDictionary) {
            return [HPUserValidator validateDictionary:validatedDictionary];
        }].array;
    }];
}

+ (RACSignal *)saveServerUsersArray:(RACSignal *)signal {
    return [[signal map:^NSArray *(NSArray *value) {
        return [value.rac_sequence map:^id(NSDictionary *cityDict) {
            return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
                //Записывем каждый элемент
                NSMutableArray *arr = [NSMutableArray arrayWithObject:cityDict];
                NSLog(@"%@", cityDict);
                [[DataStorage sharedDataStorage] createAndSaveUserEntity:arr forUserType:PointLikeUserType withComplation:^(id object) {
                    if (!object) {
                        
                        User *usr = [[DataStorage sharedDataStorage] getUserForId:cityDict[@"id"]];
                        [subscriber sendNext:usr];
                        [subscriber sendCompleted];
                    }
                    else {
                        [subscriber sendNext:[NSError errorWithDomain:@"CoreData fault" code:500 userInfo:nil]];
                    }
                }];
                return nil;
            }];
        }].array;
    }] flattenMap:^RACStream *(NSArray *value) {
        //Обеденяем все элементы и сохраняем
        return [RACSignal zip:value];
    }];
}

+ (RACSignal *)setUsersArray:(RACSignal *)signal toLikePost:(UserPoint *)point {
    return [[signal map:^NSArray *(NSArray *value) {
        return [value.rac_sequence map:^id(User *user) {
            return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
                //Записывем каждый элемент
                [[DataStorage sharedDataStorage] setAndSaveUser:user toLikePoint:point withComplationBlock:^(id object) {
                    if (object) {
                        [subscriber sendNext:object];
                        [subscriber sendCompleted];
                    }
                    else {
                        [subscriber sendNext:[NSError errorWithDomain:@"CoreData fault" code:500 userInfo:nil]];
                    }
                }];
                return nil;
            }];
        }].array;
    }] flattenMap:^RACStream *(NSArray *value) {
        return [RACSignal zip:value];
    }];
}

@end