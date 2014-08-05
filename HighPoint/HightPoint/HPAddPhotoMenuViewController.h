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
- (void)viewWillBeHidden:(UIImage*) img;
@end

@interface HPAddPhotoMenuViewController : UIViewController <GreenButtonProtocol,UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (nonatomic, weak) id<HPAddPhotoMenuViewControllerDelegate> delegate;

@property (strong, nonatomic) UIImage *screenShoot;
@property (strong, nonatomic) UIImageView *backGroundView;

@property (weak, nonatomic) IBOutlet UIButton *takePhoto;
@property (weak, nonatomic) IBOutlet UIButton *pickPhoto;

@end
