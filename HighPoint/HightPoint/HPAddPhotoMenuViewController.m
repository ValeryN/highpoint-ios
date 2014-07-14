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
   // [self setupBackgroundTap];
    isCamera = NO;
    [self setBgBlur];
    [self createGreenButton];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - blur for bg

- (void) setBgBlur {
    self.view.opaque = NO;
    self.view.backgroundColor = [UIColor clearColor];
    UIToolbar *fakeToolbar = [[UIToolbar alloc] initWithFrame:self.view.bounds];
    fakeToolbar.alpha = 0.9;
    fakeToolbar.autoresizingMask = self.view.autoresizingMask;
    fakeToolbar.barTintColor = [UIColor clearColor];
    [self.view insertSubview:fakeToolbar atIndex:0];
}


#pragma mark - background tap
- (void) setupBackgroundTap {
    self.bgImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]
                                     initWithTarget:self action:@selector(handleTap:)];
    tgr.delegate = self;
    [self.bgImageView addGestureRecognizer:tgr];
}

- (void)handleTap:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    [self hideView];
}


- (void) hideView {
    [self.view removeFromSuperview];
}

#pragma mark - cancel
- (IBAction)cancelBtnTap:(id)sender {
    [self hideView];
}


#pragma mark - setup green buttons
- (void) createGreenButton
{
    HPGreenButtonVC* pickFromPhohtoAlb = [[HPGreenButtonVC alloc] initWithNibNameAndTitle: @"HPGreenButtonVC" bundle: nil  title: NSLocalizedString(@"GET_FROM_PHOTO_LIBRARY_BTN", nil)];
    pickFromPhohtoAlb.tag = 0;
    pickFromPhohtoAlb.view.translatesAutoresizingMaskIntoConstraints = NO;
    pickFromPhohtoAlb.delegate = self;
    
    CGRect rect = pickFromPhohtoAlb.view.frame;
    CGRect bounds = [UIScreen mainScreen].bounds;
    rect.origin.x = (bounds.size.width - rect.size.width) / 2.0f ;
    rect.origin.y = bounds.size.height - rect.size.height - 150;
    pickFromPhohtoAlb.view.frame = rect;
    [self addChildViewController: pickFromPhohtoAlb];
    [self.view addSubview: pickFromPhohtoAlb.view];
    [self createGreenButtonsConstraint: pickFromPhohtoAlb];
    
    
    HPGreenButtonVC* getFromCamera = [[HPGreenButtonVC alloc] initWithNibNameAndTitle: @"HPGreenButtonVC" bundle: nil  title: NSLocalizedString(@"TAKE_PHOTO_BTN", nil)];
    
    getFromCamera.view.translatesAutoresizingMaskIntoConstraints = NO;
    getFromCamera.delegate = self;
    getFromCamera.tag = 1;
    rect = getFromCamera.view.frame;
    bounds = [UIScreen mainScreen].bounds;
    rect.origin.x = (bounds.size.width - rect.size.width) / 2.0f ;
    rect.origin.y = bounds.size.height - rect.size.height - 200;
    getFromCamera.view.frame = rect;
    [self addChildViewController: getFromCamera];
    [self.view addSubview: getFromCamera.view];
    [self createGreenButtonsConstraint: getFromCamera];
    
    
    self.cancelBtn.titleLabel.text = NSLocalizedString(@"CANCEL_BTN",nil);
    [self.cancelBtn hp_tuneFontForGreenButton];
}


- (void) createGreenButtonsConstraint: (HPGreenButtonVC*) sendMessage
{
    [sendMessage.view addConstraint:[NSLayoutConstraint constraintWithItem: sendMessage.view
                                                                 attribute: NSLayoutAttributeWidth
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: nil
                                                                 attribute: NSLayoutAttributeNotAnAttribute
                                                                multiplier: 1.0
                                                                  constant: sendMessage.view.frame.size.width]];
    
    [sendMessage.view addConstraint:[NSLayoutConstraint constraintWithItem: sendMessage.view
                                                                 attribute: NSLayoutAttributeHeight
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: nil
                                                                 attribute: NSLayoutAttributeNotAnAttribute
                                                                multiplier: 1.0
                                                                  constant: sendMessage.view.frame.size.height]];
}


- (void) greenButtonPressed: (HPGreenButtonVC*) button
{
    if (button.tag == 0) {
        isCamera = NO;
        [self showPhotoPickerController];
    } else {
        isCamera = YES;
        [self showCameraControl];
    }
    
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
    if (isCamera) {
        UIImage *viewImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        // Request to save the image to camera roll
        [library writeImageToSavedPhotosAlbum:[viewImage CGImage] orientation:(ALAssetOrientation)[viewImage imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
            if (error) {
                NSLog(@"error");
            } else {
                NSLog(@"url %@", assetURL);
            }  
        }];
        
        [picker dismissModalViewControllerAnimated:YES];
        
    } else {
        UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
        NSURL *path = [info valueForKey:UIImagePickerControllerReferenceURL];
        [picker dismissViewControllerAnimated:YES completion:^{
            NSLog(@"image path = %@", path);
        }];
    }
    isCamera = NO;
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
            [self presentModalViewController:picker animated:YES];
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
    //NSLog(@"Image:%@", image);
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
    [picker dismissModalViewControllerAnimated:YES];
}

@end
