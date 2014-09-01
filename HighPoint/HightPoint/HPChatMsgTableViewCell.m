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
    [self.msgTextView removeFromSuperview];
    CGSize labelSize = [self getCellSize:msg];
    
    if ([msg.sourceId isEqualToNumber:self.currentUserId]) {
        int width = 250;
        if (labelSize.width < 250) {
            width = labelSize.width;
        }
        self.msgTextView = [[UITextView alloc] initWithFrame:CGRectMake(60, 8, width, labelSize.height + 25)];
        self.msgTextView.backgroundColor = [UIColor colorWithRed: 230.0 / 255.0
                                                           green: 230.0 / 255.0
                                                            blue: 242.0 / 255.0
                                                           alpha: 1.0];
    } else {
        
        int width = 250;
        if (labelSize.width < 250) {
            width = labelSize.width;
        }
        
        
        self.msgTextView = [[UITextView alloc] initWithFrame:CGRectMake(100 + 250 - width, 8, width, labelSize.height + 25)];
        self.msgTextView.backgroundColor = [UIColor colorWithRed: 80.0 / 255.0
                                                           green: 227.0 / 255.0
                                                            blue: 194.0 / 255.0
                                                           alpha: 1.0];
    }
    
    self.msgTextView.userInteractionEnabled = NO;
    self.scrollView.userInteractionEnabled = NO;
    self.msgTextView.text = msg.text;
    self.msgTextView.font = [UIFont fontWithName:@"FuturaPT-Book" size:18.0];
    self.msgTextView.layer.cornerRadius = 15;
    [self.scrollView addSubview:self.msgTextView];
}


#pragma mark - count size 
- (CGSize) getCellSize : (Message *) msg {
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:18.0];
    CGSize constraintSize = CGSizeMake(250.0f, 1000.0f);
    CGRect textRect = [msg.text boundingRectWithSize:constraintSize
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:cellFont}
                                         context:nil];
    CGSize labelSize = textRect.size;
    return labelSize;
}

#pragma mark - scroll view delegate
-(void)scrollViewDidScroll:(UIScrollView *)sender
{
    NSLog(@"content offset = %f", self.scrollView.contentOffset.x);
    if (self.scrollView.contentOffset.x > 40) {
        self.scrollView.contentOffset = CGPointMake(40, self.scrollView.contentOffset.y);
    }
    if (self.scrollView.contentOffset.x < -16) {
        self.scrollView.contentOffset = CGPointMake(-16, self.scrollView.contentOffset.y);
    }
    
//    if ([self.delegate respondsToSelector:@selector(scrollCellsForTimeShowing:)]) {
//        [self.delegate scrollCellsForTimeShowing:self.scrollView.contentOffset];
//    }
    
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

- (void) scrollCellForTimeShowingCell :(CGPoint) point {
    [self.scrollView scrollRectToVisible:CGRectMake(point.x,0,360, 99) animated:YES];
}


@end
