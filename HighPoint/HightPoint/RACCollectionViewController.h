//
//  RACCollectionViewController.h
//  HighPoint
//
//  Created by Eugene on 30/10/14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RACCollectionViewController :  UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, retain) RACSignal * selectRowSignal;
- (void)configureCollectionView: (UICollectionView*) collectionView withSignal:(RACSignal *)source andTemplateCell:(UINib *)templateCellNib;
@end
