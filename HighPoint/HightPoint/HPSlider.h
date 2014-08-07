//
//  HPSlider.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 06.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HPSliderTimeView;

@interface HPSlider : UISlider {
    HPSliderTimeView *timePopupView;
}

@property (nonatomic, readonly) CGRect thumbRect;


- (void) initOnLoad;

@end
