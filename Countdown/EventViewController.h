//
//  EventViewController.h
//  Countdown
//
//  Created by Neil Ang on 15/09/11.
//  Copyright 2011 neilang.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@interface EventViewController : UIViewController

@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) EKEvent *event;
@property (nonatomic, retain) NSTimer *timer;

- (id)initWithEvent:(EKEvent *)event;
- (void)updateCountdown;

@end
