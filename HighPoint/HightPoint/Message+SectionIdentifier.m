//
// Created by Eugen Antropov on 08/09/14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "Message+SectionIdentifier.h"


@implementation Message (SectionIdentifier)

- (NSString*) createdAtDaySection{
    [self willAccessValueForKey:@"createdAtDaySection"];
    NSString *tmp = [self primitiveValueForKey: @"createdAtDaySection"];
    [self didAccessValueForKey:@"createdAtDaySection"];

    if (!tmp)
    {
        tmp = [Message createdAtSectionIdentifierGenerateFromDate:self.createdAt];
        [self willChangeValueForKey: @"createdAtDaySection"];
        [self setPrimitiveValue:tmp  forKey: @"createdAtDaySection"];
        [self didChangeValueForKey: @"createdAtDaySection"];
    }
    return tmp;
}

- (void) setCreatedAt: (NSDate*) createdAt
{
    [self willChangeValueForKey: @"createdAt"];
    [self setPrimitiveValue: createdAt forKey: @"createdAt"];
    [self didChangeValueForKey: @"createdAt"];
    self.createdAtDaySection = [Message createdAtSectionIdentifierGenerateFromDate:createdAt];
}

+ (NSString *) createdAtSectionIdentifierGenerateFromDate:(NSDate*) date{
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    return  [dateFormatter stringFromDate: date];
}

@end