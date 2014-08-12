//
//  Contact.h
//  HighPoint
//
//  Created by Andrey Anisimov on 11.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Message, User;

@interface Contact : NSManagedObject

@property (nonatomic, retain) Message *lastmessage;
@property (nonatomic, retain) User *user;

@end
