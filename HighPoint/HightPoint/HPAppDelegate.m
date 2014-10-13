//
//  HPAppDelegate.m
//  HightPoint
//
//  Created by Andrey Anisimov on 17.04.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "HPAppDelegate.h"
#import "Utils.h"
#import "HPRootViewController.h"
#import "HPBaseNetworkManager.h"
#import "UINavigationController+HighPoint.h"
#import <HockeySDK/HockeySDK.h>
#import "URLs.h"
#import "UserTokenUtils.h"
#import "HPSplashViewController.h"
#import "HPAuthorizationViewController.h"


//==============================================================================

@implementation HPAppDelegate

//==============================================================================

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

//==============================================================================

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"HightPoint.sqlite"];
    _managedObjectContext = [NSManagedObjectContext MR_defaultContext];
    
    [URLs isServerUrlSetted];
    
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"b209e48e58a6fe3f6737b5fee1d95f4d"];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
    
    
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName: @"Storyboard_568" bundle: nil];
    if ([UserTokenUtils getUserToken]) {
        HPSplashViewController* splashViewController = [storyBoard instantiateViewControllerWithIdentifier: @"HPSplashViewController"];
         self.navigationController = [[UINavigationController alloc] initWithRootViewController:splashViewController];
    } else {
        HPAuthorizationViewController* authViewController = [storyBoard instantiateViewControllerWithIdentifier: @"auth"];
        self.window.rootViewController = authViewController;
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:authViewController];
    }

    [self managedObjectContext];

    [self.navigationController hp_configureNavigationBar];
    
    [self.window setRootViewController:self.navigationController];
    
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [MagicalRecord cleanUp];
    [self saveContext];
}



- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Error: Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

//==============================================================================

#pragma mark - Core Data stack -

//==============================================================================

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

//==============================================================================

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"HightPoint" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

//==============================================================================

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"HightPoint.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Error: Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

//==============================================================================

#pragma mark - Application's Documents directory -

//==============================================================================

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

//==============================================================================

@end
