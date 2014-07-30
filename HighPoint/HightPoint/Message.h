//
//  Message.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 30.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Chat;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * destinationId;
@property (nonatomic, retain) NSNumber * id_;
@property (nonatomic, retain) NSString * messageBody;
@property (nonatomic, retain) NSDate * readAt;
@property (nonatomic, retain) NSNumber * sourceId;
@property (nonatomic, retain) NSNumber * bindedUserId;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Chat *chat;

@end
