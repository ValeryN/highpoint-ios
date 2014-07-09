//
//  TLSwipeForOptionsCell.m
//  UITableViewCell-Swipe-for-Options
//
//  Created by Ash Furrow on 2013-07-29.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLSwipeForOptionsCell.h"

NSString *const TLSwipeForOptionsCellEnclosingTableViewDidBeginScrollingNotification = @"TLSwipeForOptionsCellEnclosingTableViewDidScrollNotification";

//#define kCatchWidth 100

@interface TLSwipeForOptionsCell () <UIScrollViewDelegate>



@end

@implementation TLSwipeForOptionsCell

-(void)awakeFromNib {
    [super awakeFromNib];
    
    [self setup];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}
//TODO:
-(void)setup {
 }
- (int) returnCatchWidth {
    return 100;
}
-(void)enclosingTableViewDidScroll {
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - Private Methods

-(void)addToTemplate:(id)sender {
    if([self.delegate respondsToSelector:@selector(addToTemplate:)])
        [self.delegate addToTemplate:self];
    
    
    //[self.scrollView setContentOffset:CGPointZero animated:YES];
}

-(void)signToInvoice:(id)sender {
    if([self.delegate respondsToSelector:@selector(signToInvoice:)])
        [self.delegate signToInvoice:self];
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - Overridden Methods

-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) + [self returnCatchWidth], CGRectGetHeight(self.bounds));
    self.scrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    self.scrollViewButtonView.frame = CGRectMake(CGRectGetWidth(self.bounds) - [self returnCatchWidth], 0, [self returnCatchWidth], CGRectGetHeight(self.bounds));
    self.scrollViewContentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
}

-(void)prepareForReuse {
    [super prepareForReuse];
    
    [self.scrollView setContentOffset:CGPointZero animated:NO];
}
- (void) resetCell {
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}
-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    self.scrollView.scrollEnabled = !self.editing;
    
    // Corrects effect of showing the button labels while selected on editing mode (comment line, build, run, add new items to table, enter edit mode and select an entry)
    self.scrollViewButtonView.hidden = editing;
    
    NSLog(@"%d", editing);
}

-(UILabel *)textLabel {
    // Kind of a cheat to reduce our external dependencies
    return self.scrollViewLabel;
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    if (scrollView.contentOffset.x > [self returnCatchWidth]) {
        targetContentOffset->x = [self returnCatchWidth];
    }
    else {
        *targetContentOffset = CGPointZero;
        
        // Need to call this subsequently to remove flickering. Strange.
        dispatch_async(dispatch_get_main_queue(), ^{
            [scrollView setContentOffset:CGPointZero animated:YES];
        });
    }
}/*
#pragma mark -
#pragma mark - UITapGestureRecognizer Methods
- (void) addPanGesture
{
    if(self.tapGesture == nil)
    {
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        
        self.tapGesture.cancelsTouchesInView = NO;
        self.tapGesture.numberOfTouchesRequired = 1;
        self.tapGesture.numberOfTapsRequired = 1;
        [self.tapGesture setDelegate:self];
        [self.scrollViewContentView addGestureRecognizer:self.tapGesture];
    }
}
- (void) removePanGesture
{
    [self.scrollViewContentView removeGestureRecognizer:self.tapGesture];
    //[self.tapGesture release];
    self.tapGesture = nil;
}*/

- (void)tapGesture:(UITapGestureRecognizer *)recognizer {
    if([self.delegate respondsToSelector:@selector(cellDidTap:)])
        [self.delegate cellDidTap:self];
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if([self.delegate respondsToSelector:@selector(cellWillSwipe:)])
        [self.delegate cellWillSwipe:self];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x < 0) {
        scrollView.contentOffset = CGPointZero;
    }
    
    self.scrollViewButtonView.frame = CGRectMake(scrollView.contentOffset.x + (CGRectGetWidth(self.bounds) - [self returnCatchWidth]), 0.0f, [self returnCatchWidth], CGRectGetHeight(self.bounds));
}

@end

#undef kCatchWidth
