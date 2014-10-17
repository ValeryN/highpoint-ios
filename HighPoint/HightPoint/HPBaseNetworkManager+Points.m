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
    NSLog(@"points req");
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kPointsRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [self addTaskToArray:manager];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params addEntriesFromDictionary:[Utils getParameterForPointsRequest:lastPoint]];
    [params addEntriesFromDictionary:[Utils getFilterParamsForRequest]];
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                NSArray *poi = [[jsonDict objectForKey:@"data"] objectForKey:@"points"];
                if (poi && (![poi isKindOfClass:[NSNull class]])) {
                    
                    NSMutableArray *arr = [NSMutableArray new];
                    for(NSDictionary *dict in poi) {
                        [arr addObject:dict];
                    }//save points
                    [[DataStorage sharedDataStorage] createAndSavePoint:arr withComplation:^(NSError *error) {
                        if(!error) {
                            NSLog(@"stop save points");
                            NSDictionary *usr = [[jsonDict objectForKey:@"data"] objectForKey:@"users"];
                            if (usr && (![usr isKindOfClass:[NSNull class]])) {
                                
                                NSMutableArray *dataArray = [NSMutableArray new];
                                for(NSString *key in [usr allKeys]) {
                                    [dataArray addObject:[usr objectForKey:key]];
                                }//save users from points
                                [[DataStorage sharedDataStorage] createAndSaveUserEntity:dataArray forUserType:MainListUserType withComplation:^(NSError *error) {
                                    NSLog(@"stop save users");
                                    if(!error) {
                                        if([self isTaskArrayEmpty:manager]) {
                                            [self makeTownByIdRequest];
                                        }
                                        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNeedUpdateUsersListViews
                                                                                                                             object:nil
                                                                                                                           userInfo:nil]];
                                    }
                                }];
                            }
                        }
                    }];
                }
            }
            else {
                if([self isTaskArrayEmpty:manager]) {
                    [self makeTownByIdRequest];
                }
                NSLog(@"Error: no valid data");
            }
        }
        
        //NSMutableDictionary *parsedDictionary = [NSMutableDictionary new];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if([self isTaskArrayEmpty:manager]) {
            [self makeTownByIdRequest];
        }
        
        
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];
        
    }];
    
}
#pragma mark - get point likes

- (void) getPointLikesRequest: (NSNumber *) pointId {
     NSLog(@"point like req");
    NSString *url = nil;
    NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys: pointId, @"id", nil];
    url = [URLs getServerURL];
    url =  [url stringByAppendingString:[NSString stringWithFormat:kPointLikesRequest, [pointId stringValue]]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    //[self addTaskToArray:manager];
    [manager GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                NSArray *usr = [[jsonDict objectForKey:@"data"] objectForKey:@"users"];
                if (![usr isKindOfClass:[NSNull class]]) {
                    //NSMutableArray *dataArray = [NSMutableArray new];
                    //for(NSString *key in [usr allKeys]) {
                    //    [dataArray addObject:[usr objectForKey:key]];
                    //}
                    [[DataStorage sharedDataStorage] createAndSaveUserEntity:[NSMutableArray arrayWithArray:usr] forUserType:PointLikeUserType withComplation:^(NSError *error) {
                        if(!error) {
                            if([self isTaskArrayEmpty:manager]) {
                                [self makeTownByIdRequest];
                            }
                        }
                    }];
                }
            }
            else
                NSLog(@"Error: no valid data");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self isTaskArrayEmpty:manager]) {
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
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                if ([[jsonDict objectForKey:@"data"] objectForKey:@"success"]) {
                   // [[DataStorage sharedDataStorage] setAndSavePointLiked:pointId :YES];
                }
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
                [[DataStorage sharedDataStorage] setAndSavePointLiked:pointId isLiked:NO withComplationBlock:^(id object) {
                    if (!object) {
                        //TODO : error msg
                    }
                }];
                //TODO: show error
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        [[DataStorage sharedDataStorage] setAndSavePointLiked:pointId isLiked:NO withComplationBlock:^(id object) {
            if (!object) {
                //TODO : error msg
            }
        }];
        //TODO: show error
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
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                if ([[jsonDict objectForKey:@"data"] objectForKey:@"success"]) {
                   // [[DataStorage sharedDataStorage] setAndSavePointLiked:pointId :NO];

                }
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
                [[DataStorage sharedDataStorage] setAndSavePointLiked:pointId isLiked:YES withComplationBlock:^(id object) {
                    if (!object) {
                        //TODO : error msg
                    }
                }];
                //TODO: show error
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        [[DataStorage sharedDataStorage] setAndSavePointLiked:pointId isLiked:YES withComplationBlock:^(id object) {
            if (!object) {
                //TODO : error msg
            }
        }];
        //TODO: show error
        
    }];
}

@end
