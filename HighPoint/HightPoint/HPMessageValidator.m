//
// Created by Eugene on 10.09.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPMessageValidator.h"


@implementation HPMessageValidator

+ (BOOL)validateDictionary:(NSDictionary *)dictionary {
    if (![dictionary[@"id"] isKindOfClass:[NSNumber class]])
        return NO;
    if (![dictionary[@"createdAt"] isKindOfClass:[NSString class]])
        return NO;
    if (![dictionary[@"destinationId"] isKindOfClass:[NSNumber class]])
        return NO;
    if (![dictionary[@"readAt"] isKindOfClass:[NSString class]] && ![dictionary[@"readAt"] isKindOfClass:[NSNull class]] && dictionary[@"readAt"])
        return NO;
    if (![dictionary[@"sourceId"] isKindOfClass:[NSNumber class]])
        return NO;
    if (![dictionary[@"text"] isKindOfClass:[NSString class]])
        return NO;

    return dictionary != nil;
}

@end