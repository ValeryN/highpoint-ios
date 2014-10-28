//
//  HPPointLikesViewController.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 21.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPPointLikesViewController.h"
#import "User.h"
#import "NSManagedObjectContext+HighPoint.h"
#import "UINavigationBar+HighPoint.h"
#import "HPBaseNetworkManager+Reference.h"
#import "HPUserInfoViewController.h"
#import "DataStorage.h"
#import "HPUserCardViewController.h"
#import "UIViewController+HighPoint.h"


@interface HPPointLikesViewController ()
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultController;
@property (nonatomic, weak) IBOutlet UITableView* tableView;
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
    @weakify(self);
    [super viewDidLoad];
    [self configureTableView:self.tableView withSignal:RACObserve(self, fetchedResultController) andTemplateCell:[UINib nibWithNibName:@"HPMainViewListTableViewCell" bundle:nil]];
    [self.selectRowSignal subscribeNext:^(User* x) {
        @strongify(self);
        HPUserCardViewController* cardController = [[HPUserCardViewController alloc] initWithController:self.fetchedResultController andSelectedUser:x];
        [self.navigationController pushViewController:cardController animated:YES];
    }];
    [self configureNavigationBar];
}


#pragma mark - navigation bar

- (void)configureNavigationBar {
    self.navigationItem.title = NSLocalizedString(@"POINT_LIKES_TITLE", nil);
    UIBarButtonItem* backButton = [self createBarButtonItemWithImage:[UIImage imageNamed:@"Back"]
                                                     highlighedImage:[UIImage imageNamed:@"Back Tap.png"]
                                                              action:@selector(backButtonTaped:)];
    self.navigationItem.leftBarButtonItem = backButton;
}


- (void)backButtonTaped: (id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    if(self.view.window == nil){
        self.view = nil;
    }
}

@end
