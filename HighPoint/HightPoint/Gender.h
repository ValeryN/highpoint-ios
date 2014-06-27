//
//  Gender.h
//  HighPoint
//
//  Created by Andrey Anisimov on 26.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserFilter;

@interface Gender : NSManagedObject

@property (nonatomic, retain) NSNumber * genderType;
@property (nonatomic, retain) UserFilter *userfilter;

@end
