//: NSBrowserCell-SGExtensions.m
/**
  * $Id: NSBrowserCell-SGExtensions.m,v 1.1.1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "NSBrowserCell-SGExtensions_p.h"


@implementation NSBrowserCell(SGExtensions)
+ (void) attachDataCellOfTableColumn : (NSTableColumn *) tableColumn
{
	NSBrowserCell *iconImagedCell_;
	
	if(nil == tableColumn) return;
	iconImagedCell_ = [[self alloc] initTextCell : @""];
	
	[iconImagedCell_ setLeaf : YES];
	[iconImagedCell_ setEditable : YES];
	[tableColumn setDataCell : iconImagedCell_];
	[iconImagedCell_ release];
}
@end
