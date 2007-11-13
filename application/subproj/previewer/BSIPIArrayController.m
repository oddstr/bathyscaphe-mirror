//
//  BSIPIArrayController.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/11/11.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSIPIArrayController.h"


@implementation BSIPIArrayController
- (void)removeAll:(id)sender
{
	[self removeObjects:[self arrangedObjects]];
}

- (void)selectLast:(id)sender
{
	[self setSelectionIndex:[[self arrangedObjects] count]-1];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	if ([menuItem action] == @selector(removeAll:)) {
		return ([[self arrangedObjects] count] > 0);
	}
	return [super validateMenuItem:menuItem];
}
@end
