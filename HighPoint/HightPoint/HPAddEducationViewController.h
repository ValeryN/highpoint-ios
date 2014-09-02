//
//  HPAddEducationViewController.h
//  HighPoint
//
//  Created by Andrey Anisimov on 04.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  HPAddEducationViewControllerDelegate <NSObject>
- (void) newEducationSelected:(NSArray*) edu;
- (void) newWorkPlaceSelected:(NSArray*) place;
@end

@interface HPAddEducationViewController : UIViewController <UITextFieldDelegate>


@property (nonatomic, assign) BOOL isItForEducation;

@property (nonatomic, weak) id<HPAddEducationViewControllerDelegate> delegate;
@end
