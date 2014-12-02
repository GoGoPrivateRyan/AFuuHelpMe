//
//  AppDelegate.h
//  AFuuHelpMe
//
//  Created by Ryan Tseng on 2014/11/25.
//  Copyright (c) 2014年 RyanTseng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property CLProximity lastProximity;

@end

