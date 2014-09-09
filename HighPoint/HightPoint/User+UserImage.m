//
// Created by Eugene on 02.09.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "User+UserImage.h"
#import "SDWebImageManager.h"
#import "Avatar.h"
#import "NSManagedObject+HighPoint.h"
#import "NSManagedObjectContext+HighPoint.h"


@implementation User (UserImage)
- (RACSignal *) userImageSignal
{
    //return [RACSignal return:[UIImage imageNamed:@"img_sample1.png"]];
    User* userInContext = [self moveToContext:[NSManagedObjectContext threadContext]];
    NSString* avatarUrl = userInContext.avatar.originalImgSrc;
    SDWebImageOptions options = SDWebImageProgressiveDownload|SDWebImageRefreshCached;
    if(userInContext.isCurrentUser.boolValue) {
        options |= SDWebImageDownloaderHighPriority;
    }
    @weakify(self);
    return [[[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self);
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        manager.imageDownloader.maxConcurrentDownloads = 1;

        id <SDWebImageOperation> operation = [manager downloadWithURL:[NSURL URLWithString:avatarUrl]
                                                              options: SDWebImageRetryFailed
                                                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                                 NSLog(@"%d", receivedSize);
                                                             }
                                                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                                                
                                                                NSLog(@"%@", error.localizedDescription);
                                                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                    @strongify(self);
                                                                    if (image) {
                                                                        [subscriber sendNext:image];
                                                                        [subscriber sendCompleted];
                                                                    }
                                                                    else {
                                                                        NSLog(@"Failed download %@",avatarUrl);
                                                                        [subscriber sendError:error];
                                                                    }
                                                                });
                                                            }];
        return [RACDisposable disposableWithBlock:^{
            [operation cancel];
        }];
    }] retry:2] catchTo:[RACSignal empty]];
}
@end