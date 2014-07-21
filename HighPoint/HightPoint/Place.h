//
//  Place.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 18.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Place : NSManagedObject

@property (nonatomic, retain) NSNumber * id_;
@property (nonatomic, retain) NSNumber * cityId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) User *user;

@end
