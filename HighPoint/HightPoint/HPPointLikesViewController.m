//
//  HPPointLikesViewController.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 21.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPPointLikesViewController.h"
#import "HPPointLikeCollectionViewCell.h"
#import "User.h"
#import "NSManagedObjectContext+HighPoint.h"
#import "UINavigationBar+HighPoint.h"
#import "HPBaseNetworkManager+Reference.h"
#import "HPUserInfoViewController.h"
#import "DataStorage.h"


@interface HPPointLikesViewController ()
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultController;
@end

@implementation HPPointLikesViewController

- (NSFetchedResultsController *) fetchedResultController{
    if (!_fetchedResultController){
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"User"];
        [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ANY likedPosts == %@", self.user.point]];
        _fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[NSManagedObjectContext threadContext] sectionNameKeyPath:nil cacheName:nil];
        if (![_fetchedResultController performFetch:nil]) {
            NSAssert(false, @"Error occurred");
        }
        _fetchedResultController.delegate = self;
    }
    return _fetchedResultController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureCollectionViewWithSignal:RACObserve(self, fetchedResultController) andTemplateCell:[UINib nibWithNibName:@"HPPointLikeCollectionViewCell" bundle:nil]];
    [self configureNavigationBar];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - navigation bar

- (void)configureNavigationBar {

    [RACObserve(self, navigationController.navigationBar) subscribeNext:^(UINavigationBar * x) {
        [x configureTranslucentNavigationBar];
    }];

    self.navigationItem.title = NSLocalizedString(@"POINT_LIKES_TITLE", nil);
    UIBarButtonItem* backButton = [self createBarButtonItemWithImage:[UIImage imageNamed:@"Down.png"]
                                                     highlighedImage:[UIImage imageNamed:@"Down Tap.png"]
                                                              action:@selector(backButtonTaped:)];
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
    
    UIBarButtonItem*newButtonItem = [[UIBarButtonItem alloc] initWithCustomView: newButton];
    
    return newButtonItem;
}

- (void)backButtonTaped: (id) sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionView Datasource

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    User * usr = [[self.fetchedResultController fetchedObjects] objectAtIndex:indexPath.row];
    if(usr) {
        [[HPBaseNetworkManager sharedNetworkManager] makeReferenceRequest:[[DataStorage sharedDataStorage] prepareParamFromUser:usr]];
    }
    HPUserInfoViewController* uiController = [[HPUserInfoViewController alloc] initWithNibName: @"HPUserInfoViewController" bundle: nil];
    uiController.user = [[self.fetchedResultController fetchedObjects] objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:uiController animated:YES];
}

@end
