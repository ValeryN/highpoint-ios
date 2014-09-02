//
// Created by Eugene on 02.09.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol RACCollectionViewCellProtocol
- (void)bindViewModel:(id)viewModel;
@end

@interface RACFetchedCollectionViewController : UICollectionViewController<UICollectionViewDataSource, NSFetchedResultsControllerDelegate>
@property (nonatomic, retain) RACSignal * selectRowSignal;
- (void)configureCollectionViewWithSignal:(RACSignal *)source andTemplateCell:(UINib *)templateCellNib;
@end