//
//  UserPoint.h
//  HighPoint
//
//  Created by Andrey Anisimov on 26.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserPoint : NSManagedObject

@property (nonatomic, retain) NSString * pointCreatedAt;
@property (nonatomic, retain) NSNumber * pointId;
@property (nonatomic, retain) NSNumber * pointLiked;
@property (nonatomic, retain) NSString * pointText;
@property (nonatomic, retain) NSNumber * pointUserId;
@property (nonatomic, retain) NSString * pointValidTo;
@property (nonatomic, retain) NSSet*    likedBy;

@end
