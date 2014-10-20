//
//  HPBaseNetworkManager+Contacts.m
//  HighPoint
//
//  Created by Andrey Anisimov on 11.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPBaseNetworkManager+Contacts.h"
#import "HPBaseNetworkManager+Users.h"
#import "URLs.h"
#import "Utils.h"
#import "Constants.h"
#import "AFNetworking.h"
#import "DataStorage.h"
#import "UserTokenUtils.h"
#import "NotificationsConstants.h"

@implementation HPBaseNetworkManager (Contacts)
#pragma mark - contacts
- (void) getContactsRequest {
     NSLog(@"cont req");
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kGetContactsRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [self addTaskToArray:manager];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                NSArray *users = [[jsonDict objectForKey:@"data"] objectForKey:@"users"];
                NSDictionary *lastMsgs = [[jsonDict objectForKey:@"data"] objectForKey:@"messages"];
                
                [[DataStorage sharedDataStorage] createAndSaveUserEntity:[NSMutableArray arrayWithArray:users] forUserType:ContactUserType withComplation:^(NSError *error) {
                    if(!error) {
                        if ([self isTaskArrayEmpty:manager]) {
                            [self makeTownByIdRequest];
                        }
                        for (id key in [lastMsgs allKeys]) {
                            User *user = [[DataStorage sharedDataStorage] getUserForId:[NSNumber numberWithInt:[key intValue]]];
                            
                            [[DataStorage sharedDataStorage] createAndSaveMessage:[lastMsgs objectForKey:key] forUserId:user.userId andMessageType:LastMessageType withComplation:^(Message *lastMsg) {
                                [[DataStorage sharedDataStorage] createAndSaveContactEntity:user forMessage:lastMsg withComplation:^(id object) {
                                    //[self getChatMsgsForUser:user.userId :nil];
                                }];
                            }];
                        }
                    }
                }];
            }
            else {
                NSLog(@"Error: no valid data");
                if ([self isTaskArrayEmpty:manager]) {
                    [self makeTownByIdRequest];
                }
                
            }
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if([self isTaskArrayEmpty:manager]) {
            [self makeTownByIdRequest];
        }
        NSLog(@"Error: %@", error.localizedDescription);
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //        [alert show];
        
    }];
}
- (void) deleteContactRequest : (NSNumber *)contactId {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:[NSString stringWithFormat:kContactDeleteRequest, [contactId stringValue]]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                if ([[jsonDict objectForKey:@"data"] objectForKey:@"id"]) {
                    [[DataStorage sharedDataStorage] deleteAndSaveContact:contactId];
                    [[DataStorage sharedDataStorage] deleteAndSaveChatByUserId:contactId];
                }
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
               // UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
              //  [alert show];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];
        
    }];
}

@end
