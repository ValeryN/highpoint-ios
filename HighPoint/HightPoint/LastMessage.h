//
//  LastMessage.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 29.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact;

@interface LastMessage : NSManagedObject

@property (nonatomic, retain) NSNumber * id_;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * destinationId;
@property (nonatomic, retain) NSDate * readAt;
@property (nonatomic, retain) NSNumber * sourceId;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) Contact *contact;

@end
