//
//  Chat.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 30.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Message, User;

@interface Chat : NSManagedObject

@property (nonatomic, retain) NSSet *message;
@property (nonatomic, retain) User *user;
@end

@interface Chat (CoreDataGeneratedAccessors)

- (void)addMessageObject:(Message *)value;
- (void)removeMessageObject:(Message *)value;
- (void)addMessage:(NSSet *)values;
- (void)removeMessage:(NSSet *)values;

@end
