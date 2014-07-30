//
//  Message.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 25.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestMessage : NSObject


@property (strong, nonatomic) NSString *messageBody;
@property (strong, nonatomic) NSString *sendTime;
@property (assign, nonatomic) BOOL isIncoming;

@end
