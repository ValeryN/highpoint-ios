//
//  HPAddEducationViewController.m
//  HighPoint
//
//  Created by Andrey Anisimov on 04.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPAddEducationViewController.h"
#import "Utils.h"
@interface HPAddEducationViewController ()

@end

@implementation HPAddEducationViewController

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
    self.view.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:48.0/255.0 alpha:1.0];
    
    
    self.firstRow.font = [UIFont fontWithName:@"FuturaPT-Light" size:18.0];
    self.secondRow.font = [UIFont fontWithName:@"FuturaPT-Light" size:18.0];
    self.thirdRow.font = [UIFont fontWithName:@"FuturaPT-Light" size:18.0];
    
    self.firstRow.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
    self.secondRow.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
    self.thirdRow.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
    
    self.firstRow.delegate = self;
    self.secondRow.delegate = self;
    self.thirdRow.delegate = self;
    // Do any additional setup after loading the view from its nib.
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Utils configureNavigationBar:self.navigationController];
    [self configureNavButton];
    [self.navigationController setNavigationBarHidden:NO];
    //[self addTownsListFromFilter];
    //[self.townsTableView reloadData];
    [[UITextField appearance] setTintColor:[UIColor colorWithRed:80.0/255.0 green:227.0/255.0 blue:194.0/255.0 alpha:1]];
    //[self.townSearchBar becomeFirstResponder];
    self.automaticallyAdjustsScrollViewInsets = NO;
    NSArray *arr = [self.navigationItem rightBarButtonItems];
    if(arr.count >= 2) {
        UIBarButtonItem *rightButton_ = (UIBarButtonItem*) [arr objectAtIndex:1];
        rightButton_.customView.alpha = 0.4;
    }
    [self configurePlaceholders];
    [self registerNotification];
}
- (void) configurePlaceholders {
    NSAttributedString *str;
    NSAttributedString *str1;
    NSAttributedString *str2;
    if(self.isItForEducation) {
        str = [[NSAttributedString alloc] initWithString:@"Название учебного заведения" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:0.4], NSFontAttributeName : [UIFont fontWithName:@"FuturaPT-Light" size:18.0] }];
        str1 = [[NSAttributedString alloc] initWithString:@"Специальность" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:0.4], NSFontAttributeName : [UIFont fontWithName:@"FuturaPT-Light" size:18.0] }];
        str2 = [[NSAttributedString alloc] initWithString:@"Годы обучения" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:0.4], NSFontAttributeName : [UIFont fontWithName:@"FuturaPT-Light" size:18.0] }];
        
    } else {
        str = [[NSAttributedString alloc] initWithString:@"Место работы" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:0.4], NSFontAttributeName : [UIFont fontWithName:@"FuturaPT-Light" size:18.0] }];
        str1 = [[NSAttributedString alloc] initWithString:@"Должность" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:0.4], NSFontAttributeName : [UIFont fontWithName:@"FuturaPT-Light" size:18.0] }];
        str2 = [[NSAttributedString alloc] initWithString:@"Годы работы" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:0.4], NSFontAttributeName : [UIFont fontWithName:@"FuturaPT-Light" size:18.0] }];
    }
    self.firstRow.attributedPlaceholder = str;
    self.secondRow.attributedPlaceholder = str1;
    self.thirdRow.attributedPlaceholder = str2;
}
- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterNotification];
}
#pragma mark - notifications
- (void) registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(textFieldTextChange) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void) unregisterNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}
- (void) configureNavButton {
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 23)];
    [leftButton setContentMode:UIViewContentModeScaleAspectFit];
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 23)];
    [rightButton setContentMode:UIViewContentModeScaleAspectFit];
    
    
    leftButton.titleLabel.font = [UIFont fontWithName:@"FuturaPT-Book" size:16];
    [leftButton setTitle:@"Отменить" forState:UIControlStateNormal];
    [leftButton setTitle:@"Отменить" forState:UIControlStateHighlighted];
    
    rightButton.titleLabel.font = [UIFont fontWithName:@"FuturaPT-Medium" size:16];
    [rightButton setTitle:@"Готово" forState:UIControlStateNormal];
    [rightButton setTitle:@"Готово" forState:UIControlStateHighlighted];
    
    [leftButton setTitleColor:[UIColor colorWithRed:80.0/255.0 green:227.0/255.0 blue:194.0/255.0 alpha:1] forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor colorWithRed:80.0/255.0 green:227.0/255.0 blue:194.0/255.0 alpha:1] forState:UIControlStateHighlighted];
    
    [rightButton setTitleColor:[UIColor colorWithRed:80.0/255.0 green:227.0/255.0 blue:194.0/255.0 alpha:1] forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor colorWithRed:80.0/255.0 green:227.0/255.0 blue:194.0/255.0 alpha:1] forState:UIControlStateHighlighted];
    //[leftButton setBackgroundImage:[UIImage imageNamed:@"Back.png"] forState:UIControlStateNormal];
    //[leftButton setBackgroundImage:[UIImage imageNamed:@"Back Tap.png"] forState:UIControlStateHighlighted];
    
    [leftButton addTarget:self action:@selector(backButtonTap:) forControlEvents: UIControlEventTouchUpInside];
    [rightButton addTarget:self action:@selector(readyButtonTap:) forControlEvents: UIControlEventTouchUpInside];
    //[leftButton addTarget:self action:@selector(profileButtonPressedStop:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButton_ = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    UIBarButtonItem *rightButton_ = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        // Add a negative spacer on iOS >= 7.0
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -25;
        UIBarButtonItem *negativeSpacerRight = [[UIBarButtonItem alloc]
                                                initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                target:nil action:nil];
        negativeSpacerRight.width = -30;
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, leftButton_, nil]];
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacerRight, rightButton_, nil]];
    } else {
        // Just set the UIBarButtonItem as you would normally
        [self.navigationItem setLeftBarButtonItem:leftButton_];
        [self.navigationItem setRightBarButtonItem:rightButton_];
    }
    
}
#pragma mark - navigation bar item tap handler
- (void) backButtonTap:(UIButton *)sender {
    //[self showNotification];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) readyButtonTap:(UIButton *)sender {
    
    NSMutableArray *arr = [NSMutableArray new];
    if(self.firstRow.text.length > 0) {
        [arr addObject:self.firstRow.text];
    } else {
         [arr addObject:@""];
    }
    if(self.secondRow.text.length > 0) {
        [arr addObject:self.secondRow.text];
    } else {
        [arr addObject:@""];
    }
    if(self.thirdRow.text.length > 0) {
        [arr addObject:self.thirdRow.text];
    } else {
        [arr addObject:@""];
    }
    if(self.isItForEducation) {
        if([self.delegate respondsToSelector:@selector(newEducationSelected:)]) {
            [self.delegate newEducationSelected:arr];
        }
    } else {
        if([self.delegate respondsToSelector:@selector(newWorkPlaceSelected:)]) {
            [self.delegate newWorkPlaceSelected:arr];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - UITextFieldDelegate and notification
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if([textField isFirstResponder] && [textField isEqual:self.firstRow]) {
        [textField resignFirstResponder];
        [self.secondRow becomeFirstResponder];
    }
    if([textField isFirstResponder] && [textField isEqual:self.secondRow]) {
        [textField resignFirstResponder];
        [self.thirdRow becomeFirstResponder];
    }
    return YES;
}
- (void) textFieldTextChange {
    if(([self.firstRow isFirstResponder] && self.firstRow.text.length > 0) || ([self.secondRow isFirstResponder] && self.secondRow.text.length > 0) ||
       ([self.thirdRow isFirstResponder] && self.thirdRow.text.length > 0)) {
        NSArray *arr = [self.navigationItem rightBarButtonItems];
        if(arr.count >= 2) {
            UIBarButtonItem *rightButton_ = (UIBarButtonItem*) [arr objectAtIndex:1];
            rightButton_.customView.alpha = 1.0;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
