//
//  HPBaseNetworkManager.m
//  HightPoint
//
//  Created by Andrey Anisimov on 22.04.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPBaseNetworkManager.h"
#import "AFNetworking.h"
#import "AFNetworkReachabilityManager.h"
#import "SocketIOPacket.h"
#import "DataStorage.h"
#import "URLs.h"
#import "Utils.h"
#import "Constants.h"
static HPBaseNetworkManager *networkManager;
@interface HPBaseNetworkManager ()
@property (nonatomic,strong) SocketIO* socketIO;
@end


@implementation HPBaseNetworkManager

+ (HPBaseNetworkManager *) sharedNetworkManager {
    //networkManager = nil;
    @synchronized (self){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            networkManager = [[HPBaseNetworkManager alloc] init];
        });
        return networkManager;
    }
}
# pragma mark -
# pragma mark network status
- (void) startNetworkStatusMonitor {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}
- (void) setNetworkStatusMonitorCallback {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
    }];
    
}
# pragma mark -
# pragma mark http requests
- (void) makeAutorizationRequest:(NSDictionary*) param {
    NSString *url = nil;
    url = [NSString stringWithFormat:kAPIBaseURLString];
    url = [url stringByAppendingString:kSigninRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    
    [manager GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            }
        
        //NSMutableDictionary *parsedDictionary = [NSMutableDictionary new];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }];
}
- (void) makeRegistrationRequest:(NSDictionary*) param {
    NSString *url = nil;
    url = [NSString stringWithFormat:kAPIBaseURLString];
    url = [url stringByAppendingString:kRegistrationRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    
    [manager POST:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
        }
        //NSMutableDictionary *parsedDictionary = [NSMutableDictionary new];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}
- (void) getPointsRequest:(NSInteger) lastPoint {
    NSString *url = nil;
    url = [NSString stringWithFormat:kAPIBaseURLString];
    url = [url stringByAppendingString:kPointsRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    
    [manager GET:url parameters:[Utils getParameterForPointsRequest:lastPoint] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"POINTS -->: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                //[[DataStorage sharedDataStorage] createUserEntity:jsonDict];
                NSArray *poi = [[jsonDict objectForKey:@"data"] objectForKey:@"points"];
                for(NSDictionary *dict in poi) {
                    [[DataStorage sharedDataStorage] createPoint:dict];
                }
            }
            else NSLog(@"Error, no valid data");
            
        }
        
        //NSMutableDictionary *parsedDictionary = [NSMutableDictionary new];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }];

}
- (void) getGeoLocation:(NSDictionary*) param {
    //
    NSString *url = nil;
    url = [NSString stringWithFormat:kAPIBaseURLString];
    url = [url stringByAppendingString:kGeoLocationRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"USERS -->: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                //[[DataStorage sharedDataStorage] createUserEntity:jsonDict];
                NSArray *cities = [jsonDict objectForKey: @"cities"];
                NSArray *countries = [jsonDict objectForKey:@"countries"];
                NSArray *regions = [jsonDict objectForKey:@"regions"];
                
            }
            else NSLog(@"Error, no valid data");
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }];
}
- (void) getUsersRequest:(NSInteger) lastUser {
    ///v201405/users
    NSString *url = nil;
    url = [NSString stringWithFormat:kAPIBaseURLString];
    url = [url stringByAppendingString:kUsersRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    
    [manager GET:url parameters:[Utils getParameterForUsersRequest:lastUser] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"USERS -->: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                //[[DataStorage sharedDataStorage] createUserEntity:jsonDict];
                NSArray *usr = [[jsonDict objectForKey:@"data"] objectForKey:@"users"];
                for(NSDictionary *dict in usr) {
                    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:[[dict objectForKey:@"cityId"] stringValue] , @"city_ids", nil];
                    [self getGeoLocation:param];
                    [[DataStorage sharedDataStorage] createUserEntity:dict isCurrent:NO];
                }
            }
            else NSLog(@"Error, no valid data");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }];
}

- (void) getCurrentUserRequest {
    NSString *url = nil;
    url = [NSString stringWithFormat:kAPIBaseURLString];
    url = [url stringByAppendingString:kCurrentUserRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict)
                [[DataStorage sharedDataStorage] createUserEntity: [[jsonDict objectForKey:@"data"] objectForKey:@"user"] isCurrent:YES];
            else NSLog(@"Error, no valid data");
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }];
}
- (void) findGeoLocation:(NSDictionary*) param {
    
}
- (void) getApplicationSettingsRequest {
    ///v201405/settings
    NSString *url = nil;
    url = [NSString stringWithFormat:kAPIBaseURLString];
    url = [url stringByAppendingString:kApplicationSettingsRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict)
                [[DataStorage sharedDataStorage] createApplicationSettingEntity:jsonDict];
            else NSLog(@"Error, no valid data");
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }];
}

- (void) getUserInfoRequest:(NSDictionary*) param {
   
}
- (void) getCurrentUserSettingsRequest:(NSDictionary*) param {
    
}
- (void) makeUpdateCurrentUserFilterSettingsRequest:(NSDictionary*) param {
    
}
- (void) getUsersListRequest:(NSDictionary*) param {
    
}
- (void) getPointsListRequest:(NSDictionary*) param {
    
}
- (void) makePointLikeRequest:(NSString*) pointId {
    
}
- (void) makePointUnLikeRequest:(NSString*) pointId {
    
}
# pragma mark -
# pragma mark socket io methods
//param - dict with keys host, port, user
- (void) initSocketIO:(NSDictionary*) param {
    _socketIO = [[SocketIO alloc] initWithDelegate:self];
    [_socketIO connectToHost:[param objectForKey:@"host"]  onPort:[[param objectForKey:@"port"] intValue]];
    [_socketIO sendEvent:@"join" withData:[param objectForKey:@"user"]];
}
- (void) sendMessage:(NSDictionary*) param {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"777",@"id",@"text message",@"body",@"333", @"destinationId", nil];
    [_socketIO sendEvent:kSendMessage withData:dict];
}
- (void) sendUserActivityStart:(NSDictionary*) param {
    if(_socketIO) {
         [_socketIO sendEvent:kActivityStart withData:param];
    }
}
- (void) sendUserActivityEnd:(NSDictionary*) param {
    if(_socketIO) {
        [_socketIO sendEvent:kActivityEnd withData:param];
    }
}
- (void) sendUserMessagesRead:(NSDictionary*) param {
    if(_socketIO) {
        [_socketIO sendEvent:kMessagesRead withData:param];
    }
}
- (void) sendUserTypingStart:(NSDictionary*) param {
    if(_socketIO) {
        [_socketIO sendEvent:kTypingStart withData:param];
    }
}
- (void) sendUserTypingFinish:(NSDictionary*) param {
    if(_socketIO) {
        [_socketIO sendEvent:kTypingFinish withData:param];
    }
}
- (void) sendUserNotificationRead:(NSDictionary*) param {
    if(_socketIO) {
        [_socketIO sendEvent:kNotificationRead withData:param];
    }
}
- (void) sendUserAllNotificationRead:(NSDictionary*) param {
    if(_socketIO) {
        [_socketIO sendEvent:kAllNotificationRead withData:param];
    }
}
# pragma mark -
# pragma mark socket.IO-objc delegate methods

- (void) socketIODidConnect:(SocketIO *)socket
{
    NSLog(@"socket.io connected.");
}
//receive event
- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    NSLog(@"didReceiveEvent()");
    NSLog(@"%@",packet.args);
    NSLog(@"%@",packet.name);
    //parsing incoming messages here
 
    if([packet.name isEqualToString:@"message"])
    {
        NSArray* args = packet.args;
        NSDictionary* arg = args[0];
        
    }
}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error
{
    NSLog(@"onError() %@", error);
}


- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    NSLog(@"socket.io disconnected. did error occur? %@", error);
}

@end
