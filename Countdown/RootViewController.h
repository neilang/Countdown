//
//  RootViewController.h
//  Countdown
//
//  Created by Neil Ang on 15/09/11.
//  Copyright 2011 neilang.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@interface RootViewController : UITableViewController

@property (nonatomic, retain) EKEventStore *eventStore;
@property (nonatomic, retain) NSMutableArray *events;

-(IBAction)reloadEvents:(id)sender;

@end
