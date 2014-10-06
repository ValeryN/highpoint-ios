//
//  HPUserInfoPhotoAlbumViewController.h
//  HighPoint
//
//  Created by Eugene on 06/10/14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface HPUserInfoPhotoAlbumViewController : UIViewController <NSFetchedResultsControllerDelegate>
@property (nonatomic, retain) User* user;
@end
