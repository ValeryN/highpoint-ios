//
//  Place.h
//  HighPoint
//
//  Created by Andrey Anisimov on 02.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class City, User;

@interface Place : NSManagedObject

@property (nonatomic, retain) NSNumber * cityId;
@property (nonatomic, retain) NSNumber * id_;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) City *city;

@end
