//
// Created by Eugene on 01.09.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPRequest.h"

@class UserPoint;
@class User;

@interface HPRequest (Points)
+ (RACSignal *)getLikedUserOfPoint:(UserPoint *)point;
+ (RACSignal*) createPointWithText:(NSString*) text dueDate:(NSDate*) date forUser:(User*) user;
+ (RACSignal*) deletePoint:(UserPoint*) point;
@end