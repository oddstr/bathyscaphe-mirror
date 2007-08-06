//
//  BSAdvancedPaneArrayController.m
//  BathyScaphe
//
//  Created by ODORI MOMOHA on 07/08/06.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import "BSAdvancedPaneArrayController.h"


@implementation BSAdvancedPaneArrayController
- (NSTableView *)tableView
{
	return m_tableView;
}

- (void)addObject:(id)object
{
	NSTableView *tv = [self tableView];
	[super addObject:object];
	[tv editColumn:0 row:[tv selectedRow] withEvent:nil select:YES];
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
	NSString *str = [fieldEditor string];
	if ([str isEqualToString: @""]) {
		NSBeep();
		return NO;
	} else if ([str hasPrefix:@"."]) {
		[fieldEditor setString:[str substringFromIndex:1]];
		return YES;
	}
	return YES;
}
@end
