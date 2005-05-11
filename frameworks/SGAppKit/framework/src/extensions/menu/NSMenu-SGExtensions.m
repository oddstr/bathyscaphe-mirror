//: NSMenu-SGExtensions.m
/**
  * $Id: NSMenu-SGExtensions.m,v 1.1.1.1 2005/05/11 17:51:27 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "NSMenu-SGExtensions_p.h"


@implementation NSMenu(SGExtensions)
- (void) removeAllItems
{
	int		i, cnt;
	
	cnt = [self numberOfItems];
	for(i = (cnt -1); i >= 0; i--){
		[self removeItemAtIndex : i];
	}
}
- (NSMenuItem *) addItemWithTitle : (NSString *) title
{
	id	menuItem = [self addItemWithTitle : title
								   action : NULL
							keyEquivalent : @""];
	return menuItem;
}
- (void) addItemsWithTitles : (NSArray *) itemTitles
{
	NSEnumerator		*iter_;
	NSString			*title_;
	
	iter_ = [itemTitles objectEnumerator];
	while(title_ = [iter_ nextObject]){
		UTILAssertKindOfClass(title_, NSString);
		[self addItemWithTitle : title_];
	}
}
@end
