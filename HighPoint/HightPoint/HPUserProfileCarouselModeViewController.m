//
// Created by Eugene on 22.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPUserProfileCarouselModeViewController.h"
#import "iCarousel.h"
#import "UIDevice+HighPoint.h"
#import "UIView+HighPoint.h"
#import "Photo.h"
#import "UIImageView+WebCache.h"

#import "HPMakeAvatarViewController.h"
#import "AssetsLibrary/AssetsLibrary.h"
#import "DataStorage.h"
#import "HPBaseNetworkManager+Photos.h"



@interface HPUserProfileCarouselModeViewController ()
@property(nonatomic, weak) IBOutlet iCarousel *carousel;
@property(nonatomic) BOOL fullScreenMode;
@property(nonatomic, weak) IBOutlet UIButton *setUserPicButton;
@property(nonatomic, weak) IBOutlet UIButton *deletePicButton;
@property(nonatomic, weak) IBOutlet UIButton *cancelDeleteButton;
@property(nonatomic, retain) NSMutableArray *deletedPhotoIndex;
@property(nonatomic, retain) NSNumber *userPicIndex;
@property(nonatomic, retain) RACSignal *selectedPhotoSignal;
@end


@implementation HPUserProfileCarouselModeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.deletedPhotoIndex = [NSMutableArray new];
    self.userPicIndex = @(2);
    [self configureCarouserView];
    [self configureNavigationBar];
    [self configureFullScreenMode];
    [self configureDeleteButton];
    [self configureSetUserPicButton];

    [self.carousel scrollToItemAtIndex:self.selectedPhoto animated:NO];

}

- (void)configureSetUserPicButton {
    RAC(self, setUserPicButton.hidden) = [[[RACSignal combineLatest:@[[[self isCurrentUserPicSignal] not], [self isPhotoDeletedSignal]]] and] not];
    [[self.setUserPicButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        
        HPMakeAvatarViewController *avaView = [[HPMakeAvatarViewController alloc] initWithNibName: @"HPMakeAvatarViewController" bundle: nil];
        NSLog(@"%d", self.carousel.currentItemIndex);
        
        avaView.doneCallback = ^(UIImage *editedImage, UIImageView *parentView, NSDictionary *param, BOOL canceled){
            if(editedImage && !canceled) {
                NSLog(@"Image ready");
                NSLog(@"%f", editedImage.size.height * [[param objectForKey:@"scale"] floatValue]);
                NSLog(@"%f", editedImage.size.width * [[param objectForKey:@"scale"] floatValue]);
                
                CGFloat x = [[param objectForKey:@"x"] floatValue];
                CGFloat y = [[param objectForKey:@"y"] floatValue];
                if(parentView.frame.origin.x < 0) {
                    x = parentView.frame.origin.x * -1 + x;
                } else {
                    x = x - parentView.frame.origin.x;
                }
                if(x < 0) x = 0;
                if(parentView.frame.origin.y < 0) {
                    y = parentView.frame.origin.y * -1 + y;
                } else {
                    y = y - parentView.frame.origin.y;
                }
                if(y < 0) y = 0;
                NSNumber *height = [NSNumber numberWithInt:(int) editedImage.size.height * [[param objectForKey:@"scale"] floatValue]];
                NSNumber *width = [NSNumber numberWithInt:(int) editedImage.size.width * [[param objectForKey:@"scale"] floatValue]];
                
                NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:height, @"height", width, @"width",[NSNumber numberWithInt:(int)x], @"left", [NSNumber numberWithInt:(int)y], @"top", nil];
                
                NSLog(@"x--> %f",x);
                NSLog(@"y--> %f",y);
                
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                [library writeImageToSavedPhotosAlbum:[editedImage CGImage]
                 
                                          orientation:(ALAssetOrientation)editedImage.imageOrientation
                                      completionBlock:^(NSURL *assetURL, NSError *error){
                                          if (error) {
                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Saving"
                                                                                              message:[error localizedDescription]
                                                                                             delegate:nil
                                                                                    cancelButtonTitle:@"Ok"
                                                                                    otherButtonTitles: nil];
                                              [alert show];
                                          }
                                      }];
                
            }
            else  NSLog(@"Ups...");
           
        };
        
        Photo *photo = [self.photosArray objectAtIndex:self.carousel.currentItemIndex];
        if([photo.photoId intValue] > 0) {
            
            NSString* avatarUrl = photo.imgeSrc;
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:[NSURL URLWithString:avatarUrl]
                                  options:0
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize)
             {
                 // progression tracking code
             }
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *url)
             {
                 if (image)
                 {
                     avaView.sourceImage = image;
                     //[avaView reset:YES];
                     //avaView.cImg = image;
                     self.navigationController.delegate = nil;
                     [self.navigationController pushViewController:avaView animated:YES];
                     
                     
                 }
             }];
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                @autoreleasepool {
                    
                    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
                    [assetsLibrary assetForURL:[NSURL URLWithString:photo.imgeSrc] resultBlock: ^(ALAsset *asset)   {
                        ALAssetRepresentation *representation = [asset defaultRepresentation];
                        CGImageRef imageRef = [representation fullResolutionImage];
                        if (imageRef) {
                            UIImage* image = [UIImage imageWithCGImage:imageRef
                                                                 scale:representation.scale
                                                           orientation:(UIImageOrientation) representation.orientation];
                            
                            dispatch_async(dispatch_get_main_queue(), ^(void) {
                                avaView.sourceImage = image;
                                [avaView reset:YES];
                                //avaView.cImg = image;
                                self.navigationController.delegate = nil;
                                [self.navigationController pushViewController:avaView animated:YES];
                            });
                        }
                    } failureBlock:^(NSError *error)    {
                        
                    }];
                }
            });
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //TODO: delete photos from database here
}

- (void)configureCarouserView {
    @weakify(self);
    RACSignal *carouselDidScroll = [[self rac_signalForSelector:@selector(carouselDidScroll:) fromProtocol:@protocol(iCarouselDelegate)] takeUntil:self.rac_willDeallocSignal];
    self.selectedPhotoSignal = [[[RACSignal return:@(self.carousel.currentItemIndex)] concat:[carouselDidScroll map:^id(id value) {
        @strongify(self);
        return @(self.carousel.currentItemIndex);
    }]] replayLast];

    [RACObserve(self, deletedPhotoIndex) subscribeNext:^(id x) {
        [self.carousel reloadData];
    }];
}

- (void)configureNavigationBar {
    @weakify(self);
    [[RACSignal combineLatest:@[self.selectedPhotoSignal, RACObserve(self, photosArray)]] subscribeNext:^(RACTuple *x) {
        @strongify(self);
        RACTupleUnpack(NSNumber *selectedIndex, NSArray *photosArray) = x;
        self.navigationItem.title = [NSString stringWithFormat:@"%d из %d", selectedIndex.intValue + 1, photosArray.count];
    }];
    self.navigationItem.leftBarButtonItem = [self leftBarButtonItem];
}

- (void)configureFullScreenMode {
    @weakify(self);
    [RACObserve(self, fullScreenMode) subscribeNext:^(NSNumber *fullScreenMode) {
        @strongify(self);
        [self.navigationController setNavigationBarHidden:fullScreenMode.boolValue animated:YES];
        [UIView animateWithDuration:0.3 animations:^{
            self.setUserPicButton.alpha = fullScreenMode.boolValue ? 0 : 1.0f;
            self.deletePicButton.alpha = fullScreenMode.boolValue ? 0 : 1.0f;
        }];
    }];
}

- (void)configureDeleteButton {
    @weakify(self);
    RACSignal *showDeleteFunctionSignal = [self isPhotoDeletedSignal];
    RACSignal *isCurrentUserPic = [self isCurrentUserPicSignal];

    RAC(self, deletePicButton.hidden) = [[[RACSignal combineLatest:@[[isCurrentUserPic not], showDeleteFunctionSignal]] and] not];
    RAC(self, cancelDeleteButton.hidden) = showDeleteFunctionSignal;

    [[[self.deletePicButton rac_signalForControlEvents:UIControlEventTouchUpInside] map:^id(id value) {
        @strongify(self);
        return @(self.carousel.currentItemIndex);
    }] subscribeNext:^(NSNumber *selectedPhoto) {
        @strongify(self);
        [self deletePhotoAtIndex:selectedPhoto];
    }];
    [[[self.cancelDeleteButton rac_signalForControlEvents:UIControlEventTouchUpInside] map:^id(id value) {
        @strongify(self);
        return @(self.carousel.currentItemIndex);
    }] subscribeNext:^(NSNumber *selectedPhoto) {
        @strongify(self);
        [self cancelDeletePhotoAtIndex:selectedPhoto];
    }];

}

- (RACSignal *)isCurrentUserPicSignal {
    RACSignal *isCurrentUserPic = [[RACSignal combineLatest:@[self.selectedPhotoSignal, RACObserve(self, userPicIndex)]] map:^id(RACTuple *value) {
        RACTupleUnpack(NSNumber *currentPhoto, NSNumber *userPicIndex) = value;
        return @([currentPhoto isEqualToNumber:userPicIndex ?: @(-1)]);
    }];
    return isCurrentUserPic;
}

- (RACSignal *)isPhotoDeletedSignal {
    RACSignal *showDeleteFunctionSignal = [[RACSignal combineLatest:@[self.selectedPhotoSignal, RACObserve(self, deletedPhotoIndex)]] map:^id(RACTuple *value) {
        RACTupleUnpack(NSNumber *selectedPhoto, NSArray *deletedArray) = value;
        return @(![deletedArray containsObject:selectedPhoto]);
    }];
    return showDeleteFunctionSignal;
}

- (UIBarButtonItem *)leftBarButtonItem {
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] init];
    if ([UIDevice hp_isIOS6]) {
        leftBarItem.image = [UIImage imageNamed:@"Back"];
    }
    else {
        leftBarItem.image = [[UIImage imageNamed:@"Back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    @weakify(self);
    leftBarItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        if(self.deletedPhotoIndex.count > 0)
            [self deleteSelectedPhotos];
        [self.navigationController popViewControllerAnimated:YES];
        return [RACSignal empty];
    }];
    return leftBarItem;
}
- (void) deleteSelectedPhotos {
    [[HPBaseNetworkManager sharedNetworkManager] createDeletedItemArray];
    for(NSNumber *index in self.deletedPhotoIndex) {
        Photo *photo = [self.photosArray objectAtIndex:[index intValue]];
        [[HPBaseNetworkManager sharedNetworkManager] addDeletedItemToArray:[photo.photoId intValue]];
    }
    //start delete chain
    Photo *photo = [self.photosArray firstObject];
    [[HPBaseNetworkManager sharedNetworkManager] deletePhotoRequest:photo.photoId];
}
#pragma mark Carousel delegate

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return _photosArray.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    if ([self.deletedPhotoIndex containsObject:@(index)]) {
        return [self deletedImageCellView];
    }
    else {
        return [self imageViewForCellIndex:index];
    }
}

- (UIView *)imageViewForCellIndex:(NSUInteger)index {
    UIImageView *view = [[UIImageView alloc] init];
    Photo *photo = [self.photosArray objectAtIndex:index];
    if([photo.photoId intValue] > 0) {
        
        [view sd_setImageWithURL:[NSURL URLWithString:photo.imgeSrc]
                placeholderImage:nil];
        CGRect rect = CGRectMake([UIScreen mainScreen].bounds.size.width, 0, 320.0, 200);
        view.contentMode = UIViewContentModeScaleAspectFill;
        view.clipsToBounds = YES;
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        view.frame = rect;
        
        
    } else {
        
        CGRect rect = CGRectMake(0, 0, 320.0, 200);
        view.contentMode = UIViewContentModeScaleAspectFill;
        view.clipsToBounds = YES;
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        view.frame = rect;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            @autoreleasepool {
                
                ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
                [assetsLibrary assetForURL:[NSURL URLWithString:photo.imgeSrc] resultBlock: ^(ALAsset *asset)   {
                    ALAssetRepresentation *representation = [asset defaultRepresentation];
                    CGImageRef imageRef = [representation fullResolutionImage];
                    if (imageRef) {
                        UIImage* image = [UIImage imageWithCGImage:imageRef
                                                             scale:representation.scale
                                                       orientation:(UIImageOrientation) representation.orientation];
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            view.image = image;
                            
                        });
                    }
                } failureBlock:^(NSError *error)    {
                    
                }];
            }
        });
        
    }
return view;
}

- (UIView *)deletedImageCellView {
    return [UIView viewWithNibName:@"HPUserProfileCarouselDeletedCellView"];
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    self.fullScreenMode = !self.fullScreenMode;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    switch (option) {
        case iCarouselOptionFadeMin:
            return -1;
        case iCarouselOptionFadeMax:
            return 1;
        case iCarouselOptionFadeRange:
            return 2.0;
        case iCarouselOptionCount:
            return 10;
        case iCarouselOptionSpacing:
            return value * 1.3f;
        default:
            return value;
    }
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel {
    return 320;
}

#pragma mark manage array with KVO
- (void)deletePhotoAtIndex:(NSNumber *)number {
    NSMutableArray *contents = [self mutableArrayValueForKey:@keypath(self, deletedPhotoIndex)];
    [contents addObject:number];
}

- (void)cancelDeletePhotoAtIndex:(NSNumber *)number {
    NSMutableArray *contents = [self mutableArrayValueForKey:@keypath(self, deletedPhotoIndex)];
    [contents removeObject:number];
}


@end