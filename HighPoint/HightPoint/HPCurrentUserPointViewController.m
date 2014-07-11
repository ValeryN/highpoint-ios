//
//  HPCurrentUserPointViewController.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 10.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPCurrentUserPointViewController.h"

@interface HPCurrentUserPointViewController ()

@end

@implementation HPCurrentUserPointViewController

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
    [self setGestureRecognizerForBgImage];
    self.pointTextView.delegate = self;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - background tap

- (void) setGestureRecognizerForBgImage {
    self.bgAvatarImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    singleTap.delegate = self;
    [self.bgAvatarImageView addGestureRecognizer:singleTap];
}

- (void) backgroundTap {
    [self.view endEditing:YES];
}

- (IBAction)userProfileBtnTap:(id)sender {
}


#pragma mark - text view delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [UIView animateWithDuration:0.5 delay:0.0 options: UIViewAnimationCurveEaseOut
        animations:^{
            self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 80, self.view.frame.size.width, self.view.frame.size.height);
        }
        completion:^(BOOL finished){
            NSLog(@"Done!");
        }];
    
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    [UIView animateWithDuration:0.5 delay:0.0 options: UIViewAnimationCurveEaseOut
                     animations:^{
                         self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 80, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];
}
@end
