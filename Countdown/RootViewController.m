//
//  RootViewController.m
//  Countdown
//
//  Created by Neil Ang on 15/09/11.
//  Copyright 2011 neilang.com. All rights reserved.
//

#import "RootViewController.h"
#import "EventViewController.h"

@implementation RootViewController

@synthesize eventStore = _eventStore;
@synthesize events     = _events;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the app title
    self.title = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    // Store a reference to the event store
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    self.eventStore = eventStore;
    [eventStore release];
    
    // Load the events from the event store
    [self reloadEvents:nil];
    
    // The iOS simulator does not have any default events, so we will need to add some for demo purposes
    #ifdef TARGET_IPHONE_SIMULATOR
    if([self.events count] < 1){
        
        NSLog(@"Adding sample events");
    
        EKEvent *oneMinute  = [EKEvent eventWithEventStore:self.eventStore];
        oneMinute.title     = @"One minute from now";
        oneMinute.startDate = [NSDate dateWithTimeIntervalSinceNow:(60 * 1)];
        oneMinute.endDate   = oneMinute.startDate;
        oneMinute.calendar  = [self.eventStore defaultCalendarForNewEvents];
        [self.eventStore saveEvent:oneMinute span:EKSpanThisEvent error:nil];
        
        EKEvent *twoMinutes  = [EKEvent eventWithEventStore:self.eventStore];
        twoMinutes.title     = @"Two minutes from now";
        twoMinutes.startDate = [NSDate dateWithTimeIntervalSinceNow:(60 * 2)];
        twoMinutes.endDate   = twoMinutes.startDate;
        twoMinutes.calendar  = [self.eventStore defaultCalendarForNewEvents];
        [self.eventStore saveEvent:twoMinutes span:EKSpanThisEvent error:nil];
    
        EKEvent *threeHours  = [EKEvent eventWithEventStore:self.eventStore];
        threeHours.title     = @"Three hours from now";
        threeHours.startDate = [NSDate dateWithTimeIntervalSinceNow:(60 * 60 * 3)];
        threeHours.endDate   = threeHours.startDate;
        threeHours.calendar  = [self.eventStore defaultCalendarForNewEvents];
        [self.eventStore saveEvent:threeHours span:EKSpanThisEvent error:nil];
        
        EKEvent *tomorrowEvent  = [EKEvent eventWithEventStore:self.eventStore];
        tomorrowEvent.title     = @"Tomorrow, tomorrow";
        tomorrowEvent.startDate = [NSDate dateWithTimeIntervalSinceNow:(60 * 60 * 24)];
        tomorrowEvent.endDate   = tomorrowEvent.startDate;
        tomorrowEvent.calendar  = [self.eventStore defaultCalendarForNewEvents];
        [self.eventStore saveEvent:tomorrowEvent span:EKSpanThisEvent error:nil];
        
        EKEvent *nextWeekEvent  = [EKEvent eventWithEventStore:self.eventStore];
        nextWeekEvent.title     = @"Next week";
        nextWeekEvent.startDate = [NSDate dateWithTimeIntervalSinceNow:(60 * 60 * 24 * 7)];
        nextWeekEvent.endDate   = nextWeekEvent.startDate;
        nextWeekEvent.calendar  = [self.eventStore defaultCalendarForNewEvents];
        [self.eventStore saveEvent:nextWeekEvent span:EKSpanThisEvent error:nil];
        
        // Perform the query again with newly added data
        [self reloadEvents:nil];
    }
    #endif
    
    // Add a refresh button
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadEvents:)];
    self.navigationItem.rightBarButtonItem = refresh;
    [refresh release];
    
}

-(IBAction)reloadEvents:(id)sender {
    
    // Define a range of event dates we want to display
    NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:(-1*60*60)]; // 1 hour in the past
    NSDate *endDate   = [NSDate dateWithTimeIntervalSinceNow:(60*60*24*365)]; // 1 year from now

    // Create a predicate to search all celndars with our date range
    NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
    
    // Query the event store using the predicate.
    NSArray *results       = [self.eventStore eventsMatchingPredicate:predicate];
    
    // Convert the results to a mutable array and store so we can implement swipe to delete
    NSMutableArray *events = [[NSMutableArray alloc] initWithArray:results];
    self.events            = events;
    [events release];
    
    // Update the table view
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.events count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    EKEvent * event = [self.events objectAtIndex:indexPath.row];
    cell.textLabel.text = event.title;
    
	cell.detailTextLabel.text = event.calendar.title;
    
	if (event.calendar.CGColor) {
        cell.detailTextLabel.textColor = [UIColor colorWithCGColor:event.calendar.CGColor];
	}

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EKEvent *event = [self.events objectAtIndex:indexPath.row];
    EventViewController *eventViewController = [[EventViewController alloc] initWithEvent:event];
    [self.navigationController pushViewController:eventViewController animated:YES];
    [eventViewController release];
}

- (void)viewDidUnload {
    [super viewDidUnload];

    self.events     = nil;
    self.eventStore = nil;
}

- (void)dealloc {
    [_events release];
    [_eventStore release];
    [super dealloc];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {        
        // Delete the event from the event store
        [self.eventStore removeEvent:[self.events objectAtIndex:indexPath.row] span:EKSpanThisEvent error:nil];
        
        // Delete the row from the array
        [self.events removeObjectAtIndex:indexPath.row];

        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];        
    }
}

@end
