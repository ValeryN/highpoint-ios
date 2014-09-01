//
// Created by Eugene on 01.09.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPRequest+GeoLocations.h"
#import "URLs.h"
#import "Constants.h"
#import "DataStorage.h"
#import "HPCityValidator.h"


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

#pragma mark private

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
@end