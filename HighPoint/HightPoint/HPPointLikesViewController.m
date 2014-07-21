//
//  HPPointLikesViewController.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 21.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPPointLikesViewController.h"
#import "UINavigationController+HighPoint.h"
#import "HPPointLikeCollectionViewCell.h"

@interface HPPointLikesViewController ()

@end

@implementation HPPointLikesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.likesCollectionView.delegate = self;
    self.likesCollectionView.dataSource = self;
    
    [self.likesCollectionView registerNib:[UINib nibWithNibName:@"HPPointLikeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"PointLikesCell"];

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureNabBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - navigation bar

- (void) configureNabBar {
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.title = NSLocalizedString(@"POINT_LIKES_TITLE", nil);
    [self.navigationController hp_configureNavigationBar];
    UIBarButtonItem* backButton = [self createBarButtonItemWithImage: [UIImage imageNamed:@"Down.png"]
                                                     highlighedImage: [UIImage imageNamed:@"Down Tap.png"]
                                                              action: @selector(backbuttonTaped:)];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (UIBarButtonItem*) createBarButtonItemWithImage: (UIImage*) image
                                  highlighedImage: (UIImage*) highlighedImage
                                           action: (SEL) action
{
    UIButton* newButton = [UIButton buttonWithType: UIButtonTypeCustom];
    newButton.frame = CGRectMake(0, 0, 22, 10);
    [newButton setBackgroundImage: image forState: UIControlStateNormal];
    [newButton setBackgroundImage: highlighedImage forState: UIControlStateHighlighted];
    [newButton addTarget: self
                  action: action
        forControlEvents: UIControlEventTouchUpInside];
    
    UIBarButtonItem* newbuttonItem = [[UIBarButtonItem alloc] initWithCustomView: newButton];
    
    return newbuttonItem;
}

- (void) backbuttonTaped: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}


#pragma mark - uicollection view

#pragma mark - UICollectionView Datasource
// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return 25;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HPPointLikeCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"PointLikesCell" forIndexPath:indexPath];
    [cell configureCell];
    return cell;
}

/*- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(106, 100);
}


- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

@end
