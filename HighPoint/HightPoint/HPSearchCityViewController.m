//
// Created by Eugene on 28.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPSearchCityViewController.h"
#import "HPBaseNetworkManager.h"

@interface HPSearchCityViewController()
@property (nonatomic, weak) IBOutlet UITextField * searchBar;
@end

@implementation HPSearchCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    RACSignal * tableViewSignal = [[[self.searchBar.rac_textSignal throttle:0.3] flattenMap:^RACStream *(NSString* value) {
        return [self getCitiesBySearchString:value];
    }] catch:^RACSignal *(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:error.domain delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
        return [RACSignal empty];
    }];
    [self configureTableViewWithSignal:tableViewSignal andTemplateCell:[UINib nibWithNibName:@"HPSearchCityCell" bundle:nil]];
}

- (RACSignal *) getCitiesBySearchString:(NSString*) string{
    return [[HPBaseNetworkManager sharedNetworkManager] rac_findGeoLocationWithSearchString:string];
}

@end