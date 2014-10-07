//
//  HPUserInfoPhotoAlbumViewController.m
//  HighPoint
//
//  Created by Eugene on 06/10/14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPUserInfoPhotoAlbumViewController.h"
#import "iCarousel.h"
#import "Photo.h"
#import "UIImageView+HighlightedWebCache.h"
#import "UIImageView+WebCache.h"

@interface HPUserInfoPhotoAlbumViewController ()
@property(nonatomic, weak) IBOutlet iCarousel *carousel;
@property(nonatomic, retain) RACSignal *selectedPhotoSignal;
@property(nonatomic) BOOL fullScreenMode;
@property(nonatomic, retain) NSFetchedResultsController* fetchedController;
@end

@implementation HPUserInfoPhotoAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureCarouserView];
    [self configureFullScreenMode];
    
}


- (void)configureCarouserView {
    @weakify(self);
    [RACObserve(self, user) subscribeNext:^(User* user) {
        @strongify(self);
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"userId = %@",user.userId];
        self.fetchedController = [Photo MR_fetchAllSortedBy:@"photoPosition" ascending:YES withPredicate:predicate groupBy:nil delegate:self];
        [self.carousel reloadData];
    }];
    
    RACSignal *carouselDidScroll = [[self rac_signalForSelector:@selector(carouselDidScroll:) fromProtocol:@protocol(iCarouselDelegate)] takeUntil:self.rac_willDeallocSignal];
    self.selectedPhotoSignal = [[[RACSignal return:@(self.carousel.currentItemIndex)] concat:[carouselDidScroll map:^id(id value) {
        @strongify(self);
        return @(self.carousel.currentItemIndex);
    }]] replayLast];
    
}

- (void)configureFullScreenMode {
    @weakify(self);
    [RACObserve(self, fullScreenMode) subscribeNext:^(NSNumber *fullScreenMode) {
        @strongify(self);
        [self.navigationController setNavigationBarHidden:fullScreenMode.boolValue animated:YES];
    }];
}

#pragma mark Carousel delegate

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    id<NSFetchedResultsSectionInfo>  sectionInfo = self.fetchedController.sections[0];
    return sectionInfo.numberOfObjects;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    return [self imageViewForCellIndex:index];
}

- (UIView *)imageViewForCellIndex:(NSUInteger)index {
    NSIndexPath * path = [NSIndexPath indexPathForRow:index inSection:0];
    Photo* photo = [self.fetchedController objectAtIndexPath:path];
    UIImageView *view = [[UIImageView alloc] init];
    [view sd_setImageWithURL:[NSURL URLWithString:photo.imgeSrc] placeholderImage:[UIImage imageNamed:@"transparentflower"]];
    CGRect rect = CGRectMake([UIScreen mainScreen].bounds.size.width, 0, 320.0, 200);
    
    view.contentMode = UIViewContentModeScaleAspectFill;
    view.clipsToBounds = YES;
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    view.frame = rect;
    
    return view;
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

@end
