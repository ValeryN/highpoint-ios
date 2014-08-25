//
//  HPSettingsViewController.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 21.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HPSettingsViewController : UIViewController <UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UITextField *enterIPTextField;


- (IBAction)logoutBtnTap:(id)sender;
- (IBAction)changeIPBtnTap:(id)sender;

@end
