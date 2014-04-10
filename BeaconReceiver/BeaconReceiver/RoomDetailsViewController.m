//
//  RoomDetailsViewController.m
//  BeaconReceiver
//
//  Created by Yuwei Xia on 4/9/14.
//  Copyright (c) 2014 Citigroup. All rights reserved.
//

#import "RoomDetailsViewController.h"
#import "BookViewController.h"
#import "Beacon.h"
#import "Room.h"
#import "Booking.h"

@interface RoomDetailsViewController ()

@property (nonatomic, strong) Room *room;
@property (nonatomic, strong) NSMutableArray *bookings;

@end

@implementation RoomDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    NSString *majorString = self.beacon.major.stringValue;
    NSString *minorString = self.beacon.minor.stringValue;
    
    NSString* url = [NSString stringWithFormat:@"http://yuweixia.local:8888/%@/%@/redirect", majorString, minorString];
    NSURL *jsonURL = [NSURL URLWithString:url];
    NSData *jsonData = [NSData dataWithContentsOfURL:jsonURL];
    //NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //NSLog(@"%@", jsonString);
    NSDictionary *twoObjects = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    
    //NSString *roomDetails = [NSString stringWithFormat:@"%@", [twoObjects objectForKey:@"roomDetails"]];
    NSDictionary *roomDetails = [twoObjects objectForKey:@"roomDetails"];
    NSDictionary *bookings = [twoObjects objectForKey:@"bookings"];
    //    NSLog(@"%@", roomDetails);
    //    NSLog(@"%@", bookings);
    
    self.room = [[Room alloc] initWithRoomDictionary:roomDetails];
    
    NSArray *bookingArray = [bookings objectForKey:@"bookings"];
    self.bookings = [[NSMutableArray alloc] init];
    for (NSDictionary *bookingJson in bookingArray) {
        Booking *booking = [[Booking alloc] initWithBookingDictionary:bookingJson];
        [self.bookings addObject:booking];
    }
    
    
    //    NSLog(@"1------ %@", self.room.name);
    //    NSLog(@"1------ %@", self.room.location);
    //    NSLog(@"1------ %@", [NSString stringWithFormat:@"%d", self.room.capacity]);
    //    NSLog(@"1------ %@", self.room.phoneNumber.stringValue);
    //    NSLog(@"1------ %@", self.room.owner);
    //    NSLog(@"1------ %@", (self.room.conferencing) ? @"Yes" : @"No");
    self.name.text = self.room.name;
    self.location.text = self.room.location;
    self.capacity.text = [NSString stringWithFormat:@"%d", self.room.capacity];
    self.phone.text = self.room.phoneNumber.stringValue;
    
    
//    if ([self.room.name isEqual: @"solas"]) {
//        self.cardButton.backgroundColor = [UIColor colorWithRed:145.0/255.0 green:188.0/255.0 blue:161.0/255.0 alpha:1.0];
//    } else if ([self.room.name isEqual:@"nova"]) {
//        self.cardButton.backgroundColor = [UIColor colorWithRed:43.0/255.0 green:42.0/255.0 blue:83.0/255.0 alpha:1.0];
//        
//    } else if ([self.room.name isEqual:@"scotia"]) {
//        self.cardButton.backgroundColor = [UIColor colorWithRed:99.0/255.0 green:181.0/255.0 blue:218.0/255.0 alpha:1.0];
//        
//    }
    
//    self.owner.text = self.room.owner;
//    self.conference.text = (self.room.conferencing) ? @"Yes" : @"No";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"BookTheRoom"]) {
        NSLog(@"Book the room...");
        BookViewController *bookViewController = [segue destinationViewController];
        NSLog(@"1...");
        bookViewController.room = self.room;
        bookViewController.bookings = self.bookings;
        NSLog(@"2...");
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
