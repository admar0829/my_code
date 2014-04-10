//
//  BookViewController.m
//  BeaconReceiver
//
//  Created by Yuwei Xia on 4/4/14.
//  Copyright (c) 2014 Citigroup. All rights reserved.
//

#import "BookViewController.h"
#import "EmbededTableTableViewController.h"

@interface BookViewController ()
@property (nonatomic, weak) NSMutableData *responseData;
@end

@implementation BookViewController

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
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)saveTheBooking:(id)sender {
    EmbededTableTableViewController *embededTableTableViewController =  self.childViewControllers.lastObject;
    NSLog(@"%@", embededTableTableViewController.timeTF.text);
    
    if (![embededTableTableViewController.timeTF.text isEqualToString:@""] && ![embededTableTableViewController.meetingNameTF.text isEqualToString:@""] && ![embededTableTableViewController.usersTF.text isEqualToString:@""]) {
        NSString *urlString = [NSString stringWithFormat:@"http://yuweixia.local:8888/rooms/%@/booking", self.room.name];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:@"POST"];
        NSString *date = embededTableTableViewController.dateTF.text;
        NSString *timeslot = embededTableTableViewController.timeTF.text;
        NSArray *timeArray = [timeslot componentsSeparatedByString:@"-"];
        NSString *startTime = timeArray[0];
        NSString *endTime = timeArray[1];
        NSString *meetingName = embededTableTableViewController.meetingNameTF.text;
        NSString *users = embededTableTableViewController.usersTF.text;
        NSString *bodyString = [NSString stringWithFormat:@"date=%@&startTime=%@&endTime=%@&meetingName=%@&users=%@",
                                date, startTime, endTime, meetingName, users];
        [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
        
        //    NSURLResponse *response;
        //    NSError *error;
        
        //NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        if (connection) {
            NSLog(@"connecting......");
            self.responseData = [NSMutableData data];
        }
        //NSLog(@"%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        //[connection start];
    }else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Hello" message:@"Please provide all booking information" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [message show];

    }
    
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    
    NSLog(@"finished: %@", responseString);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Embed"]) {
        NSLog(@"embed view...");
        EmbededTableTableViewController *embededTableTableViewController = [segue destinationViewController];
        NSLog(@"1...");
        embededTableTableViewController.room = self.room;
        embededTableTableViewController.bookings = self.bookings;
        NSLog(@"2...");
    }
}

@end
