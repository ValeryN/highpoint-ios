//
// Created by Eugene on 28.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol RACTableViewCellProtocol
- (void)bindViewModel:(id)viewModel;
@optional
+ (CGFloat) heightForRowWithModel:(id) model;
@end

@interface RACTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) RACSignal * selectRowSignal;
- (void)configureTableView:(UITableView *)tableView withSignal:(RACSignal *)source andTemplateCell:(UINib *)templateCellNib;
@end