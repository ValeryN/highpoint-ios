//
// Created by Eugene on 01.09.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPUserValidator.h"


@implementation HPUserValidator

+ (BOOL)validateDictionary:(NSDictionary *)dictionary {
    if (![dictionary[@"id"] isKindOfClass:[NSNumber class]])
        return NO;
    if (![dictionary[@"age"] isKindOfClass:[NSNumber class]] && ![dictionary[@"age"] isKindOfClass:[NSNull class]] && dictionary[@"age"])
        return NO;
    if (![dictionary[@"avatar"] isKindOfClass:[NSDictionary class]] && ![dictionary[@"avatar"] isKindOfClass:[NSNull class]] && dictionary[@"avatar"])
        return NO;
    if (![dictionary[@"career"] isKindOfClass:[NSArray class]] && ![dictionary[@"career"] isKindOfClass:[NSNull class]] && dictionary[@"career"])
        return NO;
    if (![dictionary[@"cityId"] isKindOfClass:[NSNumber class]])
        return NO;
    if (![dictionary[@"cityName"] isKindOfClass:[NSString class]] && ![dictionary[@"cityName"] isKindOfClass:[NSNull class]] && dictionary[@"cityName"])
        return NO;
    if (![dictionary[@"education"] isKindOfClass:[NSArray class]] && ![dictionary[@"education"] isKindOfClass:[NSNull class]] && dictionary[@"education"])
        return NO;
    if (![dictionary[@"email"] isKindOfClass:[NSString class]] && ![dictionary[@"email"] isKindOfClass:[NSNull class]] && dictionary[@"email"])
        return NO;
    if (![dictionary[@"favoriteCityIds"] isKindOfClass:[NSArray class]] && ![dictionary[@"favoriteCityIds"] isKindOfClass:[NSNull class]] && dictionary[@"favoriteCityIds"])
        return NO;
    if (![dictionary[@"favoritePlaceIds"] isKindOfClass:[NSArray class]] && ![dictionary[@"favoritePlaceIds"] isKindOfClass:[NSNull class]] && dictionary[@"favoritePlaceIds"])
        return NO;
    if (![dictionary[@"gender"] isKindOfClass:[NSNumber class]])
        return NO;
    if (![dictionary[@"languageIds"] isKindOfClass:[NSArray class]] && ![dictionary[@"languageIds"] isKindOfClass:[NSNull class]] && dictionary[@"languageIds"])
        return NO;
    if (![dictionary[@"maxEntertainmentPrice"] isKindOfClass:[NSDictionary class]] && ![dictionary[@"maxEntertainmentPrice"] isKindOfClass:[NSNull class]] && dictionary[@"maxEntertainmentPrice"])
        return NO;
    if (![dictionary[@"minEntertainmentPrice"] isKindOfClass:[NSDictionary class]] && ![dictionary[@"minEntertainmentPrice"] isKindOfClass:[NSNull class]] && dictionary[@"minEntertainmentPrice"])
        return NO;
    if (![dictionary[@"name"] isKindOfClass:[NSString class]])
        return NO;
    if (![dictionary[@"nameForms"] isKindOfClass:[NSArray class]] && ![dictionary[@"nameForms"] isKindOfClass:[NSNull class]] && dictionary[@"nameForms"])
        return NO;
    if (![dictionary[@"online"] isKindOfClass:[NSNumber class]] && ![dictionary[@"online"] isKindOfClass:[NSNull class]] && dictionary[@"online"])
        return NO;
    if (![dictionary[@"visibility"] isKindOfClass:[NSNumber class]])
        return NO;

    return dictionary != nil;
}

@end