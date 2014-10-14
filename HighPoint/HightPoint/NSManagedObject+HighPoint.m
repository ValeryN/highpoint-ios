//
// Created by Eugene on 07.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "NSManagedObject+HighPoint.h"


@implementation NSManagedObject (HighPoint)

- (id)moveToContext:(NSManagedObjectContext *)otherContext {
    //No transfer if context are equal
    if([otherContext isEqual:self.managedObjectContext])
        return self;

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

    NSError *error2 = nil;

    NSManagedObject *inContext = [otherContext existingObjectWithID:[self objectID] error:&error2];
    if (error2) {
#ifdef DEBUG
        @throw [NSException exceptionWithName:@"CoreData.error" reason:@"Error migration context" userInfo:@{@"error" : error}];
#endif
        NSLog(@"Error: %@", error.localizedDescription);
    }
    if(inContext.isFault){
        NSLog(@"Error: Fault after move context");
    }
    return inContext;

}
@end