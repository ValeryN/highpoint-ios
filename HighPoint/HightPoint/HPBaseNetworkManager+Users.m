//
//  HPBaseNetworkManager+Users.m
//  HighPoint
//
//  Created by Andrey Anisimov on 11.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPBaseNetworkManager+Users.h"
#import "URLs.h"
#import "Utils.h"
#import "Constants.h"
#import "AFNetworking.h"
#import "DataStorage.h"
#import "UserTokenUtils.h"
#import "NotificationsConstants.h"

@implementation HPBaseNetworkManager (Users)
#pragma mark - users

- (void) getUsersRequest:(NSInteger) lastUser {
    ///v201405/users
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kUsersRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [self addTaskToArray:manager];
    [manager GET:url parameters:[Utils getParameterForUsersRequest:lastUser] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"USERS -->: %@", operation.responseString);
        NSLog(@"USERS");
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                if ([[jsonDict objectForKey:@"data"] isKindOfClass:[NSNull class]]) {
                    if([self isTaskArrayEmpty:manager]) {
                        NSLog(@"Stop Queue");
                    }
                    return;
                }
                NSDictionary *poi = [[jsonDict objectForKey:@"data"] objectForKey:@"points"];
                if (poi && (![poi isKindOfClass:[NSNull class]])) {
                    
                    NSMutableArray *arr = [NSMutableArray new];
                    for (NSString* key in [poi allKeys]) {
                        NSDictionary *point = [poi objectForKey:key];
                        [arr addObject:point];
                    }
                    [[DataStorage sharedDataStorage] createAndSavePoint:arr withComplation:^(NSError *error) {
                        if(!error) {
                            NSArray *usr = [[jsonDict objectForKey:@"data"] objectForKey:@"users"];
                            if (usr && (![usr isKindOfClass:[NSNull class]])) {
                                [[DataStorage sharedDataStorage] createAndSaveUserEntity:[NSMutableArray arrayWithArray:usr] forUserType:MainListUserType withComplation:^(NSError *error) {
                                    if(!error) {
                                        if([self isTaskArrayEmpty:manager]) {
                                            NSLog(@"Stop Queue");
                                            [self makeTownByIdRequest];
                                        }
                                    }
                                }];
                            }
                        }
                    }];
                }
            }
            else NSLog(@"Error, no valid data");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self isTaskArrayEmpty:manager]) {
            NSLog(@"Stop Queue");
            [self makeTownByIdRequest];
        }
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];
        
    }];
}
#pragma mark - user info


- (void) getUserInfoRequest: (NSNumber *) userId {
    NSString *url = nil;
    NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys: userId, @"id", nil];
    url = [URLs getServerURL];
    url =  [url stringByAppendingString:[NSString stringWithFormat:kUserInfoRequest, [userId stringValue]]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [self addTaskToArray:manager];
    [manager GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"USER INFO REQUEST -->: %@", operation.responseString);
        NSLog(@"USER INFO");
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                //[[DataStorage sharedDataStorage] createAndSaveUserEntity:[[jsonDict objectForKey:@"data"] objectForKey:@"user"] forUserType:0 withComplation:nil];
                
            }
            else NSLog(@"Error, no valid data");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}
#pragma mark - chat

- (void) getChatMsgsForUser : (NSNumber *) userId : (NSNumber *) afterMsgId {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:[NSString stringWithFormat:kUserMessagesRequest, [userId stringValue]]];
    NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:afterMsgId, @"afterMessageId", nil];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    [manager GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // NSLog(@"GET USER MESSAGES RESP JSON: --> %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                
                NSArray *messages = [[jsonDict objectForKey:@"data"] objectForKey:@"messages"];
                if (messages && (![messages isKindOfClass:[NSNull class]])) {
                    User *user = [[DataStorage sharedDataStorage] getUserForId:userId];
                    [[DataStorage sharedDataStorage] createAndSaveChatEntity:user withMessages:messages withComplation:^(id object) {
                        
                    }];
                }
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateChatView object:self userInfo:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //        [alert show];
        
    }];
}
#pragma mark - messages
- (void) sendMessageToUser : (NSNumber *) userId param: (NSDictionary *)param {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:[NSString stringWithFormat:kSendMessageToUserRequest, [userId stringValue]]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    [manager POST:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"SEND MESSAGE RESP JSON: --> %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                NSDictionary *msg = [[jsonDict objectForKey:@"data"] objectForKey:@"message"];
                if (msg) {
                    [[DataStorage sharedDataStorage] createAndSaveMessage:msg forUserId:userId andMessageType:HistoryMessageType withComplation:^(id object) {
                        
                    }];
                }
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
                //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //[alert show];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];
        
    }];
}
- (void) sendFewMessagesToUser : (NSNumber *) userId param: (NSArray *)param {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:[NSString stringWithFormat:kSendMessagesToUserRequest, [userId stringValue]]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:param,@"data", nil];
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"SEND MESSAGE RESP JSON: --> %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                NSArray *msgs = [[jsonDict objectForKey:@"data"] objectForKey:@"messages"];
                for (NSDictionary *msg in msgs) {
                    [[DataStorage sharedDataStorage] createAndSaveMessage:msg forUserId:userId andMessageType:HistoryMessageType withComplation:^(id object){
                        
                    }];
                    
                }
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
                //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //[alert show];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];
        
    }];
}

@end
