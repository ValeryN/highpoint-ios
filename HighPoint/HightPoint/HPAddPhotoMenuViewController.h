//
//  HPAddPhotoMenuViewController.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 14.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGreenButtonVC.h"

@protocol  HPAddPhotoMenuViewControllerDelegate <NSObject>
- (void) viewWillBeHidden:(UIImage*) img andIntPath:(NSString*) path;
@end

@interface HPAddPhotoMenuViewController : UIViewController <UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>


@property (nonatomic, weak) id<HPAddPhotoMenuViewControllerDelegate> delegate;

@end
