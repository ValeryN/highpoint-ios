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
#import "Avatar.h"
#import "HPChatViewController.h"
#import "Contact.h"

@interface HPUserInfoPhotoAlbumViewController ()
@property(nonatomic, weak) IBOutlet iCarousel *carousel;
@property(nonatomic, weak) IBOutlet UILabel* photoCountAndCurrentLabel;
@property(nonatomic, weak) IBOutlet UIButton* sendMessageButton;
@property(nonatomic, retain) RACSignal *selectedPhotoSignal;
@property(nonatomic) BOOL fullScreenMode;
@property(nonatomic, retain) NSFetchedResultsController* fetchedController;
@end

@implementation HPUserInfoPhotoAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self configureCarouserView];
    [self configureFullScreenMode];
    [self configureSendMessageButton];
}

- (void) configureSendMessageButton {
    [[self.sendMessageButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        HPChatViewController *chatController = [[HPChatViewController alloc] initWithNibName:@"HPChatViewController" bundle:nil];
        Contact* contact = [Contact MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"user = %@",self.user]];
        if(contact){
            chatController.contact = contact;
            [self.navigationController pushViewController:chatController animated:YES];
        }
        else{
            //TODO: how to add user as a contact (API)?
            [[[UIAlertView alloc] initWithTitle:@"Not implemented" message:@"Not implenented on server \"AddContact\"" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
        }
    }];
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
    
    RAC(self, photoCountAndCurrentLabel.text) = [[RACSignal combineLatest:@[RACObserve(self, fetchedController),self.selectedPhotoSignal]] map:^id(RACTuple* value) {
        RACTupleUnpack(NSFetchedResultsController* controller, NSNumber* currentImage) = value;
        id<NSFetchedResultsSectionInfo>  sectionInfo = controller.sections[0];
        int totalCounts = sectionInfo.numberOfObjects + 1;
        return [NSString stringWithFormat:@"%d из %d",currentImage.intValue + 1,totalCounts];
    }];
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
    return sectionInfo.numberOfObjects + 1;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    return [self imageViewForCellIndex:index];
}

- (UIView *)imageViewForCellIndex:(NSUInteger)index {
    UIImageView *view = [[UIImageView alloc] init];
    if(index > 0){
        NSIndexPath * path = [NSIndexPath indexPathForRow:index - 1 inSection:0];
        Photo* photo = [self.fetchedController objectAtIndexPath:path];
        [view sd_setImageWithURL:[NSURL URLWithString:photo.imgeSrc] placeholderImage:[UIImage imageNamed:@"transparentflower"]];
    }
    else{
        [view sd_setImageWithURL:[NSURL URLWithString:self.user.avatar.originalImgSrc] placeholderImage:[UIImage imageNamed:@"transparentflower"]];
    }
    
    CGRect rect = CGRectMake([UIScreen mainScreen].bounds.size.width, 0, self.view.frame.size.width,self.view.frame.size.height);
    
    view.contentMode = UIViewContentModeScaleAspectFit;
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
//FIXME:
- (CGFloat)carouselItemWidth:(iCarousel *)carousel {
    return 320;
}

@end
