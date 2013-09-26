//
//  SCHAppDelegate.m
//  SwingingChicken
//
//  Created by Josh Berlin on 9/25/13.
//  Copyright (c) 2013 josh. All rights reserved.
//

#import "SCHAppDelegate.h"

#import "SCHViewController.h"

@implementation SCHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  SCHViewController *chickenViewController = [[SCHViewController alloc] init];
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.rootViewController = chickenViewController;
  [self.window makeKeyAndVisible];
  return YES;
}

@end
