//
//  HPSlider.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 06.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPSlider.h"
#import <QuartzCore/QuartzCore.h>


#define hours [NSDictionary dictionaryWithObjectsAndKeys: @"часов", @0, @"час", @1, @"часа",@2, @"часа",@3, @"часа",@4, @"часов", @5, @"часов",@6, @"часов",@7, @"часов",@8, @"часов",@9, @"часов",@10, @"часов",@11, @"часов", @12, nil]



@interface HPSliderTimeView : UIView
@property (nonatomic) float value;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, retain) NSString *text;
@end

@implementation HPSliderTimeView

@synthesize value=_value;
@synthesize font=_font;
@synthesize text = _text;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [UIFont fontWithName: @"FuturaPT-Light" size:16.0f];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
	[[UIColor redColor] setFill];
    

    CGRect roundedRect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, 84, floorf(self.bounds.size.height * 0.8));
    UIBezierPath *roundedRectPath = [UIBezierPath bezierPathWithRoundedRect:roundedRect cornerRadius:6.0];
//    

//    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
//    CGFloat midX = CGRectGetMidX(roundedRect);
//    CGPoint p0 = CGPointMake(midX, CGRectGetMaxY(roundedRect) + 5);
//    [arrowPath moveToPoint:p0];
//    [arrowPath addLineToPoint:CGPointMake((midX - 5.0), CGRectGetMaxY(roundedRect))];
//    [arrowPath addLineToPoint:CGPointMake((midX + 5.0), CGRectGetMaxY(roundedRect))];
//    [arrowPath closePath];
//    
//    // Attach the arrow path to the rounded rect
//    [roundedRectPath appendPath:arrowPath];
//    
//    [roundedRectPath fill];
    

    if (self.text) {
        [[UIColor colorWithRed: 230.0 / 255.0
                         green: 236.0 / 255.0
                          blue: 242.0 / 255.0
                         alpha: 1.0] set];
        CGSize s = [_text sizeWithFont:self.font];
        CGFloat yOffset = (roundedRect.size.height - s.height) / 2;
        CGRect textRect = CGRectMake(roundedRect.origin.x, yOffset, roundedRect.size.width, s.height);
        
        [_text drawInRect:textRect
                 withFont:self.font
            lineBreakMode:UILineBreakModeWordWrap
                alignment:UITextAlignmentCenter];
    }

    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 1.0f;
}

- (void)setValue:(float)aValue {
    _value = aValue;
    self.text = [NSString stringWithFormat:@"%.0f %@", _value, [hours objectForKey:[NSNumber numberWithFloat:_value]]];
    [self setNeedsDisplay];
}

@end



@implementation HPSlider

@synthesize thumbRect;


- (void) constructSlider {
    timePopupView = [[HPSliderTimeView alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, 84, floorf(self.bounds.size.height * 0.8))];
    timePopupView.backgroundColor = [UIColor clearColor];
    timePopupView.alpha = 1.0;
    [self addSubview:timePopupView];
}


- (void)_positionAndUpdatePopupView {
    CGRect _thumbRect = self.thumbRect;
    CGRect popupRect = CGRectOffset(CGRectMake(_thumbRect.origin.x, _thumbRect.origin.y, 84, _thumbRect.size.height), 0, -floorf(_thumbRect.size.height * 1.5));
    timePopupView.frame = CGRectInset(popupRect, -20, -10);
    timePopupView.value = (NSInteger)self.value;
}

#pragma mark - Memory management

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self constructSlider];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self constructSlider];
    }
    return self;
}



- (void) initOnLoad {
    [self _positionAndUpdatePopupView];
}


#pragma mark - UIControl touch event tracking

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint = [touch locationInView:self];
    if(CGRectContainsPoint(CGRectInset(self.thumbRect, -12.0, -12.0), touchPoint)) {
        [self _positionAndUpdatePopupView];
    }
    return [super beginTrackingWithTouch:touch withEvent:event];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self _positionAndUpdatePopupView];
    return [super continueTrackingWithTouch:touch withEvent:event];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [super cancelTrackingWithEvent:event];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
}


- (CGRect)thumbRect {
    CGRect trackRect = [self trackRectForBounds:self.bounds];
    CGRect thumbR = [self thumbRectForBounds:self.bounds trackRect:trackRect value:self.value];
    return thumbR;
}


@end
