//
//  HPRequest+Private.h
//  HighPoint
//
//  Created by Eugene on 28/10/14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPRequest.h"
#import "UserPoint.h"

@interface HPRequest (Private)
//Requests
+ (RACSignal*)requestCitiesForUsersServerArray:(RACSignal*) signal;
//Validator
+ (RACSignal*)validateServerMessagesArray:(RACSignal *)signal;
+ (RACSignal*)validateServerPointsArray:(RACSignal *)signal;
+ (RACSignal*)validateServerUsersArray:(RACSignal *)signal;
+ (RACSignal*)validateServerCityArray:(RACSignal *)signal;
//Savers
+ (RACSignal*)mergeUserSignal:(RACSignal*) userSignal withCitySingal:(RACSignal*) citySignal;
+ (RACSignal*)mergeUserSignal:(RACSignal*) userSignal withPointsSingal:(RACSignal*) pointsSignal;
+ (RACSignal*)saveServerCityArray:(RACSignal *)signal;
+ (RACSignal*)saveServerUsersArray:(RACSignal *)signal;
+ (RACSignal*)setUsersArray:(RACSignal *)signal toLikePost:(UserPoint *)point;
+ (RACSignal*)saveServerMessagesArray:(RACSignal *)signal;
+ (RACSignal*)saveServerPointsArray:(RACSignal *) signal;
@end
