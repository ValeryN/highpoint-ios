//
// Created by Eugene on 10.09.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPRequest.h"
#import "City.h"
#import "User.h"

@class User;
@class Message;

@interface HPRequest (Users)
+ (RACSignal*) getMessagesForUser:(User*) user afterMessage:(Message*) message;
+ (RACSignal*) getUsersWithCity:(City*) city withGender:(UserGenderType) gender fromAge:(NSUInteger) fromAge toAge:(NSUInteger) toAge withPoint:(BOOL) withPoint afterUser:(User*) user;
@end