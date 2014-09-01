//
//  HPBubbleTextField.h
//  HighPoint
//
//  Created by Andrey Anisimov on 05.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface HPBubbleTextField : UITextField <UIKeyInput>
@property (nonatomic, retain) RACSubject * backSpaceSignal;
@end
