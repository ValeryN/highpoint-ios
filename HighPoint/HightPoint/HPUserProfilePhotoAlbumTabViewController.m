//
// Created by Eugene on 22.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPUserProfilePhotoAlbumTabViewController.h"
#import "HPImageCollectionViewCell.h"
#import "HPAddPhotoMenuViewController.h"
#import "Utils.h"
#import "UIImage+HighPoint.h"
#import "HPUserProfileСarouselModeViewController.h"
#import "DataStorage.h"
#import "Photo.h"
#import "SDWebImageManager.h"
#import "AssetsLibrary/AssetsLibrary.h"
#import "HPBaseNetworkManager+Photos.h"
#import "NotificationsConstants.h"
#import "User.h"

@interface HPUserProfilePhotoAlbumTabViewController()
@property (nonatomic, retain) NSMutableArray* photosArray;
@end

@implementation HPUserProfilePhotoAlbumTabViewController

static NSString *cellID = @"cellID";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerNib:[UINib nibWithNibName:@"HPImageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:cellID];

    [self reloadData];
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:kNeedUpdateUserPhotos object:nil];
}
- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNeedUpdateUserPhotos object:nil];
}
- (void) reloadData {
    NSArray *photos = [[DataStorage sharedDataStorage] getPhotoForUserId:self.user.userId];
    _photosArray = nil;
    _photosArray = [NSMutableArray arrayWithArray:photos];
    [self.collectionView reloadData];
}
#pragma mark - collection view
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(self.user.isCurrentUser.boolValue)
        return _photosArray.count+1;
    else
        return _photosArray.count;
}

- (CGFloat)sectionSpacingForCollectionView:(UICollectionView *)collectionView
{
    return 5.f;
}

- (CGFloat)minimumInteritemSpacingForCollectionView:(UICollectionView *)collectionView
{
    return 5.f;
}

- (CGFloat)minimumLineSpacingForCollectionView:(UICollectionView *)collectionView
{
    return 5.f;
}

- (UIEdgeInsets)insetsForCollectionView:(UICollectionView *)collectionView
{
    return UIEdgeInsetsMake(5.f, 0, 5.f, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForLargeItemsInSection:(NSInteger)section
{
    return RACollectionViewTripletLayoutStyleSquare; //same as default !
}

- (UIEdgeInsets)autoScrollTrigerEdgeInsets:(UICollectionView *)collectionView
{
    return UIEdgeInsetsMake(50.f, 0, 50.f, 0);

}

- (UIEdgeInsets)autoScrollTrigerPadding:(UICollectionView *)collectionView
{
    return UIEdgeInsetsMake(64.f, 0, 0, 0);

}

- (CGFloat)reorderingItemAlpha:(UICollectionView *)collectionview
{
    return .3f;
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    UIImage *image = _photosArray[(NSUInteger) fromIndexPath.item];
    [_photosArray removeObjectAtIndex:(NSUInteger) fromIndexPath.item];
    [_photosArray insertObject:image atIndex:(NSUInteger) toIndexPath.item];
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HPImageCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    [cell.imageView removeFromSuperview];
    cell.imageView.frame = cell.bounds;

    if(_photosArray.count - indexPath.row == 0) {
        cell.imageView.image = [UIImage imageNamed:@"Camera"];
        cell.imageView.contentMode = UIViewContentModeCenter;
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];

        cell.contentView.layer.borderWidth = 1.5;
        cell.contentView.layer.borderColor =  [UIColor colorWithRed:80.0f/255.0f green:227.0f/255.0f blue:194.0f/255.0f alpha:1].CGColor;

    } else {
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        Photo *photo = [self.photosArray objectAtIndex:indexPath.row];
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
                     
                     cell.imageView.image = image;
                     cell.contentView.layer.borderColor =  [UIColor clearColor].CGColor;
                     
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
                                cell.imageView.image = image;
                            });
                        }
                    } failureBlock:^(NSError *error)    {
                        
                    }];
                }
            });
        }
    }
    [cell addSubview:cell.imageView];
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(_photosArray.count - indexPath.row == 0) {
        [self addPhotoMenuShow];
    } else {
        HPUserProfileСarouselModeViewController* carouselViewController = [[HPUserProfileСarouselModeViewController alloc] initWithNibName:@"HPUserProfileСarouselModeViewController" bundle:nil];
        carouselViewController.photosArray = _photosArray;
        carouselViewController.selectedPhoto = indexPath.row;
        [self.navigationController pushViewController:carouselViewController animated:YES];
//        [self.carousel scrollToItemAtIndex:indexPath.row animated:NO];
//
//        [UIView transitionWithView:self.view
//                          duration:0.2
//                           options:UIViewAnimationOptionTransitionCrossDissolve //any animation
//                        animations:^ {
//                            self.carousel.hidden = NO;
//                            self.collectionView.hidden = YES;
//                            self.segmentControl.hidden = YES;
//                            self.downButton.hidden = YES;
//                            self.backButton.hidden = NO;
//                            self.barTitle.hidden = NO;
//                        }
//                        completion:^(BOOL finished){
//
//                        }];
//
//        self.barTitle.font = [UIFont fontWithName:@"FuturaPT-Light" size:18.0f];
//        self.barTitle.textColor = [UIColor whiteColor];
//        self.barTitle.text = [NSString stringWithFormat:@"%d из %d",self.carousel.currentItemIndex + 1, _photosArray.count - 1];
//
//        if(!self.greenButton && !self.tappedGreenButton) {
//            self.greenButton = [Utils getViewForGreenButtonForText:@"Сделать юзерпиком"  andTapped:NO];
//            self.tappedGreenButton = [Utils getViewForGreenButtonForText:@"Сделать юзерпиком"  andTapped:YES];
//            CGRect rect = self.greenButton.frame;
//            rect.origin.x = 17.0;
//            rect.origin.y = ScreenHeight - CONSTRAINT_GREENBUTTON_FROM_BOTTOM;
//            self.greenButton.frame = rect;
//            self.tappedGreenButton.frame = rect;
//
//
//            UIButton* newButton = [UIButton buttonWithType: UIButtonTypeCustom];
//            newButton.frame = rect;
//            [newButton addTarget: self
//                          action: @selector(makeAvatarTapDown)
//                forControlEvents: UIControlEventTouchDown];
//            [newButton addTarget: self
//                          action: @selector(makeAvatarTapUp)
//                forControlEvents: UIControlEventTouchUpInside];
//            self.tappedGreenButton.hidden = YES;
//            [self.view addSubview:self.greenButton];
//            [self.view addSubview:self.tappedGreenButton];
//            [self.view addSubview:newButton];
//
//            self.deletButton = [UIButton buttonWithType: UIButtonTypeCustom];
//            self.deletButton.frame = CGRectMake(CONSTRAINT_TRASHBUTTON_FROM_LEFT, ScreenHeight - CONSTRAINT_GREENBUTTON_FROM_BOTTOM, 32.0, 32.0);
//            [self.deletButton setBackgroundImage: [UIImage imageNamed:@"Trash"] forState: UIControlStateNormal];
//            [self.deletButton setBackgroundImage: [UIImage imageNamed:@"Trash Tap"] forState: UIControlStateHighlighted];
//            [self.deletButton addTarget: self
//                                 action: @selector(deleteImage)
//                       forControlEvents: UIControlEventTouchUpInside];
//            [self.view addSubview:self.deletButton];
//        }
//        //self.infoTableView.hidden = YES;
    }
}

- (void) addPhotoMenuShow {
    HPAddPhotoMenuViewController* addPhotoViewController = [[HPAddPhotoMenuViewController alloc] initWithNibName: @"HPAddPhotoMenuViewController" bundle: nil];
    addPhotoViewController.delegate = self;
    addPhotoViewController.screenShoot = [self selfScreenShot];
    [self presentViewController:addPhotoViewController animated:YES completion:nil];
}
- (void) viewWillBeHidden:(UIImage*) image andIntPath:(NSString *)path {
    //
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSNumber *fakeId = [NSNumber numberWithInt: (int) timeStamp * -1];
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:fakeId,@"id",[NSNumber numberWithFloat:image.size.width],@"imgwidth",[NSNumber numberWithFloat:image.size.height],@"imgheight",path, @"imgsrc", nil];
    [[DataStorage sharedDataStorage] createAndSaveIntPhotoEntity:param withComplation:^(id object) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self reloadData];
        [[HPBaseNetworkManager sharedNetworkManager] addPhotoRequest:image andPhotoId:fakeId];
    }];
}
- (void) closeMenu {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (UIImage*) selfScreenShot {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = [keyWindow frame];
    UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [keyWindow.layer renderInContext:context];
    UIImage *capturedScreen = [UIGraphicsGetImageFromCurrentImageContext() resizeImageToSize:(CGSize){rect.size.width/3, rect.size.height/3}];
    UIGraphicsEndImageContext();
    return capturedScreen;
}
@end