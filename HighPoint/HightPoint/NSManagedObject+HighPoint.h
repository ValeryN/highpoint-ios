//
// Created by Eugene on 07.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSManagedObject (HighPoint)
- (id)moveToContext:(NSManagedObjectContext *)otherContext;
@end