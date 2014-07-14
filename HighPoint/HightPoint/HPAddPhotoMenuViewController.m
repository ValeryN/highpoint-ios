//
//  HPAddPhotoMenuViewController.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 14.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPAddPhotoMenuViewController.h"

@interface HPAddPhotoMenuViewController ()

@end

@implementation HPAddPhotoMenuViewController

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
        [self showPhotoPickerController];
    } else {
        //get camera
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
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSURL *path = [info valueForKey:UIImagePickerControllerReferenceURL];
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"image path = %@", path);
    }];
}

@end
