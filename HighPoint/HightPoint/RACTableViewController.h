//
// Created by Eugene on 28.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol RACTableViewCellProtocol
- (void)bindViewModel:(id)viewModel;
@end

@interface RACTableViewController : UITableViewController
- (void)configureTableViewWithSignal:(RACSignal *)source andTemplateCell:(UINib *)templateCellNib;
@end