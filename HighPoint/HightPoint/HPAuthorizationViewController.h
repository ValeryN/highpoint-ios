//
//  HPAuthorizationViewController.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 21.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HPAuthorizationViewController : UIViewController


@property (weak, nonatomic) IBOutlet UITextField *loginTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;

- (IBAction)authBtnTap:(id)sender;

@end
