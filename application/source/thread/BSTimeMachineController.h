//
//  BSTimeMachineController.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/01/05.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>

@class BSDatePicker;

@interface BSTimeMachineController : NSWindowController {
	IBOutlet BSDatePicker	*datePicker;
}

+ (id)sharedTimeMachine;

- (void)endTimeMachine:(id)sender;

- (NSDate *)currentDate;
- (void)setCurrentDate:(id)date;
@end
