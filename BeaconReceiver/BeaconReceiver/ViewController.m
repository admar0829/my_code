//
//  ViewController.m
//  BeaconReceiver
//
//  Created by Yuwei Xia on 3/19/14.
//  Copyright (c) 2014 Citigroup. All rights reserved.
//

#import "ViewController.h"
#import "RoomDetailsViewController.h"
#import "ESTBeaconManager.h"
#import "Room.h"

#import "Beacon.h"

@interface ViewController () <ESTBeaconManagerDelegate>

@property (strong, nonatomic) ESTBeacon *beacon;

//@property (strong, nonatomic) NSArray *beacons;
@property (strong, nonatomic) NSMutableArray *beacons;
@property (strong, nonatomic) ESTBeaconManager *beaconManager;
@property (strong, nonatomic) ESTBeaconRegion *beaconRegion;

//for keep the mac address of detected beacons, mac address is null, use minor
@property (strong, nonatomic) NSMutableArray *minors;

@end

@interface ESTTableViewCell : UITableViewCell
@end

@implementation ESTTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.beacons = [NSMutableArray array];
    self.minors = [NSMutableArray array];
    
    //[self.tableView registerClass:[ESTTableViewCell class] forCellReuseIdentifier:@"CellIdentifier"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    self.beaconRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID identifier:@"EstimoteSampleRegion"];
    [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region {
//    ESTBeacon *beacon = [[ESTBeacon alloc] init];
//    beacon.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
//    beacon.major = [[NSNumber alloc] initWithInt:555];
//    beacon.minor = [[NSNumber alloc] initWithInt:6789];
//    beacon.distance = [[NSNumber alloc] initWithFloat:2.15];
//    
//    NSMutableArray *mutableArray = [NSMutableArray new];
//    [mutableArray addObject:beacon];
//    self.beacons = [mutableArray mutableCopy];

    for (ESTBeacon *detectedbeacon in beacons) {
        if (![self.minors containsObject:detectedbeacon.minor.stringValue]) {
            [self.minors addObject:detectedbeacon.minor.stringValue];
            [self.beacons addObject:detectedbeacon];
            [self.tableView reloadData];
        }
    }
    
    //self.beacons = beacons;
    //[self.tableView reloadData];
    //NSLog(@"%d", beacons.count);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.beacons count];
    //return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //ESTTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    ESTBeacon *beacon = [self.beacons objectAtIndex:indexPath.row];
    NSString *majorString = beacon.major.stringValue;
    NSString *minorString = beacon.minor.stringValue;
    
    
    
    NSString* beaconURL = [NSString stringWithFormat:@"http://yuweixia.local:8888/%@/%@", majorString, minorString];
    
    NSURL *jsonBeaconURL = [NSURL URLWithString:beaconURL];
    NSData *jsonBeaconData = [NSData dataWithContentsOfURL:jsonBeaconURL];
    
    NSDictionary *beaconObject = [NSJSONSerialization JSONObjectWithData:jsonBeaconData options:0 error:nil];
    
    Beacon *ibeacon = [[Beacon alloc] initWithBeaconDictionary:beaconObject];

    NSString* roomURL = [NSString stringWithFormat:@"http://yuweixia.local:8888/rooms/%@", ibeacon.room];
    
    NSURL *jsonRoomURL = [NSURL URLWithString:roomURL];
    NSData *jsonRoomData = [NSData dataWithContentsOfURL:jsonRoomURL];
    
    NSDictionary *twoObjects = [NSJSONSerialization JSONObjectWithData:jsonRoomData options:0 error:nil];
    
    NSDictionary *roomDetails = [twoObjects objectForKey:@"roomDetails"];
    //NSDictionary *bookings = [twoObjects objectForKey:@"bookings"];
    NSString *available = [twoObjects objectForKey:@"available"];

    Room *room = [[Room alloc] initWithRoomDictionary:roomDetails];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", room.name];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", available];
    
    if ([ibeacon.color isEqual: @"darkblue"]) {
        cell.backgroundColor = [UIColor colorWithRed:145.0/255.0 green:188.0/255.0 blue:161.0/255.0 alpha:1.0];
    } else if ([ibeacon.color isEqual:@"green"]) {
        cell.backgroundColor = [UIColor colorWithRed:43.0/255.0 green:42.0/255.0 blue:83.0/255.0 alpha:1.0];

    } else if ([ibeacon.color isEqual:@"blue"]) {
        cell.backgroundColor = [UIColor colorWithRed:99.0/255.0 green:181.0/255.0 blue:218.0/255.0 alpha:1.0];

    }
    
//    cell.textLabel.text = [NSString stringWithFormat:@"Major: %@, Minor: %@", beacon.major, beacon.minor];
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance: %.2f", [beacon.distance floatValue]];
    
    return cell;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    ESTBeacon *selectedBeacon = [self.beacons objectAtIndex:indexPath.row];
//    
//    
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowDetails"]) {
        NSLog(@"go to detail...");
        RoomDetailsViewController *roomDetailsViewController = [segue destinationViewController];
        
        roomDetailsViewController.beacon = [self.beacons objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    }
}

@end
