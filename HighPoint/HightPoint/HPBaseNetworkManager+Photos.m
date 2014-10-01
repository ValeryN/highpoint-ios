//
//  HPBaseNetworkManager+Photos.m
//  HighPoint
//
//  Created by Andrey Anisimov on 11.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPBaseNetworkManager+Photos.h"
#import "URLs.h"
#import "Utils.h"
#import "Constants.h"
#import "AFNetworking.h"
#import "DataStorage.h"
#import "UserTokenUtils.h"
#import "NotificationsConstants.h"

@implementation HPBaseNetworkManager (Photos)
//TODO: /v201405/photos/add //kAddPhotoRequest
- (void) addPhotoRequest:(UIImage*) image {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:[NSString stringWithString:kAddPhotoRequest]];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    [[self requestOperationManager] POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData
                                    name:@"image"
                                fileName:@"name" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"UPLOAD PHOTO: --> %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if (operation.response.statusCode == 403) {
                NSNumber *errorCode = [jsonDict objectForKey:@"error"];
                if ([errorCode isEqualToValue:@8]) {
                    // show wrong file format error
                }
                if ([errorCode isEqualToValue:@9]) {
                    // show too large file error
                }
                if ([errorCode isEqualToValue:@10]) {
                    // show too small file error
                }
            } else {
                if(jsonDict) {
                    if([[[jsonDict objectForKey:@"data"] objectForKey:@"photo"] isKindOfClass:[NSDictionary class]]) {
                            [[DataStorage sharedDataStorage] createAndSavePhotoEntity:[[jsonDict objectForKey:@"data"] objectForKey:@"photo"]];
                    }
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}
- (void) deletePhotoRequest : (NSNumber *) photoId {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:[NSString stringWithFormat:kDeletePhotoRequest, [photoId stringValue]]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFHTTPRequestSerializer new];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"DELETE PHOTO: --> %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                if (operation.response.statusCode == 403) {
                    //access denied
                    return;
                }
                if (operation.response.statusCode == 404) {
                    //not found
                    return;
                }
                NSNumber *deletedId = [[jsonDict objectForKey:@"data"] objectForKey:@"id"];
                if (deletedId) {
                    //delete photo by id
                }
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

@end
