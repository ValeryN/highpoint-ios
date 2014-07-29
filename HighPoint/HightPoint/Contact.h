//
//  Contact.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 29.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LastMessage, User;

@interface Contact : NSManagedObject

@property (nonatomic, retain) User *user;
@property (nonatomic, retain) LastMessage *lastmessage;

@end
