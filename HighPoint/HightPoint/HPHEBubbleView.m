//
// Created by Eugene on 25.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPHEBubbleView.h"
#import "PSMenuItem.h"
#import "HPBubbleViewDelegate.h"

@implementation HPHEBubbleView

+ (void)load {
    [PSMenuItem installMenuHandlerForObject:self];
}


- (void)showMenuCalloutWthItems:(NSArray *) menuItems forBubbleItem:(HEBubbleViewItem *)item {

    [self becomeFirstResponder];


    PSMenuItem *actionCopy = [[PSMenuItem alloc] initWithTitle:@"Copy" block:^{
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        [pb setString:item.textLabel.text];
    }];

    UIMenuController *menu = [UIMenuController sharedMenuController];
    menu.menuItems = [menuItems arrayByAddingObject:actionCopy];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didHideMenuController) name:UIMenuControllerDidHideMenuNotification object:menu];

    self.activeBubble = item;

    [menu setTargetRect:item.frame inView:item.superview];
    [menu setMenuVisible:YES animated:YES];

}
- (void)setRetainDelegate:(NSObject <HEBubbleViewDelegate, HEBubbleViewDataSource> *)retainDelegate {
    _retainDelegate = retainDelegate;
    self.bubbleDelegate = retainDelegate;
    self.bubbleDataSource = retainDelegate;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return NO;
}

@end