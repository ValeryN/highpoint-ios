//
//  HPChatTableViewCell.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 08.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPChatTableViewCell.h"

@implementation HPChatTableViewCell

- (void)awakeFromNib
{
    [self setup];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void) setup {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) + [self returnCatchWidth], CGRectGetHeight(self.bounds));
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    
    [self.contentView addSubview:scrollView];
    self.scrollView = scrollView;
    
    UIView *scrollViewButtonView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - [self returnCatchWidth], 0, [self returnCatchWidth], CGRectGetHeight(self.bounds))];
    self.scrollViewButtonView = scrollViewButtonView;
    [self.scrollView addSubview:scrollViewButtonView];
    
    self.scrollView.backgroundColor = [UIColor clearColor];
    
    // Set up our two buttons
    
    UIView *buttonBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self returnCatchWidth], CGRectGetHeight(self.bounds))];
    buttonBackView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0f];
    
    
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.exclusiveTouch = YES;
    addButton.frame = CGRectMake(0, 0, 100, 60);
    [addButton addTarget:self action:@selector(deleteChat:) forControlEvents:UIControlEventTouchUpInside];

    
    [buttonBackView addSubview:addButton];
    [self.scrollViewButtonView addSubview:buttonBackView];

    
    UIView *scrollViewContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];//CGRectGetHeight(self.bounds)
    [self.scrollView addSubview:scrollViewContentView];
    scrollViewContentView.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:48.0/255.0 alpha:1.0f];
    self.scrollViewContentView = scrollViewContentView;

    
    [self.userImageView removeFromSuperview];
    [self.scrollViewContentView addSubview: self.userImageView];
    [self.msgCountView removeFromSuperview];
    [self.scrollViewContentView addSubview: self.msgCountView];
    [self.userNameLabel removeFromSuperview];
    [self.scrollViewContentView addSubview: self.userNameLabel];
    [self.userAgeAndLocationLabel removeFromSuperview];
    [self.scrollViewContentView addSubview:self.userAgeAndLocationLabel];
    [self.currentMsgLabel removeFromSuperview];
    [self.scrollViewContentView addSubview:self.currentMsgLabel];
    [self.userAgeAndLocationLabel removeFromSuperview];
    [self.scrollViewContentView addSubview:self.userAgeAndLocationLabel];
    [self.currentUserImageView removeFromSuperview];
    [self.scrollViewContentView addSubview:self.currentUserImageView];
    [self.currentUserMsgLabel removeFromSuperview];
    [self.scrollViewContentView addSubview:self.currentUserMsgLabel];
}

- (int) returnCatchWidth {
    return 95;
}
-(void)prepareForReuse {
    [super prepareForReuse];
    //[self removePanGesture];
    [self.scrollView setContentOffset:CGPointZero animated:NO];
}

- (void)deleteChat:(TLSwipeForOptionsCell *)cell {
    NSLog(@"delete");
}


@end
