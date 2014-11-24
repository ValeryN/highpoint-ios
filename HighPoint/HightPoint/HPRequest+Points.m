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
#import "HPRequest+Private.h"

@implementation HPRequest (Points)

#pragma mark public

+ (RACSignal*) createPointWithText:(NSString*) text dueDate:(NSDate*) date forUser:(User*) user{
    //TODO: Rewrite
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        __block  UserPoint* point;
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            point = [UserPoint MR_createInContext:localContext];
            point.pointId = @(1);
            point.pointCreatedAt = [NSDate date];
            point.pointText = text;
            point.user = [user MR_inContext:localContext];
            point.pointValidTo = date;            
        } completion:^(BOOL success, NSError *error) {
            [subscriber sendNext:[point MR_inContext:[NSManagedObjectContext MR_contextForCurrentThread]]];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

+ (RACSignal*) deletePoint:(UserPoint*) point{
    //TODO: Rewrite
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            UserPoint* pointToDelete = [point MR_inContext:localContext];
            [pointToDelete MR_deleteEntity];
        } completion:^(BOOL success, NSError *error) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

+ (RACSignal *)getLikedUserOfPoint:(UserPoint *)point {
    if(!point){
        return [RACSignal empty];
    }
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:[NSString stringWithFormat:kPointLikesRequest, point.pointId]];
    RACSignal *usersJsonArrayFromServer = [self getDataFromServerWithUrl:url andParameters:nil];
    RACSignal *validUsersJsonArrayFromServer = [self validateServerUsersArray:usersJsonArrayFromServer];
    RACSignal *savedUsersArray = [self saveServerUsersArray:validUsersJsonArrayFromServer];
    RACSignal *likedUsersArray = [self setUsersArray:savedUsersArray toLikePost:point];
    return likedUsersArray;
}

@end