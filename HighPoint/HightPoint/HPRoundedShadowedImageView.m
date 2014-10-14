//
//  HPRoundedShadowedImageView.m
//  HighPoint
//
//  Created by Eugene on 09/10/14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPRoundedShadowedImageView.h"
@interface HPRoundedShadowedImageView()
@property (nonatomic) UIView * maskLayer;
@property (nonatomic) UIImageView* imageView;
@property (nonatomic) UIImageView* blendView;
@end

@implementation HPRoundedShadowedImageView

- (void)prepareForInterfaceBuilder{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *fileName = [bundle pathForResource:@"13" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:fileName];
    self.image = image;
    [self configure];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self configure];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)setImage:(UIImage *)image{
    _image = image;
     [self updateViews];
}

- (void)setBlendImage:(UIImage *)blendImage{
    _blendImage = blendImage;
    [self updateViews];
}

- (void) setCornerRadius:(CGFloat)cornerRadius{
    _cornerRadius = cornerRadius;
    [self updateViews];
}

- (void)setShadowRadius:(CGFloat)shadowRadius {
    _shadowRadius = shadowRadius;
    [self updateViews];
}
- (void)setShadowOpacity:(CGFloat)shadowOpacity{
    _shadowOpacity = shadowOpacity;
    [self updateViews];
}
- (void)setShadowOffset:(CGSize)shadowOffset{
    _shadowOffset = shadowOffset;
    [self updateViews];
}

- (void) configure{
    self.maskLayer = [[UIView alloc] initWithFrame:self.bounds];
    self.maskLayer.backgroundColor = [UIColor clearColor];
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.blendView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self.maskLayer addSubview:self.imageView];
    [self.maskLayer addSubview:self.blendView];
    [self addSubview:self.maskLayer];
    
    [self updateViews];
}

- (void) updateViews{
    self.imageView.image = _image;
    self.blendView.image = _blendImage;
    self.maskLayer.layer.masksToBounds = YES;
    self.maskLayer.layer.cornerRadius = _cornerRadius;
    self.layer.masksToBounds = NO;
    [[self layer] setCornerRadius:_cornerRadius];
    [[self layer] setShadowPath:[[UIBezierPath bezierPathWithRoundedRect:[self.imageView bounds]
                                        cornerRadius:_cornerRadius] CGPath]];
    [[self layer] setShadowOpacity:_shadowOpacity];
    [[self layer] setShadowRadius:_shadowRadius];
    [[self layer] setShadowOffset:_shadowOffset];
}

@end
