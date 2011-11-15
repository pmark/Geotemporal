//
//  AppDelegate.m
//  Bar Finder
//
//  Created by P. Mark Anderson on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "ListViewController.h"
#import "SettingsViewController.h"
#import "ARViewController.h"
#import "MapViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController;// = _tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    
    // Make nav controllers for each view controller.
    
    
    UIViewController *listvc = [[ListViewController alloc] initWithNibName:@"ListViewController" bundle:nil];
    UINavigationController *listnav = [[UINavigationController alloc] initWithRootViewController:listvc];
    listnav.title = @"List";
    listnav.tabBarItem.image = [UIImage imageNamed:@"179-notepad.png"];
    
    UIViewController *mapvc = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    UINavigationController *mapnav = [[UINavigationController alloc] initWithRootViewController:mapvc];
    mapnav.title = @"Map";
    mapnav.tabBarItem.image = [UIImage imageNamed:@"07-map-marker.png"];

    UIViewController *arvc = [[ARViewController alloc] initWithNibName:@"ARViewController" bundle:nil];
    UINavigationController *arnav = [[UINavigationController alloc] initWithRootViewController:arvc];
    arnav.title = @"3DAR";
    arnav.tabBarItem.image = [UIImage imageNamed:@"73-radar.png"];
    
    UIViewController *settingsvc = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    UINavigationController *settingsnav = [[UINavigationController alloc] initWithRootViewController:settingsvc];
    settingsnav.title = @"Settings";
    settingsnav.tabBarItem.image = [UIImage imageNamed:@"19-gear.png"];
    

    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:listnav, mapnav, arnav, settingsnav, nil];
    
    NSLog(@"\n\n\ntab bar view controllers: %@", self.tabBarController.viewControllers);
    
//    [self.window addSubview:self.tabBarController.view];
    self.window.rootViewController = self.tabBarController;
        
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
