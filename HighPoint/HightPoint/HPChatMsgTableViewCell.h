//
//  HPChatMsgTableViewCell.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 24.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"


@interface HPChatMsgTableViewCell : UITableViewCell <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UITextView * msgTextView;

- (void) configureSelfWithMsg : (Message *) msg;

@end
