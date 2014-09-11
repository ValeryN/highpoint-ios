//
//  Photo.h
//  HighPoint
//
//  Created by Andrey Anisimov on 11.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Photo : NSManagedObject

@property (nonatomic, retain) NSNumber * photoId;
@property (nonatomic, retain) NSNumber * photoPosition;
@property (nonatomic, retain) NSString * photoTitle;
@property (nonatomic, retain) NSNumber * imgeHeight;
@property (nonatomic, retain) NSNumber * imgeWidth;
@property (nonatomic, retain) NSString * imgeSrc;
@property (nonatomic, retain) NSNumber * userId;

@end
