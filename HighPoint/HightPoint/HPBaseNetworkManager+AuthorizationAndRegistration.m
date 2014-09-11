//
//  HPBaseNetworkManager+AuthorizationAndRegistration.m
//  HighPoint
//
//  Created by Andrey Anisimov on 10.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPBaseNetworkManager+AuthorizationAndRegistration.h"
#import "URLs.h"
#import "Utils.h"
#import "Constants.h"
#import "AFNetworking.h"
#import "DataStorage.h"
#import "UserTokenUtils.h"
#import "NotificationsConstants.h"


@implementation HPBaseNetworkManager (AuthorizationAndRegistration)
#pragma mark - auth

- (void) makeAutorizationRequest:(NSDictionary*) param {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kSigninRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    //[self addTaskToArray:manager];
    
    NSLog(@"auth parameters = %@", param);
    [manager POST:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        //if([self isTaskArrayEmpty:manager]) {
        //    NSLog(@"Stop Queue");
        //}
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            [UserTokenUtils setUserToken:[[jsonDict objectForKey:@"data"] objectForKey:@"token"]];
            NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@1,@"status", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateAuthView object:nil userInfo:options];
        } else {
            NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@0,@"status", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateAuthView object:nil userInfo:options];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //if([self isTaskArrayEmpty:manager]) {
        //    NSLog(@"Stop Queue");
        //}
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@0,@"status", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateAuthView object:nil userInfo:options];
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];
        
    }];
}
#pragma mark - registration

- (void) makeRegistrationRequest:(NSDictionary*) param {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kRegistrationRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    
    [manager POST:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        // NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            //  NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        }
        //NSMutableDictionary *parsedDictionary = [NSMutableDictionary new];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];
    }];
}

@end
