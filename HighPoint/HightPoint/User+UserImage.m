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
    User* userInContext = [self moveToContext:[NSManagedObjectContext threadContext]];
    NSString* avatarUrl = userInContext.avatar.originalImageSrc;
    @weakify(self);
    return [[[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self);
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        id <SDWebImageOperation> operation = [manager downloadWithURL:[NSURL URLWithString:avatarUrl]
                                                              options:SDWebImageHighPriority
                                                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                             }
                                                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
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