//
//  HPBaseNetworkManager.h
//  HightPoint
//
//  Created by Andrey Anisimov on 22.04.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketIO.h"
@class User;
@class AFHTTPRequestOperationManager;

typedef enum {
    HistoryMessageType = 1,
    LastMessageType,
    UnreadMessageType,
    NotSendedMessageType
} MessageTypes;

@interface HPBaseNetworkManager : NSObject <SocketIODelegate>
+ (HPBaseNetworkManager*) sharedNetworkManager;
- (void) createTaskArray;
- (void) deleteTaskArray;
- (void) addTaskToArray:(AFHTTPRequestOperationManager*) manager;
- (BOOL) isTaskArrayEmpty:(AFHTTPRequestOperationManager*) manager;
- (NSNumber*) getFirstIndexIntoDeletedArray;

- (void) createDeletedItemArray;
- (void) deleteDeletedItemArray;
- (void) addDeletedItemToArray:(NSInteger) index;
- (void) deleteDeletedItemFromArray:(NSInteger) index;
- (BOOL) isDeletedItemArrayEmpty;

- (void) makeTownByIdRequest;
- (void) startNetworkStatusMonitor;
- (void) setNetworkStatusMonitorCallback;
- (void) initSocketIO:(NSDictionary*) param;
- (void) sendMessage:(NSDictionary*) param;
- (void) sendUserActivityStart:(NSDictionary*) param;
- (void) sendUserActivityEnd:(NSDictionary*) param;
- (void) sendUserMessagesRead:(NSDictionary*) param;
- (void) sendUserTypingStart:(NSDictionary*) param;
- (void) sendUserTypingFinish:(NSDictionary*) param;
- (void) sendUserNotificationRead:(NSDictionary*) param;
- (void) sendUserAllNotificationRead:(NSDictionary*) param;
- (AFHTTPRequestOperationManager*) requestOperationManager;



@end
