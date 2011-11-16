//
//  AppDelegate.h
//  Bar Finder
//
//  Created by P. Mark Anderson on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Couchbase/CouchbaseMobile.h>
#import <CouchCocoa/CouchCocoa.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate,CouchbaseDelegate>
{
    IBOutlet UITabBarController *tabBarController;
    CouchPersistentReplication* _pull;
    CouchDatabase *db;

    NSURL *dbServerURL;
}

@property (strong, nonatomic) IBOutlet UIWindow *window;

@property (strong, nonatomic) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) CouchServer *server;

@end
