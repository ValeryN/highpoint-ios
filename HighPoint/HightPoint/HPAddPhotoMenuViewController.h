//
//  HPAddPhotoMenuViewController.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 14.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGreenButtonVC.h"

@interface HPAddPhotoMenuViewController : UIViewController <GreenButtonProtocol,UIGestureRecognizerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;


@end
