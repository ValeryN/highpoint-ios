//
// Created by Eugene on 07.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "NSManagedObjectContext+HighPoint.h"
#import "HPAppDelegate.h"

@implementation NSManagedObjectContext (HighPoint)

+ (NSManagedObjectContext *)threadContext {
    NSManagedObjectContext *mainContext = [((HPAppDelegate *) [UIApplication sharedApplication].delegate) managedObjectContext];
    if ([NSThread isMainThread]) {
        return mainContext;
    }
    else {
        NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
        NSManagedObjectContext *threadContext = threadDict[@"NSManagedContextForThread"];
        if (threadContext == nil) {
            threadContext = [[self alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            [threadContext setParentContext:mainContext];
            [threadContext setMergePolicy:NSOverwriteMergePolicy];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(obtainPermanentIdForContextBeforeSave:)
                                                         name:NSManagedObjectContextWillSaveNotification
                                                       object:self];
            threadDict[@"NSManagedContextForThread"] = threadContext;
        }
        return threadContext;
    }
}

- (void)obtainPermanentIdForContextBeforeSave:(NSNotification *)notification {
    NSManagedObjectContext *context = [notification object];
    NSSet *insertedObjects = [context insertedObjects];

    if ([insertedObjects count]) {
        NSError *error = nil;
        BOOL success = [context obtainPermanentIDsForObjects:[insertedObjects allObjects] error:&error];
        if (!success) {
#ifdef DEBUG
            @throw [NSException exceptionWithName:@"CoreData.error" reason:@"Error migration context" userInfo:@{@"error" : error}];
#endif
        }
    }
}

- (void) saveWithErrorHandler {
    NSError *error = nil;
    [self save:&error];
    if (error) {
        NSLog(@"ERROR: saveContext: %@", error);
#ifdef DEBUG
        @throw [NSException exceptionWithName:@"CoreData.error" reason:@"Error save context" userInfo:@{@"error" : error}];
#endif
    }
}
@end