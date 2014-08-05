//
//  HPAddNewTownView.h
//  HighPoint
//
//  Created by Andrey Anisimov on 01.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HPAddNewTownView;
@protocol  HPAddNewTownViewDelegate <NSObject>
- (void) showNextView:(HPAddNewTownView*) view;
@end

@interface HPAddNewTownView : UIView
@property (nonatomic, weak) id<HPAddNewTownViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIImageView *addImg;
@property (nonatomic, weak) IBOutlet UIImageView *addImgTap;
@property (nonatomic, weak) IBOutlet UILabel *label;
+ (id) createView;
- (void) configureView;
- (IBAction)buttonTapDown:(id)sender;
- (IBAction)buttonTapUp:(id)sender;
@end
