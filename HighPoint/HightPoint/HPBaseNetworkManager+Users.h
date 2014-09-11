//
//  HPBaseNetworkManager+Users.h
//  HighPoint
//
//  Created by Andrey Anisimov on 11.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPBaseNetworkManager.h"

@interface HPBaseNetworkManager (Users)
- (void) getUsersRequest:(NSInteger) lastUser;
- (void) getUserInfoRequest: (NSNumber *) userId;
- (void) getChatMsgsForUser : (NSNumber *) userId : (NSNumber *) afterMsgId;
- (void) sendMessageToUser : (NSNumber *) userId param: (NSDictionary *)param;
- (void) sendFewMessagesToUser : (NSNumber *) userId param: (NSArray *)param;
@end
