//
//  HPPointValidator.m
//  HighPoint
//
//  Created by Eugene on 28/10/14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPPointValidator.h"

@implementation HPPointValidator
+ (BOOL)validateDictionary:(NSDictionary *)dictionary {
    if (![dictionary[@"id"] isKindOfClass:[NSNumber class]])
        return NO;
    if (![dictionary[@"createdAt"] isKindOfClass:[NSString class]])
        return NO;
    if (![dictionary[@"liked"] isKindOfClass:[NSNumber class]])
        return NO;
    if (![dictionary[@"userId"] isKindOfClass:[NSString class]] )
        return NO;
    if (![dictionary[@"validTo"] isKindOfClass:[NSString class]])
        return NO;
    if (![dictionary[@"text"] isKindOfClass:[NSString class]])
        return NO;
    
    return dictionary != nil;
}
@end
