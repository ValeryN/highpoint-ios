//
// Created by Eugene on 01.09.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPCityValidator.h"


@implementation HPCityValidator

+ (BOOL)validateDictionary:(NSDictionary *)dictionary {
    //Проверяем валидные поля каждого элемента и игнорируем все которые не валидны
    if (![dictionary[@"id"] isKindOfClass:[NSNumber class]])
        return NO;
    if (![dictionary[@"enName"] isKindOfClass:[NSString class]])
        return NO;
    if (![dictionary[@"name"] isKindOfClass:[NSString class]])
        return NO;
    if (![dictionary[@"nameForms"] isKindOfClass:[NSArray class]] && ![dictionary[@"nameForms"] isKindOfClass:[NSNull class]])
        return NO;
    if (![dictionary[@"regionId"] isKindOfClass:[NSNumber class]])
        return NO;

    return dictionary != nil;
}

@end