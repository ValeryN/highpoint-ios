//
//  HPBaseNetworkManager+Points.m
//  HighPoint
//
//  Created by Andrey Anisimov on 11.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPBaseNetworkManager+Points.h"
#import "URLs.h"
#import "Utils.h"
#import "Constants.h"
#import "AFNetworking.h"
#import "DataStorage.h"
#import "UserTokenUtils.h"
#import "NotificationsConstants.h"

@implementation HPBaseNetworkManager (Points)
#pragma mark - points

- (void) getPointsRequest:(NSInteger) lastPoint {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kPointsRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [self addTaskToArray:manager];
    [manager GET:url parameters:[Utils getParameterForPointsRequest:lastPoint] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"POINTS -->: %@", operation.responseString);
        NSLog(@"POINTS");
        //if([self isTaskArrayEmpty:manager]) {
        //    NSLog(@"Stop Queue");
        //}
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                NSArray *poi = [[jsonDict objectForKey:@"data"] objectForKey:@"points"];
                if (poi && (![poi isKindOfClass:[NSNull class]])) {
                    for(NSDictionary *dict in poi) {
                        [[DataStorage sharedDataStorage] createAndSavePoint:dict];
                    }
                }
                NSDictionary *usr = [[jsonDict objectForKey:@"data"] objectForKey:@"users"];
                if (usr && (![usr isKindOfClass:[NSNull class]])) {
                    for(NSString *key in usr) {
                        [[DataStorage sharedDataStorage] createAndSaveUserEntity:[usr objectForKey:key] forUserType:MainListUserType withComplation:nil];
                    }
                }
                
                if([self isTaskArrayEmpty:manager]) {
                    NSLog(@"Stop Queue");
                    [self makeTownByIdRequest];
                }
            }
            else NSLog(@"Error, no valid data");
        }
        
        //NSMutableDictionary *parsedDictionary = [NSMutableDictionary new];
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
#pragma mark - get point likes

- (void) getPointLikesRequest: (NSNumber *) pointId {
    NSString *url = nil;
    NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys: pointId, @"id", nil];
    url = [URLs getServerURL];
    url =  [url stringByAppendingString:[NSString stringWithFormat:kPointLikesRequest, [pointId stringValue]]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [self addTaskToArray:manager];
    [manager GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"POINT LIKES REQUEST -->: %@", operation.responseString);
        NSLog(@"POINT LIKES");
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                NSArray *usr = [[jsonDict objectForKey:@"data"] objectForKey:@"users"];
                if (![usr isKindOfClass:[NSNull class]]) {
                    for(NSDictionary *dict in usr) {
                        [[DataStorage sharedDataStorage] createAndSaveUserEntity:dict forUserType:PointLikeUserType withComplation:nil];
                    }
                }
                if([self isTaskArrayEmpty:manager]) {
                    NSLog(@"Stop Queue");
                    [self makeTownByIdRequest];
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
    }];
}
#pragma mark - point like/unlike

- (void) makePointLikeRequest:(NSNumber*) pointId {
    ///v201405/points/<id>/like
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:[NSString stringWithFormat:kPointsLikeRequest, [pointId stringValue]]];
    NSLog(@"url like = %@", url);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"POINT LIKE RESP JSON: --> %@", operation.responseString);
        NSLog(@"LIKE STATUS CODE --> %ld", (long)operation.response.statusCode);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                if ([[jsonDict objectForKey:@"data"] objectForKey:@"success"]) {
                    [[DataStorage sharedDataStorage] setAndSavePointLiked:pointId :YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdatePointLike object:self userInfo:nil];
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
- (void) makePointUnLikeRequest:(NSNumber*) pointId {
    ///v201405/points/<id>/like
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:[NSString stringWithFormat:kPointsUnlikeRequest, [pointId stringValue]]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"POINT UNLIKE RESP JSON: --> %@", operation.responseString);
        NSLog(@"UNLIKE HEADER --> %@", operation.description);
        
        
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                if ([[jsonDict objectForKey:@"data"] objectForKey:@"success"]) {
                    [[DataStorage sharedDataStorage] setAndSavePointLiked:pointId :NO];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdatePointLike object:self userInfo:nil];
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
