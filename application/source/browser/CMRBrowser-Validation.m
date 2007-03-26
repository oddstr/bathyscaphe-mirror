/*
 * $Id: CMRBrowser-Validation.m,v 1.23 2007/03/26 00:03:51 tsawada2 Exp $
 * BathyScaphe
 *
 * Copyright 2005 BathyScaphe Project. All rights reserved.
 *
 */

#import "CMRBrowser_p.h"

#import "SmartBoardList.h"

@implementation CMRBrowser(Validation)
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

- (BOOL) validateUIItem : (id) theItem
{
	SEL			action_;
	static NSString *kToolTipNormal = nil;
	static NSString *kToolTipWaiting = nil;
	
	if(nil == theItem) return NO;
	if(NO == [theItem respondsToSelector : @selector(action)]) return NO;
	
	action_ = [theItem action];
	
	if(action_ == @selector(openBBSInBrowser:)) return ([[self document] boardURL] != nil);
	
	if (action_ == @selector(addFavorites:)) {
		CMRFavoritesOperation	operation_;

		if ([theItem tag] == 781) { // Browser Contextual Menu
			operation_ = [self favoritesOperationForThreads: [self selectedThreadsReallySelected]];
		} else {
			// ちょっとトリッキーで危ない判定方法
			if([theItem isKindOfClass: [NSMenuItem class]] && [[theItem keyEquivalent] isEqualToString: @""]) { // Thread Contextual Menu
				operation_ = [[CMRFavoritesManager defaultManager] availableOperationWithPath: [self path]];
			} else {
				NSView *focusedView_ = (NSView *)[[self window] firstResponder];
				if (focusedView_ == [self textView] || [[[focusedView_ superview] superview] isKindOfClass : [IndexField class]]) {
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
		
		if ([theItem tag] == 780) { // Browser Contextual Menu
			return [self validateDeleteThreadItemsEnabling: [self selectedThreadsReallySelected]];
		} else {
			if ([theItem isKindOfClass: [NSMenuItem class]] && [[theItem keyEquivalent] isEqualToString: @""]) { // Thread Contexual Menu
				return [super validateDeleteThreadItemEnabling: [self path]];
			} else {
				NSView *focusedView_ = (NSView *)[[self window] firstResponder];
				if (focusedView_ == [self textView] || [[[focusedView_ superview] superview] isKindOfClass : [IndexField class]]) {
					return [super validateDeleteThreadItemEnabling: [self path]];
				} else {
					return [self validateDeleteThreadItemsEnabling: [self selectedThreadsReallySelected]];
				}
			}
		}
		
		return NO;
	}
	
	if (action_ == @selector(reloadThread:)) {
		if ([theItem tag] == 782) { // browser contextual menu
			return YES;
		} else {
			if ([theItem isKindOfClass: [NSMenuItem class]] && [[theItem keyEquivalent] isEqualToString: @""]) { // Thread Contextual Menu
				return [self threadAttributes] && ![self isDatOchiThread];
			} else {
				NSView *focusedView_ = (NSView *)[[self window] firstResponder];
				if (focusedView_ == [self textView] || [[[focusedView_ superview] superview] isKindOfClass : [IndexField class]]) {
					return [self threadAttributes] && ![self isDatOchiThread];
				} else {
					return ([[self selectedThreadsReallySelected] count] > 0);
				}
			}
		}
		
		return NO;
	}
	
	if(action_ == @selector(reloadThreadsList:)){
		id tmp_ = [self currentThreadsList];
		if(nil == tmp_) return NO;
/*
		if(([tmp_ isFavorites] || [tmp_ isSmartItem]) && ![CMRPref canHEADCheck]) {
			if ([theItem respondsToSelector : @selector(setToolTip:)]) {
				NSDate *newDate_ = [CMRPref nextHEADCheckAvailableDate];
				NSString *dateStr_ =
					[NSString stringWithFormat : NSLocalizedString(@"HEADCheck Disabled ToolTip", @"Can't use HEADCheck until %@"),
												 [newDate_ descriptionWithCalendarFormat : @"%H:%M" timeZone: nil locale:nil]];
				[theItem setToolTip : dateStr_];
			}
			return NO;
		} else {
			if ([theItem respondsToSelector : @selector(setToolTip:)])
				[theItem setToolTip : NSLocalizedString(@"Reload List ToolTip", @"Reload current thread list.")];
			return YES;
		}*/

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
	
	if(action_ == @selector(changeBrowserArrangement:)){
		return YES;
	}

	return [super validateUIItem : theItem];
}

- (BOOL) validateMenuItem : (NSMenuItem *) theItem
{
	if(nil == theItem) return NO;
	int tag_ = [theItem tag];

	if (tag_ == kBrowserMenuItemAlwaysEnabledTag) return YES;
	
	if (tag_ == kBLEditItemViaMenubarItemTag || tag_ == kBLDeleteItemViaMenubarItemTag) {
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

	if ((tag_ > kBLContMenuItemTagMin) && (tag_ < kBLContMenuItemTagMax)) {
		int					rowIndex_;
		NSOutlineView		*bLT_ = [self boardListTable];
		int					semiSelRowIdx_ = [(BSBoardListView *)bLT_ semiSelectedRow];
		int					numOfSelected_ = [bLT_ numberOfSelectedRows];
	
		if (numOfSelected_ > 1) {
			if ([[bLT_ selectedRowIndexes] containsIndex : semiSelRowIdx_]) {
				if (tag_ == kBLDeleteItemViaContMenuItemTag)
					return YES; // 複数の項目に「お気に入り」が含まれていても問題はない
				else
					return NO;
			} else {
				if (tag_ == kBLShowInspectorViaContMenuItemTag) return NO;
				rowIndex_ = semiSelRowIdx_;
			}
		} else if (numOfSelected_ = 0) {
			if (semiSelRowIdx_ = -1) return NO;
			else rowIndex_ = semiSelRowIdx_;
		} else {
			rowIndex_ = [bLT_ selectedRow];
			if ((semiSelRowIdx_ != -1) && (semiSelRowIdx_ != rowIndex_)) {
				if (tag_ == kBLShowInspectorViaContMenuItemTag) return NO;
				else rowIndex_ = semiSelRowIdx_;
			}
		}

		if (rowIndex_ >= [bLT_ numberOfRows]) return NO;

		id		item_ = [bLT_ itemAtRow : rowIndex_];
		if (nil == item_) return NO;

		if ([BoardListItem isBoardItem : item_] || [BoardListItem isSmartItem : item_]) {
			return YES;
		} else if ([BoardListItem isFolderItem : item_]) {
			if (tag_ == kBLShowInspectorViaContMenuItemTag || tag_ == kBLOpenBoardItemViaContMenuItemTag)
				return NO;
			else
				return YES;
		}
		return NO;
	}
	
	if(NO == [theItem respondsToSelector : @selector(action)]) return NO;	
	SEL action_ = [theItem action];
	
	if(action_ == @selector(selectFilteringMask:)) 
		return ([self currentThreadsList] != nil);
	else if(action_ == @selector(showSearchThreadPanel:))
		return ([self currentThreadsList] != nil);
	else if(action_ == @selector(chooseColumn:))
		return ([self currentThreadsList] != nil);
	else if(action_ == @selector(saveAsDefaultFrame:))
		return NO;
	else if(action_ == @selector(collapseOrExpandBoardList:)){
		[theItem setTitle : ([[self boardListSubView] isCollapsed] ? NSLocalizedString(@"Expand Boards List", @"Expand")
																   : NSLocalizedString(@"Collapse Boards List", @"Collapse")
							)];
		return YES;
	} else if (action_ == @selector(openSelectedThreads:)) {
		NSArray *tmp = [self selectedThreadsReallySelected];
		if (tmp == nil) return NO;
		if ([tmp count] == 1 && [self shouldShowContents] &&
			[[[tmp lastObject] objectForKey: CMRThreadLogFilepathKey] isEqualToString: [self path]]) {
			return NO;
		}
		return YES;
	}

	if ([super validateMenuItem : theItem]) return YES;
	
	return [self validateUIItem : theItem];
}

- (BOOL) validateToolbarItem : (NSToolbarItem *) theItem
{
	SEL action_;
	action_ = [theItem action];
	
	if (action_ == @selector(collapseOrExpandBoardList:)) {
		return YES;
	}

	return [super validateToolbarItem : theItem];
}
@end