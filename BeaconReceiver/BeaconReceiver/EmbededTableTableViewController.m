//
//  EmbededTableTableViewController.m
//  BeaconReceiver
//
//  Created by Yuwei Xia on 4/9/14.
//  Copyright (c) 2014 Citigroup. All rights reserved.
//

#import "EmbededTableTableViewController.h"

@interface EmbededTableTableViewController ()

@property (nonatomic, weak) NSMutableData *responseData;

@property (nonatomic, strong) NSMutableArray *timeSlots;

@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;

@end

@implementation EmbededTableTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTheInputView:)];
    
    [self.tableView addGestureRecognizer:tap];
    
    self.timeSlots = [[NSMutableArray alloc] initWithObjects:@"9-10", @"10-11", @"11-12", @"12-13", @"13-14", @"14-15", @"15-16", @"16-17", nil];
    
    self.timeTF.text = @"9-10";
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:today];
    self.dateTF.text = [NSString stringWithFormat:@"%@", dateString];
    [self getAvailableTimeSlotsForTheDate:dateString];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.minuteInterval = 30;
    [datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    [self.dateTF setInputView:datePicker];
    
    
    self.pickerView = [[UIPickerView alloc] init];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    [self.timeTF setInputView:self.pickerView];
}


- (NSArray *)getAvailableTimeSlotsForTheDate: (NSString *)dateString {
    
    NSString *url = [NSString stringWithFormat:@"http://yuweixia.local:8888/rooms/%@/booking/%@", self.room.name, dateString];
    NSURL *jsonURL = [NSURL URLWithString:url];
    NSData *jsonData = [NSData dataWithContentsOfURL:jsonURL];
    
    NSArray *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    
    for (NSDictionary *bookingDict in jsonDict) {
        NSString *startTime = [bookingDict objectForKey:@"StartT"];
        NSString *endTime = [bookingDict objectForKey:@"EndT"];
        NSString *timeSlot = [NSString stringWithFormat:@"%@-%@", startTime, endTime];
        //NSLog(@"%@", timeSlot);
        [self.timeSlots removeObject:timeSlot];
    }
    
    //NSMutableArray *availableTimeSlots = [NSMutableArray array];
    
    return self.timeSlots;
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.timeSlots.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.timeSlots objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //NSLog(@"selected row %d", row);
    self.timeTF.text = [self.timeSlots objectAtIndex:row];
}

-(void)updateTextField:(id)sender {
    UIDatePicker *datePicker = (UIDatePicker *)self.dateTF.inputView;
    NSDate *selectedDate = datePicker.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *newDate = [dateFormatter stringFromDate:selectedDate];
    self.dateTF.text = [NSString stringWithFormat:@"%@", newDate];
    [self getAvailableTimeSlotsForTheDate:newDate];
    [self.pickerView reloadAllComponents];
}

- (void)dismissTheInputView:(id)sender {
    [self.tableView endEditing:YES];
    
}
@end
