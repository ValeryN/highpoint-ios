//
//  HPAddNewTownView.m
//  HighPoint
//
//  Created by Andrey Anisimov on 01.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPAddNewTownView.h"

@implementation HPAddNewTownView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
+ (id) createView {
    
    HPAddNewTownView *customView = [[[NSBundle mainBundle] loadNibNamed:@"HPAddNewTownView" owner:nil options:nil] lastObject];
    if ([customView isKindOfClass:[HPAddNewTownView class]]) {
        [customView configureView];
        return customView;
    }
    
    else
        return nil;
}
- (void) configureView {
    self.label.numberOfLines = 0;
    self.label.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ];
    self.label.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
    self.label.textAlignment = NSTextAlignmentLeft;
    self.addImgTap.hidden = YES;
}
- (IBAction)buttonTapDown:(id)sender {
    self.addImg.hidden = YES;
    self.addImgTap.hidden = NO;
}
- (IBAction)buttonTapUp:(id)sender {
    self.addImg.hidden = NO;
    self.addImgTap.hidden = YES;
    if([self.delegate respondsToSelector:@selector(showNextView:)]) {
        [self.delegate showNextView:self];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
