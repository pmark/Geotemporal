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
@synthesize tabBarController = _tabBarController;
@synthesize server;

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
    arnav.tabBarItem.image = [UIImage imageNamed:@"3dar.png"];
    
    UIViewController *settingsvc = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    UINavigationController *settingsnav = [[UINavigationController alloc] initWithRootViewController:settingsvc];
    settingsnav.title = @"Settings";
    settingsnav.tabBarItem.image = [UIImage imageNamed:@"19-gear.png"];
    

    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:listnav, mapnav, arnav, settingsnav, nil];
    
    self.window.rootViewController = self.tabBarController;
        
    [self.window makeKeyAndVisible];
    
    CouchbaseMobile* cb = [[CouchbaseMobile alloc] init];
    cb.delegate = self;
    
    NSAssert([cb start], @"Couchbase didn't start! Error = %@", cb.error);
    
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



- (void) runQuery
{
    NSLog(@"The db server url: %@", [dbServerURL absoluteString]);
    
//    NSString *strURL = [NSString stringWithFormat:@"%@barfinder/_design/geo/_spatial/full?bbox=-122.7,45.5,-122.6,45.6", [dbServerURL absoluteString]];
    
//    CouchQuery *query = [[CouchQuery alloc] initWithURL:[NSURL URLWithString:strURL]];
    
    
    CouchDesignDocument* design = [db designDocumentWithName:@"geo"];
    design.language = kCouchLanguageJavaScript;
    [design defineViewNamed: @"spatial"
                        map: @"function(doc) { if (doc.loc) { emit(doc._id, { type: \"Point\", coordinates: [doc.loc[0], doc.loc[1]] }); }};"];
     

    CouchQuery *query = [design queryViewNamed:@"spatial"];


    
    RESTOperation *op = [query start];
    
    if (![op wait] && op.httpStatus != 412) 
    {   // 412 = Conflict; just means DB already exists
        // TODO: Report error
        NSLog(@"OMG: Couldn't query database: %@", op.error);
    }
    else

    {
        CouchQueryEnumerator *results = op.resultObject;

        for (CouchQueryRow *row in [query rows]) 
        {
            NSLog(@"row: %@, %@", row.key, row);
//            Bar *bar = [Bar modelForDocument:row.document];
//            [mutableFetchResults addObject:bar];
        }

        NSLog(@"results: %@", results);
    }
}

-(void)couchbaseMobile:(CouchbaseMobile*)couchbase didStart:(NSURL*)serverURL 
{
    dbServerURL = serverURL;
    NSLog(@"Couchbase is Ready, go! %@", serverURL);

#ifdef DEBUG
    gCouchLogLevel = 1;  // Turn on some basic logging in CouchCocoa
#endif
    
    if (!self.server) 
    {
        // Do this the first time the server starts, i.e. not after a wake-from-bg:
        self.server = [[CouchServer alloc] initWithURL: serverURL];

        NSString* dbPath = [[NSBundle mainBundle] pathForResource:@"barfinder" ofType:@"couch"];
        NSAssert(dbPath, @"Couldn't find barfinder.couch");
        
        [couchbase installDefaultDatabase:dbPath];
        
        


        db = [self.server databaseNamed: @"barfinder"];
        
        RESTOperation *op = [db create];

        if (![op wait] && op.httpStatus != 412) 
        {   // 412 = Conflict; just means DB already exists
            // TODO: Report error
            NSLog(@"OMG: Couldn't create database: %@", op.error);
            exit(1);    // Panic!
        }
        

        /*
        // sync, but not every time. just sync so we can get the datas.
        NSURL *url = [NSURL URLWithString:@"http://login:password@boxelder.couchone.com/barfinder"];
//        CouchReplication *replication = [database pullFromDatabaseAtURL:url options:kCouchReplicationCreateTarget];
        
        NSArray* repls = [db replicateWithURL:url exclusively:YES];
        
        _pull = [repls objectAtIndex: 0];
//        _push = [repls objectAtIndex: 1];
        
        [_pull addObserver: self forKeyPath: @"completed" options: 0 context: NULL];
//        [_push addObserver: self forKeyPath: @"completed" options: 0 context: NULL];
         */

        
    }
    
    NSLog(@"\n\n\n\nDoc count: %i\n\n\n\n", [db getDocumentCount]);
    
    [self runQuery];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object 
                         change:(NSDictionary *)change context:(void *)context
{
    if (object == _pull) {
        unsigned completed = _pull.completed;
        unsigned total = _pull.total;

        NSLog(@"SYNC progress: %u / %u", completed, total);
        
        if (total > 0 && completed < total) 
        {
            db.server.activityPollInterval = 0.5;   // poll often while progress is showing
        } 
        else 
        {
            db.server.activityPollInterval = 2.0;   // poll less often at other times
        }
    }
}
         
-(void)couchbaseMobile:(CouchbaseMobile*)couchbase failedToStart:(NSError*)error 
{
    NSAssert(NO, @"Couchbase failed to initialize: %@", error);
}

@end
