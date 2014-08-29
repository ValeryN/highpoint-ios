//
// Created by Eugene on 22.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPUserProfileСarouselModeViewController.h"
#import "iCarousel.h"

@interface HPUserProfileСarouselModeViewController()
@property (nonatomic, weak) IBOutlet iCarousel* carousel;
@end


@implementation HPUserProfileСarouselModeViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    @weakify(self);
    RACSignal * carouselDidScroll = [[self rac_signalForSelector:@selector(carouselDidScroll:) fromProtocol:@protocol(iCarouselDelegate)] takeUntil:self.rac_willDeallocSignal];
    [[RACSignal combineLatest:@[carouselDidScroll,RACObserve(self,photosArray)]] subscribeNext:^(RACTuple * x) {
        @strongify(self);
        RACTupleUnpack(NSObject *offset,NSArray * photosArray) = x;
        self.navigationItem.title = [NSString stringWithFormat:@"%d из %d",self.carousel.currentItemIndex + 1, photosArray.count];
    }];

    [self.carousel scrollToItemAtIndex:self.selectedPhoto animated:NO];

}


- (NSUInteger)numberOfItemsInCarousel: (iCarousel*) carousel
{
    return _photosArray.count;
}

- (UIView*)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    view = [[UIImageView alloc] initWithImage: [_photosArray objectAtIndex:index]];
    CGRect rect = CGRectMake([UIScreen mainScreen].bounds.size.width, 0, 320.0, 200);

    view.contentMode = UIViewContentModeScaleAspectFill;
    view.clipsToBounds = YES;
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    view.frame = rect;
    return view;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    //self.tapState = !self.tapState;
    //if(self.tapState) {
    //    [self moveGreenButtonDown];
    //    [self movePhotoViewToLeft];
    //    [self hideTopBar];
    //} else {
    //    [self moveGreenButtonUp];
    //    [self movePhotoViewToRight];
    //    [self showTopBar];
    //}

 }
- (CGFloat)carousel: (iCarousel *)carousel valueForOption: (iCarouselOption)option withDefault:(CGFloat)value
{
    switch (option)
    {
        case iCarouselOptionFadeMin:
            return -1;
        case iCarouselOptionFadeMax:
            return 1;
        case iCarouselOptionFadeRange:
            return 2.0;
        case iCarouselOptionCount:
            return 10;
        case iCarouselOptionSpacing:
            return value * 1.3;
        default:
            return value;
    }
}

- (CGFloat)carouselItemWidth:(iCarousel*)carousel
{
    return 320;
}



@end