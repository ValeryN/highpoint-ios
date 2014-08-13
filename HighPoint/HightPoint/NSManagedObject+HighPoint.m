//
// Created by Eugene on 07.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "NSManagedObject+HighPoint.h"


@implementation NSManagedObject (HighPoint)

- (id)moveToContext:(NSManagedObjectContext *)otherContext {
    NSError *error = nil;
    if ([[self objectID] isTemporaryID]) {
        BOOL success = [[self managedObjectContext] obtainPermanentIDsForObjects:@[self] error:&error];
        if (!success) {
#ifdef DEBUG
            @throw [NSException exceptionWithName:@"CoreData.error" reason:@"Error migration context" userInfo:@{@"error" : error}];
#endif
            NSLog(@"Error: %@", error.localizedDescription);
            return nil;
        }
    }

    error = nil;

    NSManagedObject *inContext = [otherContext existingObjectWithID:[self objectID] error:&error];
    if (error) {
#ifdef DEBUG
        @throw [NSException exceptionWithName:@"CoreData.error" reason:@"Error migration context" userInfo:@{@"error" : error}];
#endif
        NSLog(@"Error: %@", error.localizedDescription);
    }
    if(inContext.isFault){
        NSLog(@"Fault");
    }
    return inContext;

}
@end