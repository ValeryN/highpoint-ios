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

#import "HPUserValidator.h"
#import "HPPointValidator.h"
#import "HPRequest+Private.h"


@implementation HPRequest (Users)

#pragma mark public
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

+ (RACSignal*) getUsersWithCity:(City*) city withGender:(UserGenderType) gender fromAge:(NSUInteger) fromAge toAge:(NSUInteger) toAge withPoint:(BOOL) withPoint afterUser:(User*) user{
    NSString *url = nil;
    url = [URLs getServerURL];
    if(withPoint){
        url = [url stringByAppendingString:kPointsRequest];
    }
    else{
        url = [url stringByAppendingString:kUsersRequest];
    }
    
    NSMutableDictionary *param = [@{
        @"minAge":@(fromAge),
        @"maxAge":@(toAge),
        @"genders":(gender==0)?@"1,2":@(gender),
        @"includePoints":@(YES)
        } mutableCopy];
    
    if(city){
        [param setValue:city.cityId forKey:@"cityIds"];
    }
    
    if(user){
        [param setValue:user.userId forKey:@"afterUserId"];
    }
    
    RACSignal *dataFromServer = [[self getDataFromServerWithUrl:url andParameters:param] replayLast];
    RACSignal *validatedUsersServerData = [self validateServerUsersArray:dataFromServer];
    RACSignal *savedUsersDataToDataBase = [self saveServerUsersArray:validatedUsersServerData];
    
    RACSignal *validatedPointsServerData = [self validateServerPointsArray:dataFromServer];
    RACSignal *savedPointsDataToDataBase = [self saveServerPointsArray:validatedPointsServerData];
    
    return [self mergeUserSignal:savedUsersDataToDataBase withPointsSingal:savedPointsDataToDataBase];
}

#pragma mark private

@end