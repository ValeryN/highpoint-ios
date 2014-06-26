//
//  Region.h
//  HighPoint
//
//  Created by Andrey Anisimov on 26.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Region : NSManagedObject

@property (nonatomic, retain) NSNumber * regionId;
@property (nonatomic, retain) NSNumber * regionCountryId;
@property (nonatomic, retain) NSString * regionName;
@property (nonatomic, retain) NSString * regionEnName;
@property (nonatomic, retain) NSString * regionNameForms;

@end
