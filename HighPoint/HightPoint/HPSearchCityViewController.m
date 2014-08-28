//
// Created by Eugene on 28.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPSearchCityViewController.h"
#import "HPBaseNetworkManager.h"
#import "UITextField+HighPoint.h"
#import "City.h"

@interface HPSearchCityViewController()
@property (nonatomic, weak) IBOutlet UITextField * searchBar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem * cancelBarButton;
@property(nonatomic, retain) NSMutableDictionary *cacheDictionary;
@end

@implementation HPSearchCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    RACChannelTo(self,selectRowSignal) = RACChannelTo(self,returnSignal);
    self.navigationItem.leftBarButtonItem = [self barItemCancelEditText];

    [self.searchBar.rac_textReturnSignal subscribeNext:^(UITextField *x) {
        [x resignFirstResponder];
    }];

    RACSignal * tableViewSignal = [[[self.searchBar.rac_textSignal throttle:0.3] flattenMap:^RACStream *(NSString* value) {
        return [self getCitiesBySearchString:value];
    }] catch:^RACSignal *(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:error.domain delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
        return [RACSignal empty];
    }];

    [self configureTableViewWithSignal:tableViewSignal andTemplateCell:[UINib nibWithNibName:@"HPSearchCityCell" bundle:nil]];

    [self.searchBar becomeFirstResponder];
}

- (RACSignal *) getCitiesBySearchString:(NSString*) string{
    if (!self.cacheDictionary)
        self.cacheDictionary = [NSMutableDictionary new];

    if (!self.cacheDictionary[string]) {
        self.cacheDictionary[string] = [[[HPBaseNetworkManager sharedNetworkManager] rac_findGeoLocationWithSearchString:string] replayLast];
    }

    return self.cacheDictionary[string];
}


- (UIBarButtonItem *)barItemCancelEditText {
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] init];
    leftBarItem.title = @"Отменить";
    [leftBarItem setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"FuturaPT-Light" size:18]} forState:UIControlStateNormal];
    @weakify(self);
    leftBarItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        [self.navigationController popViewControllerAnimated:YES];
        return [RACSignal empty];
    }];
    return leftBarItem;
}

@end