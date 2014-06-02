//
//  HPUserProfileViewController.h
//  HighPoint
//
//  Created by Andrey Anisimov on 27.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import <UIKit/UIKit.h>

//==============================================================================

@protocol  HPUserProfileViewControllerDelegate <NSObject>
- (void)profileWillBeHidden;
@end

//==============================================================================

@interface HPUserProfileViewController : UIViewController
@property (nonatomic, weak) IBOutlet UIButton *downButton;
@property (nonatomic, weak) IBOutlet UIView *barView;
@property (nonatomic, weak) id<HPUserProfileViewControllerDelegate> delegate;
- (IBAction)downButtonTap:(id)sender;
@end
