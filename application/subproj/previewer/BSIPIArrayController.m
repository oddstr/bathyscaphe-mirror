//
//  BSIPIArrayController.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/11/11.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSIPIArrayController.h"
#import <AppKit/NSToolbarItem.h>


@implementation BSIPIArrayController
- (void)removeAll:(id)sender
{
	[self removeObjects:[self arrangedObjects]];
}

- (void)selectFirst:(id)sender
{
	[self setSelectionIndex:0];
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

- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem
{
	if ([toolbarItem action] == @selector(remove:)) {
		return [self canRemove];
	}
	return [super validateToolbarItem:toolbarItem];
}
@end
