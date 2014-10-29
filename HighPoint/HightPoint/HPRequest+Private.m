//
//  HPRequest+Private.m
//  HighPoint
//
//  Created by Eugene on 28/10/14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPRequest+Private.h"
#import "DataStorage.h"
#import "NSNumber+Convert.h"
#import "HPMessageValidator.h"
#import "HPUserValidator.h"
#import "HPPointValidator.h"
#import "HPCityValidator.h"
#import "HPAdditionalUserInfoManager.h"

@implementation HPRequest (Private)
#pragma mark validator
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
+ (RACSignal *)validateServerPointsArray:(RACSignal *)signal {
    return [[signal flattenMap:^RACStream *(NSDictionary *value) {
        //Проверяем масив городов что он есть, и является массивом
        if ([value isKindOfClass:[NSDictionary class]]) {
            if ([value[@"data"] isKindOfClass:[NSDictionary class]]) {
                if ([value[@"data"][@"points"] isKindOfClass:[NSDictionary class]]) {
                    return [RACSignal return:((NSDictionary*)value[@"data"][@"points"]).allValues];
                }
                if ([value[@"data"][@"points"] isKindOfClass:[NSArray class]]) {
                    return [RACSignal return:((NSDictionary*)value[@"data"][@"points"])];
                }
            }
            if ([value[@"data"] isKindOfClass:[NSNull class]]) {
                return [RACSignal empty];
            }
        }
        
        return [RACSignal error:[NSError errorWithDomain:@"Not valid json data" code:400 userInfo:value]];
    }] map:^id(NSArray *value) {
        return [value.rac_sequence filter:^BOOL(NSDictionary *validatedDictionary) {
            return [HPPointValidator validateDictionary:validatedDictionary];
        }].array;
    }];
}

+ (RACSignal *)validateServerUsersArray:(RACSignal *)signal {
    return [[signal flattenMap:^RACStream *(NSDictionary *value) {
        //Проверяем масив городов что он есть, и является массивом
        if ([value isKindOfClass:[NSDictionary class]]) {
            if ([value[@"data"] isKindOfClass:[NSDictionary class]]) {
                if ([value[@"data"][@"users"] isKindOfClass:[NSDictionary class]]) {
                    return [RACSignal return:((NSDictionary*)value[@"data"][@"users"]).allValues];
                }

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

+ (RACSignal *)validateServerCityArray:(RACSignal *)signal {
    return [[signal flattenMap:^RACStream *(NSDictionary *value) {
        //Проверяем масив городов что он есть, и является массивом
        if ([value isKindOfClass:[NSDictionary class]]) {
            if ([value[@"data"] isKindOfClass:[NSDictionary class]]) {
                if ([value[@"data"][@"cities"] isKindOfClass:[NSArray class]]) {
                    return [RACSignal return:value[@"data"][@"cities"]];
                }
            }
            if ([value[@"data"] isKindOfClass:[NSNull class]]) {
                return [RACSignal empty];
            }
        }
        
        return [RACSignal error:[NSError errorWithDomain:@"Not valid json data" code:400 userInfo:value]];
    }] map:^id(NSArray *value) {
        return [value.rac_sequence filter:^BOOL(NSDictionary *validatedDictionary) {
            //Проверяем валидные поля каждого элемента и игнорируем все которые не валидны
            return [HPCityValidator validateDictionary:validatedDictionary];
        }].array;
    }];
}


#pragma mark savers

+ (RACSignal *)saveServerCityArray:(RACSignal *)signal {
    return [[signal map:^NSArray *(NSArray *value) {
        return [value.rac_sequence map:^id(NSDictionary *cityDict) {
            return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
                //Записывем каждый элемент
                [[DataStorage sharedDataStorage] createAndSaveCity:cityDict popular:NO withComplation:^(City *object) {
                    if (object) {
                        //Пробрасываем дальнейшие данные не JSON а уже City
                        [subscriber sendNext:object];
                        [subscriber sendCompleted];
                    }
                    else {
                        [subscriber sendError:[NSError errorWithDomain:@"CoreData fault" code:500 userInfo:nil]];
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

+ (RACSignal *)saveServerUsersArray:(RACSignal *)signal {
    return [[signal map:^NSArray *(NSArray *value) {
        return [value.rac_sequence map:^id(NSDictionary *cityDict) {
            return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
                //Записывем каждый элемент
                NSMutableArray *arr = [NSMutableArray arrayWithObject:cityDict];
                [[DataStorage sharedDataStorage] createAndSaveUserEntity:arr forUserType:PointLikeUserType withComplation:^(User* object) {
                    if (object) {
                        [subscriber sendNext:[object MR_inContext:[NSManagedObjectContext MR_contextForCurrentThread]]];
                        [subscriber sendCompleted];
                    }
                    else {
                        [subscriber sendNext:[NSError errorWithDomain:@"CoreData fault" code:500 userInfo:nil]];
                    }
                }];
                return nil;
            }] subscribeOn:[RACScheduler scheduler]];
        }].array;
    }] flattenMap:^RACStream *(NSArray *value) {
        //Обеденяем все элементы и сохраняем
        return [RACSignal zip:value];
    }];
}

+ (RACSignal*) saveServerPointsArray:(RACSignal *) signal{
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    return [[signal map:^NSArray *(NSArray *value) {
        return [value.rac_sequence map:^id(NSDictionary *dict) {
            return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
                __block UserPoint *userPoint;
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                    userPoint = [UserPoint MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"pointId == %d", [dict[@"id"] intValue]] inContext:localContext];
                    if(!userPoint)
                        userPoint = [UserPoint MR_createInContext:localContext];
                    userPoint.pointId = [dict[@"id"] convertToNSNumber];
                    userPoint.userId = [dict[@"userId"] convertToNSNumber];
                    userPoint.pointCreatedAt = [df dateFromString:dict[@"createdAt"]];
                    userPoint.pointLiked = [dict[@"liked"] convertToNSNumber];
                    userPoint.pointText = [dict[@"text"] convertToNSString];
                    userPoint.pointUserId = [[dict[@"userId"] convertToNSNumber] convertToNSNumber];
                    userPoint.pointValidTo =  [df dateFromString:dict[@"validTo"]];
                } completion:^(BOOL success, NSError *error) {
                    if(!error){
                        [subscriber sendNext:[userPoint MR_inContext:[NSManagedObjectContext MR_contextForCurrentThread]]];
                        [subscriber sendCompleted];
                    }
                    else{
                        [subscriber sendError:error];
                    }
                }];
                return nil;
            }] subscribeOn:[RACScheduler scheduler]];
        }].array;
    }] flattenMap:^RACStream *(NSArray *value) {
        //Обеденяем все элементы и сохраняем
        return [RACSignal zip:value];
    }];
}

+ (RACSignal*) mergeUserSignal:(RACSignal*) userSignal withPointsSingal:(RACSignal*) pointsSignal{
    return [[RACSignal zip:@[userSignal,pointsSignal]] flattenMap:^RACSignal*(RACTuple* value) {
        return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            RACTupleUnpack(NSArray* usersArrayGlobal, NSArray* pointsArrayGlobal) = value;
            NSManagedObjectContext* context = [NSManagedObjectContext MR_contextForCurrentThread];
            NSArray* userArrayLocal = [usersArrayGlobal.rac_sequence map:^id(User* user) {
                return [user MR_inContext:context];
            }].array;
            NSArray* pointsArrayLocal = [pointsArrayGlobal.rac_sequence map:^id(UserPoint* point) {
                return [point MR_inContext:context];
            }].array;
            
            NSDictionary* cacheDictionary = [NSDictionary dictionaryWithObjects:userArrayLocal forKeys:[userArrayLocal valueForKeyPath:@"userId"]];
            [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
                for(UserPoint* point in pointsArrayLocal){
                    point.user = cacheDictionary[point.userId];
                }
            } completion:^(BOOL success, NSError *error) {
                if(!error){
                    [subscriber sendNext:userArrayLocal];
                    [subscriber sendCompleted];
                }
                else{
                    [subscriber sendError:error];
                }
            }];
            return nil;
        }] subscribeOn:[RACScheduler scheduler]];
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
                        [subscriber sendError:[NSError errorWithDomain:@"CoreData fault" code:500 userInfo:nil]];
                    }
                }];
                return nil;
            }];
        }].array;
    }] flattenMap:^RACStream *(NSArray *value) {
        return [RACSignal zip:value];
    }];
}
//TODO: not final version
+ (RACSignal *)saveServerMessagesArray:(RACSignal *)signal {
    //NSNumber * currentUserId = [[DataStorage sharedDataStorage] getCurrentUser].userId;
    return [[signal map:^NSArray *(NSArray *value) {
        //
        [[DataStorage sharedDataStorage] createAndSaveMessageArray:value andMessageType:HistoryMessageType withComplation:^(id object) {
            if(!object) {
                
            }
        }];
        return [value.rac_sequence map:^id(NSDictionary *cityDict) { //[value.rac_sequence map:^id(NSDictionary *cityDict)
            return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
                
                //NSNumber *userId = [cityDict[@"destinationId"] isEqual:currentUserId]?cityDict[@"sourceId"]:cityDict[@"destinationId"];
                //Записывем каждый элемент
                
                id message = [[DataStorage sharedDataStorage] getMessageForId:[cityDict[@"id"] convertToNSNumber]];
                if (message) {
                    //Пробрасываем дальнейшие данные не JSON а уже City
                    [subscriber sendNext:message];
                    [subscriber sendCompleted];
                }
                else {
                    [subscriber sendError:[NSError errorWithDomain:@"CoreData fault" code:500 userInfo:nil]];
                }
                
                
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

+ (RACSignal *) requestCitiesForUsersServerArray:(RACSignal*) signal{
    return [[signal map:^NSArray *(NSArray *value) {
        return [value.rac_sequence map:^id(NSDictionary *userDict) {
            return [[HPAdditionalUserInfoManager instance] getCitySignalForId:userDict[@"cityId"]];
        }].array;
    }] flattenMap:^RACStream *(NSArray *value) {
        //Обеденяем все элементы и сохраняем
        return [RACSignal zip:value];
    }];
}

+ (RACSignal*) mergeUserSignal:(RACSignal*) userSignal withCitySingal:(RACSignal*) citySignal{
    return [[RACSignal zip:@[userSignal,citySignal]] flattenMap:^RACSignal*(RACTuple* value) {
        return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            RACTupleUnpack(NSArray* usersArrayGlobal, NSArray* citiesArrayGlobal) = value;
            NSManagedObjectContext* context = [NSManagedObjectContext MR_contextForCurrentThread];
            NSArray* userArrayLocal = [usersArrayGlobal.rac_sequence map:^id(User* user) {
                return [user MR_inContext:context];
            }].array;
            NSArray* citiesArrayLocal = [citiesArrayGlobal.rac_sequence map:^id(City* city) {
                return [city MR_inContext:context];
            }].array;
            
            NSDictionary* cacheDictionary = [NSDictionary dictionaryWithObjects:citiesArrayLocal forKeys:[userArrayLocal valueForKeyPath:@"cityId"]];
            [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
                for(User* user in userArrayLocal){
                    user.city = cacheDictionary[user.cityId];
                }
            } completion:^(BOOL success, NSError *error) {
                if(!error){
                    [subscriber sendNext:userArrayLocal];
                    [subscriber sendCompleted];
                }
                else{
                    [subscriber sendError:error];
                }
            }];
            return nil;
        }] subscribeOn:[RACScheduler scheduler]];
    }];
}
@end
