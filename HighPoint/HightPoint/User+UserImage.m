//
// Created by Eugene on 02.09.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "User+UserImage.h"
#import "Avatar.h"
#import "NSManagedObject+HighPoint.h"
#import "NSManagedObjectContext+HighPoint.h"
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"

#define IMAGE_NOT_DOWNLOADED @"transparentflower.png"
#define IMAGE_ERROR_DOWNLOAD @"error-256.png"

@implementation User (UserImage)

+ (NSOperationQueue *)af_sharedImageRequestOperationQueue {
    static NSOperationQueue *_af_sharedImageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _af_sharedImageRequestOperationQueue = [[NSOperationQueue alloc] init];
        _af_sharedImageRequestOperationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    });
    
    return _af_sharedImageRequestOperationQueue;
}


- (RACSignal *) userImageSignal
{
    User* userInContext = [self moveToContext:[NSManagedObjectContext threadContext]];
    NSString* avatarUrl = userInContext.avatar.originalImgSrc;
    NSURL * imageURL = [NSURL URLWithString:avatarUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageURL];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    return [[User getPlaceholderImage] takeUntilReplacement:[[User getAvatarFromCacheWithUrl:request] catchTo:[User getAvatarFromNetworkWithUrl:request]]];
}

+ (RACSignal*) getPlaceholderImage{
    return [RACSignal return:[UIImage imageNamed:IMAGE_NOT_DOWNLOADED]];
}

+ (RACSignal *) getAvatarFromCacheWithUrl:(NSURLRequest*)avatarRequest{
    return [[[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        
        UIImage* image = [[[UIImageView class] sharedImageCache] cachedImageForRequest:avatarRequest];
        if(image){
            [subscriber sendNext:image];
            [subscriber sendCompleted];
        }
        else{
            [subscriber sendError:[NSError errorWithDomain:@"afnetwimage.cache.notfound" code:404 userInfo:nil]];
        }
        return nil;
    }] subscribeOn:[RACScheduler scheduler]] deliverOn:[RACScheduler mainThreadScheduler]];
}

+ (RACSignal*) getAvatarFromNetworkWithUrl:(NSURLRequest*) avatarRequest{
    return [[[[[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        __block AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:avatarRequest];
        operation.responseSerializer = [AFImageResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [subscriber sendNext:responseObject];
            [subscriber sendCompleted];
            [[UIImageView sharedImageCache] cacheImage:responseObject forRequest:avatarRequest];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: Failed download avatar with url %@",avatarRequest.URL);
            [subscriber sendError:error];
        }];
        
        [[[self class] af_sharedImageRequestOperationQueue] addOperation:operation];
        
        return [RACDisposable disposableWithBlock:^{
            [operation cancel];
            operation = nil;
        }];
    }] retry:2] catchTo:[RACSignal return:[UIImage imageNamed:IMAGE_ERROR_DOWNLOAD]]] subscribeOn:[RACScheduler scheduler]] deliverOn:[RACScheduler mainThreadScheduler]];
}
@end