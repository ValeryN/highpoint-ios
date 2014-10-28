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
#import "Avatar.h"
#import "HPChatViewController.h"
#import "Contact.h"
#import "DataStorage.h"
#import "HPRoundView.h"
#import "UIImageView+AFNetworking.h"

@interface HPUserInfoPhotoAlbumViewController ()
@property(nonatomic, weak) IBOutlet iCarousel *carousel;
@property(nonatomic, weak) IBOutlet HPRoundView* photosInfoView;
@property(nonatomic, weak) IBOutlet UILabel* photoCountAndCurrentLabel;
@property(nonatomic, weak) IBOutlet UIButton* sendMessageButton;
@property(nonatomic, weak) IBOutlet UIView* profileLockView;
@property(nonatomic, weak) IBOutlet UIImageView* lockStatusImage;
@property(nonatomic, weak) IBOutlet UILabel* lockStatusLabel;
@property(nonatomic, retain) RACSignal *selectedPhotoSignal;
@property(nonatomic, retain) RACSignal* userVisibilityStatus;
@property(nonatomic) BOOL fullScreenMode;
@property(nonatomic, retain) NSFetchedResultsController* fetchedController;
@end

@implementation HPUserInfoPhotoAlbumViewController

- (RACSignal*) userVisibilityStatus{
    if(!_userVisibilityStatus)
        _userVisibilityStatus = [RACObserve(self, user.visibility) replayLast];
    return _userVisibilityStatus;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self configureCarouserView];
    [self configureFullScreenMode];
    [self configureBottomInfoBlock];
    [self configureSendButton];
}

- (void) configureBottomInfoBlock
{
    @weakify(self);
    RAC(self,lockStatusImage.image) = [self.userVisibilityStatus map:^id(NSNumber* value) {
        switch ((UserVisibilityType)value.intValue) {
            case UserVisibilityVisible:
            case UserVisibilityRequestBlur:
                return [UIImage imageNamed:@"Eye Active"];
            case UserVisibilityRequestHidden:
                return [UIImage imageNamed:@"Lock Active"];
            case UserVisibilityBlur:
                return [UIImage imageNamed:@"Eye Active"];
            case UserVisibilityHidden:
                return [UIImage imageNamed:@"Lock Active"];
        }
    }];
    
    RAC(self,profileLockView.hidden) = [self.userVisibilityStatus map:^id(NSNumber* value) {
        switch ((UserVisibilityType)value.intValue) {
            case UserVisibilityVisible:
                return @(YES);
            case UserVisibilityRequestBlur:
            case UserVisibilityRequestHidden:
            case UserVisibilityBlur:
            case UserVisibilityHidden:
                return @(NO);
        }
    }];
    
    RAC(self,lockStatusLabel.text) = [[self.userVisibilityStatus map:^id(id value) {
        @strongify(self);
        return RACTuplePack(value, self.user.gender.intValue == UserGenderMale?@"его":@"её");
    }] map:^id(RACTuple* x) {
        RACTupleUnpack(NSNumber* value, NSString* handling) = x;
        switch ((UserVisibilityType)value.intValue) {
            case UserVisibilityVisible:
                return @"";
            case UserVisibilityRequestBlur:
                return [NSString stringWithFormat:@"Вы попросили открыть вам %@ имя и фотографии.",handling];
            case UserVisibilityRequestHidden:
                return [NSString stringWithFormat:@"Вы попросили открыть вам %@ профиль.",handling];
            case UserVisibilityBlur:
                return [NSString stringWithFormat:@"Вы можете попросить %@ открыть свое имя и фотографии.",handling];
            case UserVisibilityHidden:
                return [NSString stringWithFormat:@"Вы можете попросить %@ открыть свой профиль.",handling];
        }
    }];
}

- (void) configureSendButton {
    @weakify(self);
    RACSignal* canSendRequestToUserSingal = [[self.userVisibilityStatus map:^id(NSNumber* value) {
        switch ((UserVisibilityType)value.intValue) {
            case UserVisibilityVisible:
            case UserVisibilityRequestBlur:
            case UserVisibilityRequestHidden:
                return @(NO);
            case UserVisibilityBlur:
            case UserVisibilityHidden:
                return @(YES);
        }
    }] replayLast];
    
    [canSendRequestToUserSingal subscribeNext:^(NSNumber* x) {
        @strongify(self);
        [self.sendMessageButton setTitle:x.boolValue ? @"Открыть" : @"Написать ей" forState:UIControlStateNormal];
    }];
    
    [[[self.sendMessageButton rac_signalForControlEvents:UIControlEventTouchUpInside] map:^id(id value) {
        return canSendRequestToUserSingal.first;
    }] subscribeNext:^(NSNumber* buttonType) {
        @strongify(self);
        if(buttonType.boolValue){
            if(self.user.visibility.intValue == UserVisibilityBlur)
                [[DataStorage sharedDataStorage] updateAndSaveVisibility:UserVisibilityRequestBlur forUser:self.user];
            if(self.user.visibility.intValue == UserVisibilityHidden)
                [[DataStorage sharedDataStorage] updateAndSaveVisibility:UserVisibilityRequestHidden forUser:self.user];
        }
        else{
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
    
    [self.userVisibilityStatus subscribeNext:^(NSNumber* visibility) {
        @strongify(self);
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
    
    RAC(self, photosInfoView.hidden) = [self.userVisibilityStatus map:^(NSNumber* value) {
        switch ((UserVisibilityType)value.intValue) {
            case UserVisibilityVisible:
                return @(NO);
            case UserVisibilityRequestBlur:
            case UserVisibilityRequestHidden:
            case UserVisibilityBlur:
            case UserVisibilityHidden:
                return @(YES);
        }
    }];
}

- (void)configureFullScreenMode {
    @weakify(self);
    [[RACObserve(self, fullScreenMode) filter:^BOOL(id value) {
        @strongify(self);
        switch ((UserVisibilityType)((NSNumber*)self.userVisibilityStatus.first).intValue) {
            case UserVisibilityVisible:
                return YES;
            case UserVisibilityRequestBlur:
            case UserVisibilityRequestHidden:
            case UserVisibilityBlur:
            case UserVisibilityHidden:
                return NO;
        }
    }] subscribeNext:^(NSNumber *fullScreenMode) {
        @strongify(self);
        [self.navigationController setNavigationBarHidden:fullScreenMode.boolValue animated:YES];
    }];
}

#pragma mark Carousel delegate

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    @weakify(self);
    if([self.user.visibility isEqual: @(UserVisibilityVisible)]){
        @strongify(self);
        id<NSFetchedResultsSectionInfo>  sectionInfo = self.fetchedController.sections[0];
        return sectionInfo.numberOfObjects + 1;
    }
    else{
        return 1;
    }
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    return [self imageViewForCellIndex:index];
}

- (UIView *)imageViewForCellIndex:(NSUInteger)index {
    UIImageView *view = [[UIImageView alloc] init];
    if(index > 0){
        NSIndexPath * path = [NSIndexPath indexPathForRow:index - 1 inSection:0];
        Photo* photo = [self.fetchedController objectAtIndexPath:path];
        [view setImageWithURL:[NSURL URLWithString:photo.imgeSrc]  placeholderImage:[UIImage imageNamed:@"transparentflower"]];
    }
    else{
        [view setImageWithURL:[NSURL URLWithString:self.user.avatar.originalImgSrc]  placeholderImage:[UIImage imageNamed:@"transparentflower"]];
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
