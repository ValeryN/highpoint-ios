//
//  School.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 18.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Education;

@interface School : NSManagedObject

@property (nonatomic, retain) NSNumber * id_;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Education *education;

@end
