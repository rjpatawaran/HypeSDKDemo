//
//  AppDelegate.h
//  HypeSDKDemo
//
//  Created by RJ Patawaran on 9/15/15.
//  Copyright (c) 2015 Entropy Soluction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HypeSDK.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
- (void)showViewControllerWithIdentifier:(NSString*)storyboardId;

@end

