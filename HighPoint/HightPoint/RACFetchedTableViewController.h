//
// Created by Eugene on 28.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RACFetchedTableViewController : UITableViewController
@property (nonatomic, retain) RACSignal * selectRowSignal;
- (void)configureTableViewWithSignal:(RACSignal *)source andTemplateCell:(UINib *)templateCellNib;
@end