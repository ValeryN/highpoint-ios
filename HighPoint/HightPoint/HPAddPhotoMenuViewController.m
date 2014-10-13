//
//  HPAddPhotoMenuViewController.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 14.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPAddPhotoMenuViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "AssetsLibrary/AssetsLibrary.h"
#import "UIButton+HighPoint.h"
#import "UIDevice+HighPoint.h"
#import "UIImage+HighPoint.h"

#define CONSTRAINT_TOP_FOR_CANCEL 433.0
#define CONSTRAINT_TOP_FOR_CHOOSE_PHOTO 378.0
#define CONSTRAINT_TOP_FOR_TAKE_PHOTO 330.0

@interface HPAddPhotoMenuViewController ()

@end

@implementation HPAddPhotoMenuViewController
{
    BOOL isCamera;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isCamera = NO;
    
    [self createGreenButton];
    [self fixUserConstraint];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setBgBlur];
}
- (void) fixUserConstraint
{
    self.cancelBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (![UIDevice hp_isWideScreen])
    {
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem: self.cancelBtn
                                                              attribute: NSLayoutAttributeTop
                                                              relatedBy: NSLayoutRelationEqual
                                                                 toItem: self.view
                                                              attribute: NSLayoutAttributeTop
                                                             multiplier: 1.0
                                                               constant: CONSTRAINT_TOP_FOR_CANCEL]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem: self.pickPhoto
                                                              attribute: NSLayoutAttributeTop
                                                              relatedBy: NSLayoutRelationEqual
                                                                 toItem: self.view
                                                              attribute: NSLayoutAttributeTop
                                                             multiplier: 1.0
                                                               constant: CONSTRAINT_TOP_FOR_CHOOSE_PHOTO]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem: self.takePhoto
                                                              attribute: NSLayoutAttributeTop
                                                              relatedBy: NSLayoutRelationEqual
                                                                 toItem: self.view
                                                              attribute: NSLayoutAttributeTop
                                                             multiplier: 1.0
                                                               constant: CONSTRAINT_TOP_FOR_TAKE_PHOTO]];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - blur for bg

- (void) setBgBlur {
    //self.view.opaque = NO;
    //Place the UIImage in a UIImageView
    self.backGroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.backGroundView.image = [self.screenShoot hp_applyBlurWithRadius:2];
    [self.view insertSubview:self.backGroundView atIndex:0];
    
    self.darkBgView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.darkBgView.backgroundColor = [UIColor colorWithRed:30.f / 255.f green:29.f / 255.f blue:48.f / 255.f alpha:0.9];
    [self.backGroundView addSubview:self.darkBgView];

}

- (void) hideView {
    [self.backGroundView removeFromSuperview];
    self.backGroundView = nil;
    [self.darkBgView removeFromSuperview];
    self.darkBgView = nil;
    if([self.delegate respondsToSelector:@selector(viewWillBeHidden:andIntPath:)]) {
        [self.delegate viewWillBeHidden:nil andIntPath:nil];
        //animation support if need
    }
    //[self dismissViewControllerAnimated: YES
    //                         completion: nil];
}

#pragma mark - cancel
- (IBAction)cancelBtnTap:(id)sender {
    if([self.delegate respondsToSelector:@selector(closeMenu)]) {
        [self.delegate closeMenu];
    }
}


#pragma mark - setup green buttons
- (void) createGreenButton
{
    [self.takePhoto hp_tuneFontForGreenButton];
    self.takePhoto.titleLabel.text = NSLocalizedString(@"TAKE_PHOTO_BTN", nil);
    [self.pickPhoto hp_tuneFontForGreenButton];
    self.pickPhoto.titleLabel.text = NSLocalizedString(@"GET_FROM_PHOTO_LIBRARY_BTN", nil);
    self.cancelBtn.titleLabel.text = NSLocalizedString(@"CANCEL_BTN",nil);
    [self.cancelBtn hp_tuneFontForGreenButton];
}

- (IBAction)takePhotoBtnTap:(id)sender {
     isCamera = YES;
    [self showCameraControl];
}

- (IBAction)takeFromPhotoGalleryTap:(id)sender {
    isCamera = NO;
    [self showPhotoPickerController];
}


#pragma mark - image picker

- (void) showPhotoPickerController {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.delegate = self;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    });
    
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *currentImage;
    __block NSString *intUrl;
    if (isCamera) {
        currentImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        // Request to save the image to camera roll
        [library writeImageToSavedPhotosAlbum:[currentImage CGImage] orientation:(ALAssetOrientation)[currentImage imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
            if (error) {
                NSLog(@"Error: ImagePicker %@",error);
            } else {
                intUrl = [assetURL absoluteString];
            }
            isCamera = NO;
            [picker  dismissViewControllerAnimated:YES completion:^{
                if([self.delegate respondsToSelector:@selector(viewWillBeHidden:andIntPath:)])
                {
                    
                    [self.backGroundView removeFromSuperview];
                    self.backGroundView = nil;
                    if(currentImage && intUrl)
                        [self.delegate viewWillBeHidden:currentImage andIntPath:intUrl];
                    //animation support if need
                }

            }];
        }];
    } else {
        isCamera = NO;
        currentImage = [info valueForKey:UIImagePickerControllerOriginalImage];
        NSURL *path = [info valueForKey:UIImagePickerControllerReferenceURL];
        [picker dismissViewControllerAnimated:YES completion:^{
            [self.backGroundView removeFromSuperview];
            self.backGroundView = nil;
            if(currentImage && intUrl)
                [self.delegate viewWillBeHidden:currentImage andIntPath:intUrl];
            
        }];
    }
    
}

#pragma mark - photo save utils
- (NSString *)documentsPath:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

- (NSString *)getPresentDateTime{
    NSDateFormatter *dateTimeFormat = [[NSDateFormatter alloc] init];
    [dateTimeFormat setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    NSDate *now = [[NSDate alloc] init];
    NSString *theDateTime = [dateTimeFormat stringFromDate:now];
    dateTimeFormat = nil;
    now = nil;
    return theDateTime;
}


#pragma mark - load camera

- (void) showCameraControl {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray *media = [UIImagePickerController
                          availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
        
        if ([media containsObject:(NSString*)kUTTypeImage] == YES) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            //picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            [picker setMediaTypes:[NSArray arrayWithObject:(NSString *)kUTTypeImage]];
            
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:nil];
            //[picker release];
            
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unsupported!"
                                                            message:@"Camera does not support photo capturing."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unavailable!"
                                                        message:@"This device does not have a camera."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}



- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    UIAlertView *alert;
    if (error) {
        alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                           message:[error localizedDescription]
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
        [alert show];
    } 
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
