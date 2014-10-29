//
// Created by Eugene on 01.09.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPRequest+GeoLocations.h"
#import "URLs.h"
#import "Constants.h"
#import "DataStorage.h"
#import "HPCityValidator.h"
#import "HPRequest+Private.h"

@implementation HPRequest (GeoLocations)

#pragma mark public

+ (RACSignal *)findCitiesWithSearchString:(NSString *)string {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kGeoLocationFindRequest];
    NSDictionary *param = @{@"query" : string, @"limit" : @20};

    RACSignal *dataFromServer = [self getDataFromServerWithUrl:url andParameters:param];

    RACSignal *validatedServerData = [self validateServerCityArray:dataFromServer];

    RACSignal *savedDataToDataBase = [self saveServerCityArray:validatedServerData];

    return savedDataToDataBase;
}

+ (RACSignal *)getCitiesById:(NSArray*) cities{
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kGeoLocationRequest];
    NSDictionary *param = @{@"cityIds" : [cities componentsJoinedByString:@","]};
    
    RACSignal *dataFromServer = [self getDataFromServerWithUrl:url andParameters:param];
    
    RACSignal *validatedServerData = [self validateServerCityArray:dataFromServer];
    
    RACSignal *savedDataToDataBase = [self saveServerCityArray:validatedServerData];
    
    return savedDataToDataBase;
}

@end