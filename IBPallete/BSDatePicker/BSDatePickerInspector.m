//
//  BSDatePickerInspector.m
//  BSDatePicker
//
//  Created by Hori,Masaki on 06/01/09.
//  Copyright 2006 BathyScaphe Project. All rights reserved.//

#import "BSDatePickerInspector.h"
#import "BSDatePicker.h"

@implementation BSDatePickerInspector

- (id)init
{
    self = [super init];
    [NSBundle loadNibNamed:@"BSDatePickerInspector" owner:self];
    return self;
}

- (void)ok:(id)sender
{
	[self beginUndoGrouping];
    [self noteAttributesWillChangeForObject:[self object]];
	
	if(sender == tagField) {
		[[self object] setTag:[sender intValue]];
	} else if( sender == dateDate) {
		[[self object] setDate:[sender date]];
	}
	
    [super ok:sender];
}

- (void)revert:(id)sender
{
	BSDatePicker *view = [self object];
	
	[tagField setIntValue:[view tag]];
	[dateDate setDate:[view date]];
	
    [super revert:sender];
}

@end
