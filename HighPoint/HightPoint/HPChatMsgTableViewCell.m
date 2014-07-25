//
//  HPChatMsgTableViewCell.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 24.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPChatMsgTableViewCell.h"
#import <QuartzCore/QuartzCore.h>


@implementation HPChatMsgTableViewCell

- (void)awakeFromNib
{
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


- (void) configureSelfWithMsg : (Message *) msg {
    CGSize labelSize = [self getCellSize:msg];
    self.contentView.frame = CGRectMake(0, 0, 320,labelSize.height + 32);
    self.scrollView.frame = CGRectMake(0, 0, 320,labelSize.height + 32);
    [self.scrollView setContentSize:CGSizeMake(360, labelSize.height + 32)];
    [self.contentView addSubview:self.scrollView];
    [self addMsgView: msg];
    [self.scrollView scrollRectToVisible:CGRectMake(40,0,360, 99) animated:NO];
}

#pragma mark - msg area configure

- (void) addMsgView : (Message*) msg {
    CGSize labelSize = [self getCellSize:msg];
    self.msgTextView = [[UITextView alloc] initWithFrame:CGRectMake(60, 8, 250, labelSize.height + 16)];
    self.msgTextView.userInteractionEnabled = NO;
    self.msgTextView.backgroundColor = [UIColor greenColor];
    self.msgTextView.text = msg.messageBody;
    self.msgTextView.font = [UIFont fontWithName:@"Helvetica" size:18.0];
    self.msgTextView.layer.cornerRadius = 5;    
    [self.scrollView addSubview:self.msgTextView];
}


#pragma mark - count size 
- (CGSize) getCellSize : (Message *) msg {
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:18.0];
    CGSize constraintSize = CGSizeMake(250.0f, 600);
    CGSize labelSize = [msg.messageBody sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    return labelSize;
}

#pragma mark - scroll view delegate
-(void)scrollViewDidScroll:(UIScrollView *)sender
{
    NSLog(@"content offset = %f", self.scrollView.contentOffset.x);
    if (self.scrollView.contentOffset.x > 40) {
        self.scrollView.contentOffset = CGPointMake(40, self.scrollView.contentOffset.y);
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:nil afterDelay:0.0];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.scrollView scrollRectToVisible:CGRectMake(40,0,360, 99) animated:NO];
    } completion:NULL];
}


@end
