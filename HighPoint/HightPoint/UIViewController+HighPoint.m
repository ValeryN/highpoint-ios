//
//  UIViewController+HighPoint.m
//  HighPoint
//
//  Created by Michael on 18.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//



#import "UIViewController+HighPoint.h"



@implementation UIViewController (HighPoint)



- (void)hp_setNavigationItemPropertiesFromOtherItem:(UINavigationItem *)navItem {
    // WORKAROUND: we can't link UINavigationItem to UIViewController from IB, and navigationItem property in UIViewController is readonly
    self.navigationItem.title = navItem.title;
    self.navigationItem.prompt = navItem.prompt;
    self.navigationItem.hidesBackButton = navItem.hidesBackButton;
    if (navItem.backBarButtonItem != nil) {
        self.navigationItem.backBarButtonItem = navItem.backBarButtonItem;
    }
    if (navItem.leftBarButtonItem != nil) {
        self.navigationItem.leftBarButtonItem = navItem.leftBarButtonItem;
    }
    if (navItem.rightBarButtonItem != nil) {
        self.navigationItem.rightBarButtonItem = navItem.rightBarButtonItem;
    }
    if (navItem.titleView != nil) {
        self.navigationItem.titleView = navItem.titleView;
    }
}



- (UIBarButtonItem *)createBarButtonItemWithImage:(UIImage *)image
                                  highlighedImage:(UIImage *)highlighedImage
                                           action:(SEL)action {

    UIButton *newButton = [UIButton buttonWithType:UIButtonTypeCustom];
    newButton.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [newButton setBackgroundImage:image forState:UIControlStateNormal];
    [newButton setBackgroundImage:highlighedImage forState:UIControlStateHighlighted];


    UIBarButtonItem *newbuttonItem = [[UIBarButtonItem alloc] initWithCustomView:newButton];
    if (action && [self respondsToSelector:action]) {
        [newButton addTarget:self
                      action:action
            forControlEvents:UIControlEventTouchUpInside];
    }
    RACChannelTo(newButton, rac_command) = RACChannelTo(newbuttonItem, rac_command);

    return newbuttonItem;

}

- (void) configureBackButton{
    @weakify(self);
    UIBarButtonItem* backButton = [self createBarButtonItemWithImage:[UIImage imageNamed:@"Back.png"]
                                                     highlighedImage:[UIImage imageNamed:@"Back Tap.png"]
                                                              action:nil];
    backButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
        return [RACSignal empty];
    }];
    self.navigationItem.leftBarButtonItem = backButton;
}
@end
