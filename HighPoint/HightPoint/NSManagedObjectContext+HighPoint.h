//
// Created by Eugene on 07.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSManagedObjectContext (HighPoint)
+ (NSManagedObjectContext *)threadContext;
- (void) saveWithErrorHandler;
@end