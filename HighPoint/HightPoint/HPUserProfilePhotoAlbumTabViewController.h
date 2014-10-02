//
// Created by Eugene on 22.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RACollectionViewReorderableTripletLayout.h"
#import "HPAddPhotoMenuViewController.h"

@class User;


@interface HPUserProfilePhotoAlbumTabViewController : UIViewController <RACollectionViewDelegateReorderableTripletLayout, RACollectionViewReorderableTripletLayoutDataSource, HPAddPhotoMenuViewControllerDelegate>
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, retain) User* user;
@end