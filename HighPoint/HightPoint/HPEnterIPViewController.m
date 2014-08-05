//
//  HPEnterIPViewController.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 25.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPEnterIPViewController.h"
#import "HPRootViewController.h"
#import "UINavigationController+HighPoint.h"
#import "URLs.h"

@interface HPEnterIPViewController ()

@end

@implementation HPEnterIPViewController

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
    [self.navigationController hp_configureNavigationBar];
    self.ipTextField.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)enterApiBtnTap:(id)sender {
    
    if (self.ipTextField.text.length > 0) {
        [URLs setServerUrl:self.ipTextField.text];
    } else  {
        [URLs setServerUrl:@"localhost"];
    }
    
    HPRootViewController *rootController;
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard_568" bundle:nil];
    rootController = [storyBoard instantiateViewControllerWithIdentifier:@"HPRootViewController"];
    [self.navigationController pushViewController:rootController animated:YES];

}

#pragma mark - text field

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (string.length < 1) {
        return YES;
    }
    
    if (textField.text.length > 14) {
        return NO;
    }
    
    return YES;
}

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}



@end
