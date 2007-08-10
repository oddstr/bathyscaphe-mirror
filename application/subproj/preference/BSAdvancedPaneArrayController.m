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

- (int)firstColumnOfTextFieldCell
{
	NSArray *columns = [[self tableView] tableColumns];
	int i;
	int numOfColumns = [columns count];
	NSTableColumn *column;

	for (i = 0; i < numOfColumns; i++) {
		column = [columns objectAtIndex:i];
		if ([[column dataCell] isKindOfClass:[NSTextFieldCell class]]) {
			return i;
		}
	}
	return 0;
}		

- (void)addObject:(id)object
{
	NSTableView *tv = [self tableView];
	[super addObject:object];
	[tv editColumn:[self firstColumnOfTextFieldCell] row:[tv selectedRow] withEvent:nil select:YES];
}
@end
