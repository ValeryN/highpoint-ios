//
//  HPChangeAccountPasswordViewController.m
//  HighPoint
//
//  Created by Eugene on 15/10/14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPChangeAccountPasswordViewController.h"
#import "UIViewController+HighPoint.h"

@interface HPChangeAccountPasswordViewController ()
@property (nonatomic,weak) IBOutlet UITextField* textFieldOldPassword;
@property (nonatomic,weak) IBOutlet UITextField* textFieldNewPassword;
@property (nonatomic,weak) IBOutlet UITextField* textFieldConfirmPassword;
@end

@implementation HPChangeAccountPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureBackButton];
    self.navigationItem.rightBarButtonItem = [self barItemChangePassword];
    // Do any additional setup after loading the view from its nib.
}

- (UIBarButtonItem *)barItemChangePassword {
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] init];
    rightBarItem.title = @"Готово";
    @weakify(self);
    [rightBarItem setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"FuturaPT-Book" size:18]} forState:UIControlStateNormal];
    [rightBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:80.f / 255.f green:227.f / 255.f blue:194.f / 255.f alpha:0.4]} forState:UIControlStateDisabled];
    rightBarItem.rac_command = [[RACCommand alloc] initWithEnabled:[self canSendChangePassword] signalBlock:^RACSignal *(id input) {
        @strongify(self)
        [self.navigationController popViewControllerAnimated:YES];
        return [RACSignal empty];
    }];
    return rightBarItem;
}

- (RACSignal *) canSendChangePassword{
    RACSignal* oldPassword = [self.textFieldOldPassword.rac_textSignal map:^id(NSString* value) {
        return @(value.length>0);
    }];
    RACSignal* newPassword = [self.textFieldNewPassword.rac_textSignal map:^id(NSString* value) {
        return @(value.length>0);
    }];
    RACSignal* confirmPassword = [self.textFieldConfirmPassword.rac_textSignal map:^id(NSString* value) {
        return @(value.length>0);
    }];
    
    return [[RACSignal combineLatest:@[oldPassword,newPassword,confirmPassword]] and];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
