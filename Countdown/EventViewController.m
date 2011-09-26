//
//  EventViewController.m
//  Countdown
//
//  Created by Neil Ang on 15/09/11.
//  Copyright 2011 neilang.com. All rights reserved.
//

#import "EventViewController.h"

@implementation EventViewController

@synthesize event = _event;
@synthesize label = _label;
@synthesize timer = _timer;

- (id)initWithEvent:(EKEvent *)event {
    self = [super init];
    if (self) {
        self.event = event;
    }
    return self;    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the ViewController title from the event name
    self.title = self.event.title;
    
    // Set the default countdown on the label
    [self updateCountdown];
    
    // Start a timer to update the label every second
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats:YES];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.event = nil;
    self.label = nil;
}

-(void)dealloc {
    [_event release];
    [super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated {
	if ([self.timer isValid]) {
		[self.timer invalidate];
		self.timer = nil;
	}
    
	[super viewWillDisappear:animated];
}

// Calculate how many seconds are left until the event start date and update the label
- (void)updateCountdown {
    
    NSTimeInterval eventDate  = [self.event.startDate timeIntervalSince1970];
	NSTimeInterval todaysDate = [[NSDate date] timeIntervalSince1970];
    
    int secondsLeft = eventDate - todaysDate;
    
    int hours, minutes, seconds;
    
    if(secondsLeft <= 0){
        hours = minutes = seconds = 0;
    }
    else{
        hours   = secondsLeft / 3600;
        minutes = (secondsLeft % 3600) / 60;
        seconds = (secondsLeft % 3600) % 60;
    }
    
    NSString * text = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    
    self.label.text = text;
}

@end
