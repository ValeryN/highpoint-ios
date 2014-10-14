//
// Created by Eugene on 02.09.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol RACCollectionViewCellProtocol
- (void)bindViewModel:(id)viewModel;
@end

@interface RACFetchedCollectionViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate, NSFetchedResultsControllerDelegate>
@property (nonatomic, retain) RACSignal * selectRowSignal;
- (void)configureCollectionView: (UICollectionView*) collectionView withSignal:(RACSignal *)source andTemplateCell:(UINib *)templateCellNib;
@end