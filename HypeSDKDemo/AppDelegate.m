//
//  AppDelegate.m
//  HypeSDKDemo
//
//  Created by RJ Patawaran on 9/15/15.
//  Copyright (c) 2015 Entropy Soluction. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //[[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    //[application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    [application setMinimumBackgroundFetchInterval:60];
    
    [application registerForRemoteNotifications];
    [HypeSDK setupWithAPIKey:@"a818ee80-1417-48c4-bf2e-3a5d869996d2"]; //f4c65073-5edf-4a11-a45e-e48174f2b931
    
    NSString *storyboardId = [[HypeSDK sharedInstance] isActivated] ? @"Main" : @"Registration";
    [self showViewControllerWithIdentifier:storyboardId];

    return YES;
}

- (void)showViewControllerWithIdentifier:(NSString*)storyboardId
{
    self.window.rootViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:storyboardId];
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    [[HypeSDK sharedInstance] registerAPNSToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[HypeSDK sharedInstance] didReceiveRemoteNotification:userInfo];
    if ([application applicationState] == UIApplicationStateActive) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *alertMessage = [userInfo valueForKeyPath:@"aps.alert"];
            if (alertMessage != nil) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Promo"
                                                                    message:alertMessage
                                                                   delegate:self
                                                          cancelButtonTitle:@"Close"
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        });
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if ([[userInfo objectForKey:@"type"] isEqualToString:@"promo"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HypeDemoOpenPromo" object:nil userInfo:userInfo];
    }
}


- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"BACKGROUND FETCH!!!!");
    [[HypeSDK sharedInstance] fetchNewDataWithCompletionHandler:^(UIBackgroundFetchResult result) {
        NSLog(@"RESULT");
        completionHandler(result);
    }];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
