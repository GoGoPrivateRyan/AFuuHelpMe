//
//  AppDelegate.m
//  AFuuHelpMe
//
//  Created by Ryan Tseng on 2014/11/25.
//  Copyright (c) 2014年 RyanTseng. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Just for showing launch image longer
    [NSThread sleepForTimeInterval:2]; //add 2 seconds longer.

    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    // Override point for customization after application launch.
    NSUUID *beaconUUID = [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"];
    NSString *regionIdentifier = @"gogo.iBeacon";
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beaconUUID identifier:regionIdentifier];

    //beaconRegion.notifyEntryStateOnDisplay = YES;
    
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusAuthorizedAlways:
            NSLog(@"Authorized Always");
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"Authorized when in use");
            break;
        case kCLAuthorizationStatusDenied:
            NSLog(@"Denied");
            break;
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"Not determined");
            break;
        case kCLAuthorizationStatusRestricted:
            NSLog(@"Restricted");
            break;
            
        default:
            break;
    }
    
    self.locationManager = [[CLLocationManager alloc] init];
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    self.locationManager.delegate = self;
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    [self.locationManager startMonitoringForRegion:beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:beaconRegion];
    [self.locationManager startUpdatingLocation];
    
    return YES;
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [manager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
    [self.locationManager startUpdatingLocation];
    
    NSLog(@"進入射程範圍");
    [self sendLocalNotificationWithMessage:@"進入射程範圍"];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [manager stopRangingBeaconsInRegion:(CLBeaconRegion*)region];
    [self.locationManager stopUpdatingLocation];
    
    NSLog(@"離開射程範圍");
    [self sendLocalNotificationWithMessage:@"離開射程範圍"];
}

-(void)sendLocalNotificationWithMessage:(NSString*)message {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = message;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    NSString *message = @"";
    
    ViewController *viewController = (ViewController*)self.window.rootViewController;
    viewController.beacons = beacons;
    
    if(beacons.count > 0) {
        CLBeacon *nearestBeacon = beacons.firstObject;
        if(nearestBeacon.proximity == self.lastProximity ||
           nearestBeacon.proximity == CLProximityUnknown) {
            return;
        }
        self.lastProximity = nearestBeacon.proximity;

        switch(nearestBeacon.proximity) {
            case CLProximityFar:
                message = @"阿福聽見你了";
                break;
            case CLProximityNear:
                message = @"阿福在附近";
                break;
            case CLProximityImmediate:
                message = @"阿福在你旁邊";
                break;
            case CLProximityUnknown:
                return;
        }
        
        NSString *ourPath = @"";
        
        viewController.imgCmdBulb.highlighted = NO;
        viewController.imgCmdChrome.highlighted = NO;
        viewController.imgCmdYoutube.highlighted = NO;
        
        if (nearestBeacon.minor.intValue == 1)
        {
            viewController.lblAction.text = @"萊恩大兵的部落格";
            viewController.imgCmdChrome.highlighted = YES;
            ourPath = @"http://gogoprivateryan.blogspot.tw/";
        }
        else if (nearestBeacon.minor.intValue == 2)
        {
            viewController.lblAction.text = @"來點音樂";
            viewController.imgCmdYoutube.highlighted = YES;
            ourPath = @"http://www.youtube.com/watch?v=83I_5lq5MwI";
        }
        else if (nearestBeacon.minor.intValue == 3)
        {
            viewController.lblAction.text = @"遙控燈泡君";
            viewController.imgCmdBulb.highlighted = YES;
            ourPath = @"bulbcontrol://?cmd=1";
        }
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:ourPath]])
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:ourPath]];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"URL error" message:[NSString stringWithFormat: @"No custom URL defined for %@", [NSURL URLWithString:ourPath]] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        
    } else {
        //message = @"偵測不到 iBeacon.";
    }
    
    NSLog(@"%@", message);
    [self sendLocalNotificationWithMessage:message];
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
