//
//  HPChatMsgTableViewCell.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 24.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestMessage.h"
#import "HPChatViewController.h"


@interface HPChatMsgTableViewCell : UITableViewCell <UIScrollViewDelegate>


@property (strong, nonatomic) id <HPChatViewControllerProtocol> delegate;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UITextView * msgTextView;

- (void) configureSelfWithMsg : (TestMessage *) msg;
- (void) scrollCellForTimeShowingCell :(CGPoint) point;
@end
