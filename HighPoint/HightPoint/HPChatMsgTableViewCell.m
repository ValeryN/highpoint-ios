//
//  HPChatMsgTableViewCell.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 24.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPChatMsgTableViewCell.h"

@implementation HPChatMsgTableViewCell

- (void)awakeFromNib
{
    self.scrollView.delegate = self;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void) configureSelfWithIncomingMsg {
    [self.scrollView setContentSize:CGSizeMake(360, 99)];
    [self.scrollView scrollRectToVisible:CGRectMake(40,0,360, 99) animated:NO];
}


#pragma mark - scroll view delegate


-(void)scrollViewDidScroll:(UIScrollView *)sender
{
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
