//
//  HPBaseNetworkManager+Messages.m
//  HighPoint
//
//  Created by Andrey Anisimov on 11.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPBaseNetworkManager+Messages.h"
#import "URLs.h"
#import "Utils.h"
#import "Constants.h"
#import "AFNetworking.h"
#import "DataStorage.h"
#import "UserTokenUtils.h"
#import "NotificationsConstants.h"

@implementation HPBaseNetworkManager (Messages)
#pragma mark - unread message
- (void) getUnreadMessageRequest {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kUnreadMessagesRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [self addTaskToArray:manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            
            NSArray *jsonArray = [[[NSJSONSerialization JSONObjectWithData:jsonData
                                                                   options:kNilOptions
                                                                     error:&error] objectForKey:@"data"] objectForKey:@"messages"];
            if ([jsonArray isKindOfClass:[NSNull class]]) {
                if([self isTaskArrayEmpty:manager]) {
                }
                return;
            }
            for (NSDictionary * msg in jsonArray) {
                [[DataStorage sharedDataStorage] createAndSaveMessage:msg forUserId:[msg objectForKey:@"sourceId"] andMessageType:UnreadMessageType withComplation:^(id object) {
                    
                }];
                
                
            }
            if(jsonArray) {
                if([self isTaskArrayEmpty:manager]) {
                    [self makeTownByIdRequest];
                }
            }
            else
                NSLog(@"Error: no valid data");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
    
}

@end
