//
//  Message.h
//  HighPoint
//
//  Created by Andrey Anisimov on 11.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef NS_ENUM(NSUInteger, MessageStatus){
    MessageStatusUnknown = 0,
    MessageStatusSending = 1,
    MessageStatusSendFailed = 2,
    MessageStatusSent = 3,
    MessageStatusRead = 4
};

typedef NS_ENUM(NSUInteger, MessageType){
    MessageTypePlain = 0,
    MessageTypeOpenRequest = 1,
    MessageTypeOpenAllowResponse = 2,
    MessageTypeOpenDenyResponse = 3
};

@class Chat, Contact;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSNumber * messageType;
@property (nonatomic, retain) NSNumber * bindedUserId;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString* createdAtDaySection;
@property (nonatomic, retain) NSNumber * destinationId;
@property (nonatomic, retain) NSNumber * id_;
@property (nonatomic, retain) NSString * messageBody;
@property (nonatomic, retain) NSDate * readAt;
@property (nonatomic, retain) NSNumber * sourceId;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * lastMessage;
@property (nonatomic, retain) NSNumber * unreadMessage;
@property (nonatomic, retain) NSNumber * historyMessage;
@property (nonatomic, retain) NSNumber * notsendedMessage;
@property (nonatomic, retain) Chat *chat;
@property (nonatomic, retain) Contact *contact;
@property (nonatomic, retain) NSNumber* status;

@end
