//
//  HPPointLikesViewController.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 21.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@interface HPPointLikesViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate>
@property (nonatomic, retain) User* user;
@end
