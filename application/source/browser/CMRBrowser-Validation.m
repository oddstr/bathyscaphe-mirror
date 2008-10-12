/*
 * $Id: CMRBrowser-Validation.m,v 1.32 2008/10/12 16:49:15 tsawada2 Exp $
 * BathyScaphe
 *
 * Copyright 2005 BathyScaphe Project. All rights reserved.
 *
 */

#import "CMRBrowser_p.h"
#import "SmartBoardList.h"

@implementation CMRBrowser(Validation)
- (BOOL)segCtrlTbItem:(BSSegmentedControlTbItem *)item validateSegment:(int)segment
{
	if ([[item itemIdentifier] isEqualToString:@"Toggle View Mode"]) {
		return YES;//[[self window] isKeyWindow];
	}
	return [super segCtrlTbItem:item validateSegment:segment];
}

#pragma mark Validation Helpers
- (BOOL)isIndexFieldFirstResponder
{
	NSWindow *window = [self window];
	if (![[window firstResponder] isKindOfClass:[NSTextView class]]) return NO;

	id fieldEditor = [window fieldEditor:NO forObject:nil];
	if (!fieldEditor) return NO;

	return ([[(NSTextView *)[window firstResponder] delegate] isKindOfClass:[IndexField class]]);
}

- (BOOL) validateDeleteThreadItemsEnabling: (NSArray *) threads
{
	NSEnumerator		*Iter_;
	NSDictionary		*thread_;

	if (!threads || [threads count] == 0) return NO;
	
	Iter_ = [threads objectEnumerator];
	while((thread_ = [Iter_ nextObject])){
		NSNumber	*status_;
		
		status_ = [thread_ objectForKey: CMRThreadStatusKey];
		if(nil == status_) continue;
		
		if(ThreadLogCachedStatus & [status_ unsignedIntValue]) {
			return YES;
		}
	}

	return NO;
}

- (BOOL) validateReloadThreadsListItem: (id) theItem
{
	static NSString *kToolTipNormal = nil;
	static NSString *kToolTipWaiting = nil;

	id tmp_ = [self currentThreadsList];
	if(nil == tmp_) return NO;

	if (!kToolTipNormal || !kToolTipWaiting) {
		kToolTipNormal = [NSLocalizedStringFromTable(@"Reload List ToolTip", @"ToolbarItems", @"") retain];
		kToolTipWaiting = [NSLocalizedStringFromTable(@"Reload List ToolTip 2", @"ToolbarItems", @"") retain];
	}

	if ([tmp_ isFavorites] || [tmp_ isSmartItem]) {
		BOOL canCheck = [CMRPref canHEADCheck];
		if ([theItem respondsToSelector: @selector(setToolTip:)]) {
			[theItem setToolTip: (canCheck ? kToolTipNormal : kToolTipWaiting)];
		}
		return canCheck;
	} else {
		if ([theItem respondsToSelector: @selector(setToolTip:)]) {
			[theItem setToolTip: kToolTipNormal];
		}
		return YES;
	}
}

- (BOOL) validateCollapseOrExpandBoardListItem: (id) theItem
{
	if ([theItem isKindOfClass: [NSMenuItem class]]) {
		[theItem setTitle : ([[self boardListSubView] isCollapsed] ? NSLocalizedString(@"Expand Boards List", @"")
																   : NSLocalizedString(@"Collapse Boards List", @""))];
	}
	return YES;
}

- (BOOL) validateDeleteBoardFromListItem: (int) tag_
{
	NSOutlineView	*bLT = [self boardListTable];
	int numOfSelectedRow = [bLT numberOfSelectedRows];
	switch(numOfSelectedRow) {
		case 0:
			return NO;
		case 1:
			return (NO == [SmartBoardList isFavorites : [bLT itemAtRow : [bLT selectedRow]]]);
		default:
			return (tag_ == kBLDeleteItemViaMenubarItemTag);
	}
}

- (BOOL) validateBoardListContextualMenuItem: (int) tag_
{
	BSBoardListView *view = (BSBoardListView *)[self boardListTable];
	int			rowAtMenu = [view semiSelectedRow];

	if (rowAtMenu == -1) {
		return NO;
	} else {
		NSIndexSet *selectedRows = [view selectedRowIndexes];
		if ([selectedRows count] > 1 && [selectedRows containsIndex:rowAtMenu]) {
			return (tag_ == kBLDeleteItemViaContMenuItemTag);
		}
		id item = [view itemAtRow:rowAtMenu];
		if (!item) return NO;
		return ![BoardListItem isFavoriteItem:item];
	}
	return NO;
}

#pragma mark NSUserInterfaceValidations Protocol
- (BOOL) validateUserInterfaceItem: (id <NSValidatedUserInterfaceItem>) theItem
{
	int tag_ = [theItem tag];

	if (tag_ == kBrowserMenuItemAlwaysEnabledTag) return YES;
	if (tag_ == kBLEditItemViaMenubarItemTag || tag_ == kBLDeleteItemViaMenubarItemTag) {
		return [self validateDeleteBoardFromListItem: tag_];
	}
	if ((tag_ > kBLContMenuItemTagMin) && (tag_ < kBLContMenuItemTagMax)) {
		return [self validateBoardListContextualMenuItem: tag_];
	}

	SEL action_ = [theItem action];

/*	if(action_ == @selector(selectFilteringMask:)) {
		return ([self currentThreadsList] != nil);
	} else*/ if(action_ == @selector(showSearchThreadPanel:)) {
		return ([self currentThreadsList] != nil);
	} else if(action_ == @selector(chooseColumn:)) {
		return ([self currentThreadsList] != nil);
	} else if(action_ == @selector(saveAsDefaultFrame:)) {
		return NO;
	} else if (action_ == @selector(openSelectedThreads:)) {
		NSArray *tmp = [self selectedThreadsReallySelected];
		if (tmp == nil) return NO;
		if ([tmp count] == 1 && [self shouldShowContents] &&
			[[[tmp lastObject] objectForKey: CMRThreadLogFilepathKey] isEqualToString: [self path]]) {
			return NO;
		}
		return YES;
	} else if (action_ == @selector(openBBSInBrowser:)) {
		return ([[self document] boardURL] != nil);
	} else if(action_ == @selector(collapseOrExpandBoardList:)) {
		return [self validateCollapseOrExpandBoardListItem: theItem];
	} else if(action_ == @selector(reloadThreadsList:)) {
		return [self validateReloadThreadsListItem: theItem];
//	} else if(action_ == @selector(changeBrowserArrangement:)) {
//		return YES;
	} else if(action_ == @selector(collapseOrExpandThreadViewer:)) {
		NSString *hogehoge;
		if ([[self splitView] isSubviewCollapsed:bottomSubview]) {
			hogehoge = [CMRPref isSplitViewVertical] ? NSLocalizedString(@"NSSplitView Vertical",@"") : NSLocalizedString(@"NSSplitView Horizontal", @"");
		} else {
			hogehoge = NSLocalizedString(@"collapse splitView",@"");
		}
		[theItem setTitle:hogehoge];
		return YES;
	}

	if (action_ == @selector(addFavorites:)) {
		CMRFavoritesOperation	operation_;

		if (tag_ == 781) { // Browser Contextual Menu
			operation_ = [self favoritesOperationForThreads: [self selectedThreadsReallySelected]];
		} else {
			// ちょっとトリッキーで危ない判定方法
			if([theItem isKindOfClass: [NSMenuItem class]] && [[(NSMenuItem *)theItem keyEquivalent] isEqualToString: @""]) { // Thread Contextual Menu
				operation_ = [[CMRFavoritesManager defaultManager] availableOperationWithPath: [self path]];
			} else {
				NSView *focusedView_ = (NSView *)[[self window] firstResponder];
				if (focusedView_ == [self textView] || [self isIndexFieldFirstResponder]) {
					operation_ = [[CMRFavoritesManager defaultManager] availableOperationWithPath: [self path]];
				} else {
					operation_ = [self favoritesOperationForThreads: [self selectedThreadsReallySelected]];
				}
			}
		}
		return [self validateAddFavoritesItem: theItem forOperation: operation_];
	}

	if(action_ == @selector(deleteThread:)) {

		[self validateDeleteThreadItemTitle: theItem];
		
		if (tag_ == 780) { // Browser Contextual Menu
			return [self validateDeleteThreadItemsEnabling: [self selectedThreadsReallySelected]];
		} else {
			if ([theItem isKindOfClass: [NSMenuItem class]] && [[(NSMenuItem *)theItem keyEquivalent] isEqualToString: @""]) { // Thread Contexual Menu
				return [super validateDeleteThreadItemEnabling: [self path]];
			} else {
				NSView *focusedView_ = (NSView *)[[self window] firstResponder];
				if (focusedView_ == [self textView] || [self isIndexFieldFirstResponder]) {
					return [super validateDeleteThreadItemEnabling: [self path]];
				} else {
					return [self validateDeleteThreadItemsEnabling: [self selectedThreadsReallySelected]];
				}
			}
		}
		
		return NO;
	}
	
	if (action_ == @selector(reloadThread:)) {
		if (tag_ == 782) { // browser contextual menu
			return YES;
		} else {
			if ([theItem isKindOfClass: [NSMenuItem class]] && [[(NSMenuItem *)theItem keyEquivalent] isEqualToString: @""]) { // Thread Contextual Menu
				return [self threadAttributes] && ![[self document] isDatOchiThread];
			} else {
				NSView *focusedView_ = (NSView *)[[self window] firstResponder];
				if (focusedView_ == [self textView] || [self isIndexFieldFirstResponder]) {
					return [self threadAttributes] && ![[self document] isDatOchiThread];
				} else {
					return ([[self selectedThreadsReallySelected] count] > 0);
				}
			}
		}
		
		return NO;
	}
	
	return [super validateUserInterfaceItem: theItem];
}
@end
