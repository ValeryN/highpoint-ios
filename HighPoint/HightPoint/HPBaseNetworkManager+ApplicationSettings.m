//
//  HPBaseNetworkManager+ApplicationSettings.m
//  HighPoint
//
//  Created by Andrey Anisimov on 10.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPBaseNetworkManager+ApplicationSettings.h"
#import "URLs.h"
#import "Utils.h"
#import "Constants.h"
#import "AFNetworking.h"
#import "DataStorage.h"
@implementation HPBaseNetworkManager (ApplicationSettings)
- (void) getApplicationSettingsRequest {
    ///v201405/settings
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kApplicationSettingsRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict)
                [[DataStorage sharedDataStorage] createAndSaveApplicationSettingEntity:jsonDict];
            else
                NSLog(@"Error: no valid data");
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];
        
    }];
}
@end
