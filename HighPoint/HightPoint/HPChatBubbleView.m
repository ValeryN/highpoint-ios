//
// Created by Eugene on 17.09.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPChatBubbleView.h"
#define OFFSET 4.63f
#define CORNER_RADIUS 15.f


@implementation HPChatBubbleView

+ (CAShapeLayer *)maskWithRect:(CGRect) rect andType:(BubbleType) bubbleType{

    UIBezierPath * path = [UIBezierPath bezierPath];
    //Left Top corner
    [path moveToPoint:(CGPoint){OFFSET+0,CORNER_RADIUS}];
    [path addQuadCurveToPoint:(CGPoint){OFFSET+CORNER_RADIUS,0} controlPoint:(CGPoint){OFFSET+0,0}];
    //Right top corner
    [path addLineToPoint:CGPointMake(rect.size.width - CORNER_RADIUS,0)];
    [path addQuadCurveToPoint:(CGPoint){rect.size.width,CORNER_RADIUS} controlPoint:(CGPoint){rect.size.width,0}];
    //Right bottom corner
    [path addLineToPoint:CGPointMake(rect.size.width,rect.size.height-CORNER_RADIUS)];
    [path addQuadCurveToPoint:(CGPoint){rect.size.width - CORNER_RADIUS,rect.size.height} controlPoint:(CGPoint){rect.size.width,rect.size.height}];

    //Left bottom corner
    [path addLineToPoint:CGPointMake(OFFSET+CORNER_RADIUS, rect.size.height)];
    [path addCurveToPoint:(CGPoint){OFFSET+(CORNER_RADIUS/2.4f),rect.size.height - (CORNER_RADIUS/5.f)} controlPoint1:(CGPoint){OFFSET+(CORNER_RADIUS/1.25f),rect.size.height} controlPoint2:(CGPoint){OFFSET+(CORNER_RADIUS/1.71f),rect.size.height-(CORNER_RADIUS/13.75f)}];
    [path addQuadCurveToPoint:(CGPoint){0,rect.size.height} controlPoint:(CGPoint){OFFSET+(CORNER_RADIUS/3.98f),rect.size.height}];
    [path addCurveToPoint:(CGPoint){OFFSET/7.5f, rect.size.height-(OFFSET/18.9f)} controlPoint1:(CGPoint){OFFSET/7.8f, rect.size.height-(OFFSET/19.f)} controlPoint2:(CGPoint){OFFSET/2.04f, rect.size.height-(OFFSET/4.47f)}];
    [path addCurveToPoint:(CGPoint){OFFSET/1.23f,rect.size.height - (CORNER_RADIUS/3.79f)} controlPoint1:(CGPoint){OFFSET/1.38f,rect.size.height - (CORNER_RADIUS/6.32f)} controlPoint2:(CGPoint){OFFSET/0.94f,rect.size.height - (CORNER_RADIUS/1.97f)}];
    [path addCurveToPoint:(CGPoint){OFFSET,rect.size.height - (CORNER_RADIUS/0.8f)} controlPoint1:(CGPoint){OFFSET*0.99f,rect.size.height - (CORNER_RADIUS/2.56f)} controlPoint2:(CGPoint){OFFSET*1.02f,rect.size.height - (CORNER_RADIUS/0.76f)}];
    [path closePath];

    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.fillColor = [[UIColor whiteColor] CGColor];
    maskLayer.backgroundColor = [[UIColor clearColor] CGColor];
    maskLayer.path = [path CGPath];
    if(bubbleType == BubbleTypeMine) {
        maskLayer.contentsGravity = kCAGravityCenter;
        maskLayer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
        maskLayer.position = (CGPoint) {rect.size.width, 0};
    }
    return maskLayer;
}

- (void)layoutSubviews
{
    self.layer.mask = nil;
    self.layer.mask = [HPChatBubbleView maskWithRect:self.bounds andType:self.bubbleType];
    [super layoutSubviews];
}

- (void)setBubbleType:(BubbleType)bubbleType {
    if(_bubbleType!=bubbleType){
        _bubbleType = bubbleType;
        [self layoutSubviews];
    }
}

@end