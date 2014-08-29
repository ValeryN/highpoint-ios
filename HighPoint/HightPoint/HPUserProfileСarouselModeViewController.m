//
// Created by Eugene on 22.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPUserProfileСarouselModeViewController.h"
#import "iCarousel.h"
#import "UIDevice+HighPoint.h"

@interface HPUserProfileСarouselModeViewController()
@property (nonatomic, weak) IBOutlet iCarousel* carousel;
@property (nonatomic) BOOL fullScreenMode;
@property (nonatomic, weak) IBOutlet UIButton * setUserPicButton;
@property (nonatomic, weak) IBOutlet UIButton * deletePicButton;
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

    [RACObserve(self, fullScreenMode) subscribeNext:^(NSNumber * fullScreenMode) {
        @strongify(self);
        [self.navigationController setNavigationBarHidden:fullScreenMode.boolValue animated:YES];
        [UIView animateWithDuration:0.3 animations:^{
            self.setUserPicButton.alpha = fullScreenMode.boolValue?0:1.0f;
            self.deletePicButton.alpha = fullScreenMode.boolValue?0:1.0f;
        }];
    }];
    [self.carousel scrollToItemAtIndex:self.selectedPhoto animated:NO];
    self.navigationItem.leftBarButtonItem = [self leftBarButtonItem];
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
        [self.navigationController popViewControllerAnimated:NO];
        return [RACSignal empty];
    }];
    return leftBarItem;
}

#pragma mark Carousel delegate
- (NSUInteger)numberOfItemsInCarousel: (iCarousel*) carousel
{
    return _photosArray.count;
}

- (UIView*)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    view = [[UIImageView alloc] initWithImage:_photosArray[index]];
    CGRect rect = CGRectMake([UIScreen mainScreen].bounds.size.width, 0, 320.0, 200);

    view.contentMode = UIViewContentModeScaleAspectFill;
    view.clipsToBounds = YES;
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    view.frame = rect;
    return view;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
   self.fullScreenMode = !self.fullScreenMode;
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
            return value * 1.3f;
        default:
            return value;
    }
}

- (CGFloat)carouselItemWidth:(iCarousel*)carousel
{
    return 320;
}



@end