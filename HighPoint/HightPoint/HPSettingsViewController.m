//
//  HPSettingsViewController.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 21.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPSettingsViewController.h"
#import "URLs.h"
#import "UserTokenUtils.h"

@interface HPSettingsViewController ()

@end

@implementation HPSettingsViewController

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
    self.enterIPTextField.delegate = self;
    self.enterIPTextField.text = [URLs getIPFromSettings];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutBtnTap:(id)sender {
    [UserTokenUtils setUserToken:nil];
}

- (IBAction)changeIPBtnTap:(id)sender {
    if (self.enterIPTextField.text.length > 0) {
        [URLs setServerUrl:self.enterIPTextField.text];
    } else  {
        [URLs setServerUrl:kAPIBaseURLString];
    }
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
