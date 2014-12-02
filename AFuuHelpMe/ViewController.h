//
//  ViewController.h
//  AFuuHelpMe
//
//  Created by Ryan Tseng on 2014/11/25.
//  Copyright (c) 2014年 RyanTseng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong) NSArray *beacons;
@property (weak, nonatomic) IBOutlet UILabel *lblAction;
@property (weak, nonatomic) IBOutlet UIImageView *imgCmdChrome;
@property (weak, nonatomic) IBOutlet UIImageView *imgCmdYoutube;
@property (weak, nonatomic) IBOutlet UIImageView *imgCmdBulb;

@end

