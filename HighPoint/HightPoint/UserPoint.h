//
//  UserPoint.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 05.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface UserPoint : NSManagedObject

@property (nonatomic, retain) NSDate * pointCreatedAt;
@property (nonatomic, retain) NSNumber * pointId;
@property (nonatomic, retain) NSNumber * pointLiked;
@property (nonatomic, retain) NSString * pointText;
@property (nonatomic, retain) NSNumber * pointUserId;
@property (nonatomic, retain) NSDate * pointValidTo;
@property (nonatomic, retain) NSSet *likedBy;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSNumber* userId;
@end

@interface UserPoint (CoreDataGeneratedAccessors)

- (void)addLikedByObject:(User *)value;
- (void)removeLikedByObject:(User *)value;
- (void)addLikedBy:(NSSet *)values;
- (void)removeLikedBy:(NSSet *)values;

@end
