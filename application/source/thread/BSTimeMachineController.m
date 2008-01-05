//
//  BSTimeMachineController.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/01/05.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSTimeMachineController.h"
#import "BSDatePicker.h"
#import "CocoMonar_Prefix.h"

@implementation BSTimeMachineController
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedTimeMachine);

- (id)init
{
    return [super initWithWindowNibName:@"BSTimeMachine"];
}

- (void)awakeFromNib
{
	[[self window] setFrameAutosaveName:@"BathyScaphe:TimeMachine Panel Autosave"];
}

- (void)showWindow:(id)sender
{
	[super showWindow:sender];
	[[self window] makeFirstResponder:datePicker];
}

- (void)endTimeMachine:(id)sender
{
	[[self window] orderOut:sender];
}

- (NSDate *)currentDate
{
	return [datePicker date];
}

- (void)setCurrentDate:(id)date
{
	[datePicker setDate:date];
}
@end
