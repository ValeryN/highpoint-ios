//
//  AppSetting.h
//  HighPoint
//
//  Created by Andrey Anisimov on 26.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AppSetting : NSManagedObject

@property (nonatomic, retain) NSNumber * avatarMaxFileSize;
@property (nonatomic, retain) NSNumber * avatarMinImageHeight;
@property (nonatomic, retain) NSNumber * avatarMinImageWidth;
@property (nonatomic, retain) NSNumber * pointMaxPeriod;
@property (nonatomic, retain) NSNumber * pointMinPeriod;
@property (nonatomic, retain) NSString * webSoketUrl;

@end
