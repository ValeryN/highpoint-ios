//
//  HPChatMsgTableViewCell.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 24.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HPChatMsgTableViewCell : UITableViewCell <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (void) configureSelfWithMsg;

@end
