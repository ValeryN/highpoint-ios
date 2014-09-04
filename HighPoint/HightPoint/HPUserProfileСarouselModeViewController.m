//
// Created by Eugene on 22.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPUserProfileСarouselModeViewController.h"
#import "iCarousel.h"
#import "UIDevice+HighPoint.h"
#import "UIView+HighPoint.h"

@interface HPUserProfileСarouselModeViewController ()
@property(nonatomic, weak) IBOutlet iCarousel *carousel;
@property(nonatomic) BOOL fullScreenMode;
@property(nonatomic, weak) IBOutlet UIButton *setUserPicButton;
@property(nonatomic, weak) IBOutlet UIButton *deletePicButton;
@property(nonatomic, weak) IBOutlet UIButton *cancelDeleteButton;
@property(nonatomic, retain) NSMutableArray *deletedPhotoIndex;
@property(nonatomic, retain) NSNumber *userPicIndex;
@property(nonatomic, retain) RACSignal *selectedPhotoSignal;
@end


@implementation HPUserProfileСarouselModeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.deletedPhotoIndex = [NSMutableArray new];
    self.userPicIndex = @(2);
    [self configureCarouserView];
    [self configureNavigationBar];
    [self configureFullScreenMode];
    [self configureDeleteButton];

    [self.carousel scrollToItemAtIndex:self.selectedPhoto animated:NO];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //TODO: delete photos from database here
}

- (void)configureCarouserView {
    @weakify(self);
    RACSignal *carouselDidScroll = [[self rac_signalForSelector:@selector(carouselDidScroll:) fromProtocol:@protocol(iCarouselDelegate)] takeUntil:self.rac_willDeallocSignal];
    self.selectedPhotoSignal = [[carouselDidScroll map:^id(id value) {
        @strongify(self);
        return @(self.carousel.currentItemIndex);
    }] replayLast];

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
    RACSignal *showDeleteFunctionSignal = [[RACSignal combineLatest:@[self.selectedPhotoSignal, RACObserve(self, deletedPhotoIndex)]] map:^id(RACTuple *value) {
        RACTupleUnpack(NSNumber *selectedPhoto, NSArray *deletedArray) = value;
        return @(![deletedArray containsObject:selectedPhoto]);
    }];
    RACSignal *isCurrentUserPic = [[RACSignal combineLatest:@[self.selectedPhotoSignal, RACObserve(self, userPicIndex)]] map:^id(RACTuple *value) {
        RACTupleUnpack(NSNumber *currentPhoto, NSNumber *userPicIndex) = value;
        return @([currentPhoto isEqualToNumber:userPicIndex ?: @(-1)]);
    }];
    RAC(self, setUserPicButton.hidden) = [[[RACSignal combineLatest:@[[isCurrentUserPic not], showDeleteFunctionSignal]] and] not];
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
        [self.navigationController popViewControllerAnimated:YES];
        return [RACSignal empty];
    }];
    return leftBarItem;
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
    UIView *view = [[UIImageView alloc] initWithImage:_photosArray[index]];
    CGRect rect = CGRectMake([UIScreen mainScreen].bounds.size.width, 0, 320.0, 200);

    view.contentMode = UIViewContentModeScaleAspectFill;
    view.clipsToBounds = YES;
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    view.frame = rect;

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

- (void)deletePhotoAtIndex:(NSNumber *)number {
    NSMutableArray *contents = [self mutableArrayValueForKey:@keypath(self, deletedPhotoIndex)];
    [contents addObject:number];
}

- (void)cancelDeletePhotoAtIndex:(NSNumber *)number {
    NSMutableArray *contents = [self mutableArrayValueForKey:@keypath(self, deletedPhotoIndex)];
    [contents removeObject:number];
}


@end