//
//  HPBaseNetworkManager+Geo.m
//  HighPoint
//
//  Created by Andrey Anisimov on 11.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPBaseNetworkManager+Geo.h"
#import "URLs.h"
#import "Utils.h"
#import "Constants.h"
#import "AFNetworking.h"
#import "DataStorage.h"
#import "UserTokenUtils.h"
#import "NotificationsConstants.h"

@implementation HPBaseNetworkManager (Geo)
- (void) getGeoLocation:(NSDictionary*) param  {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kGeoLocationRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    //[self addTaskToArray:manager];
    [manager GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"GEOLOCATION -->: %@", operation.responseString);
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
                if ([[jsonDict objectForKey:@"data"] isKindOfClass:[NSNull class]]) {
                    return;
                }
                NSArray *cities = [[jsonDict objectForKey:@"data"] objectForKey:@"cities"] ;
                for(NSDictionary *dict in cities) {
                    
                    [[DataStorage sharedDataStorage] createAndSaveCity:dict popular:NO withComplation:^(City *city) {
                        NSArray *users = [[DataStorage sharedDataStorage] getUsersForCityId: city.cityId];
                        
                        for(User *user in users) {
                            NSLog(@"user name city name %@ %@", user.name, city.cityName);
                            [[DataStorage sharedDataStorage] setAndSaveCityToUser:user.userId forCity:city];
                        }
                    }];
                    
                }
                
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNeedUpdateUsersListViews
                                                                                                     object:nil
                                                                                                   userInfo:nil]];
                
            }
            else NSLog(@"Error, no valid data");
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];
        
    }];
}
#pragma mark - popular cities

- (void) getPopularCitiesRequest {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kPopularCitiesRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"POPULAR CITIES: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            if (![[jsonDict objectForKey:@"data"] isKindOfClass:[NSNull class]]) {
                NSArray *cities = [[jsonDict objectForKey:@"data"] objectForKey:@"cities"] ;
                if (cities && (![cities isKindOfClass:[NSNull class]])) {
                    
                    for(NSDictionary *dict in cities) {
                        [[DataStorage sharedDataStorage] createAndSaveCity:dict popular:YES withComplation:^(id object) {
                            
                        }];
                    }
                }
            }
        } else {
            NSLog(@"Error, no valid data");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];
        
    }];
}
- (void) findGeoLocation:(NSDictionary*) param {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kGeoLocationFindRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"FIND GEO LOCATION JSON --> %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                
                NSArray *cities = [[jsonDict objectForKey:@"data"] objectForKey:@"cities"];
                NSMutableArray *citiesArr = [NSMutableArray new];
                
                for(NSDictionary *dict in cities) {
                    [[DataStorage sharedDataStorage] createAndSaveCity:dict popular:NO withComplation:^(City *city) {
                        [citiesArr addObject:city];
                    }];
                    
                }
                NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:citiesArr, @"cities", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateCitiesListView object:self userInfo:param];
                
                
            } else {
                NSLog(@"Error, no valid data");
            }
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];
        
    }];
}
- (void) getGeoLocationForPlaces:(NSDictionary*) param withBlock:(complationBlock)block {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kGeoLocationRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"GEOLOCATION -->: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                NSArray *cities = [[jsonDict objectForKey:@"data"] objectForKey:@"cities"] ;
                if (cities && (![cities isKindOfClass:[NSNull class]])) {
                    
                    for(NSDictionary *dict in cities) {
                        [[DataStorage sharedDataStorage] createAndSaveCity:dict popular:NO withComplation:^(City *city) {
                        }];
                    }
                }
                block (@"success");
            }
            else {NSLog(@"Error, no valid data");
                block(@"Error");
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];
        block(@"Error");
        
    }];
    
}

@end
