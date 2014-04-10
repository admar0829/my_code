//
//  RoomDetailsViewController.h
//  BeaconReceiver
//
//  Created by Yuwei Xia on 4/9/14.
//  Copyright (c) 2014 Citigroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESTBeaconManager.h"

@interface RoomDetailsViewController : UIViewController

@property (strong, nonatomic) ESTBeacon *beacon;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *location;
@property (strong, nonatomic) IBOutlet UILabel *capacity;
@property (strong, nonatomic) IBOutlet UILabel *phone;
//@property (strong, nonatomic) IBOutlet UIButton *cardButton;

@end
