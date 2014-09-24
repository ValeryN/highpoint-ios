//
// Created by Eugene on 28.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RACFetchedTableViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) RACSignal * selectRowSignal;
- (void)configureTableView:(UITableView*) tableView withSignal:(RACSignal *)source andTemplateCell:(UINib *)templateCellNib;
- (UITableViewCell*)addTemplateCell:(UINib *)templateCellNib;
- (NSString*)cellIdentifierForModel:(id)model;

@property (nonatomic) BOOL cachedCellHeight;
@end