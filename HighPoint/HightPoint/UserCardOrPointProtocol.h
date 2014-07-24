//
//  UserCardOrPointProtocol.h
//  HighPoint
//
//  Created by Michael on 23.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import <Foundation/Foundation.h>

//==============================================================================

@protocol UserCardOrPointProtocol

- (void) switchButtonPressed;
- (void) configurePublishPointNavigationItem;
- (void) showNavigationItem;
- (void) hideNavigationItem;
- (void) configurePublishPointNavigationItem;
- (void) configureSendPointNavigationItem;
- (void) resizeChildContainer;

- (void) hideBottomBar;
- (void) showBottomBar;

- (void) maximizeChildContainer;
- (void) minimizeChildContainer;

- (void) showTopNavigationItems;
- (void) hideTopNavigationItems;


-(void) enableCarouselScroll;
-(void) disableCarouselScroll;

@end
