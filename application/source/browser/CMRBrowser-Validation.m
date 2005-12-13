/*
 * $Id: CMRBrowser-Validation.m,v 1.11 2005/12/13 12:31:28 tsawada2 Exp $
 * BathyScaphe
 *
 * Copyright 2005 BathyScaphe Project. All rights reserved.
 *
 */

#import "CMRBrowser_p.h"
#import "BSBoardListView.h"

@implementation CMRBrowser(Validation)
- (BOOL) validateUIItem : (id) theItem
{
	SEL			action_;
	
	if(nil == theItem) return NO;
	if(NO == [theItem respondsToSelector : @selector(action)]) return NO;
	
	action_ = [theItem action];
	
	if(action_ == @selector(openBBSInBrowser:)) return ([[self document] boardURL] != nil);
	
	if(action_ == @selector(deleteThread:) || action_ == @selector(openLogfile:)) {
		NSEnumerator		*Iter_;
		NSDictionary		*thread_;
		
		Iter_ = [[self selectedThreads] objectEnumerator];
		while((thread_ = [Iter_ nextObject])){
			NSNumber				*status_;
			
			status_ = [thread_ objectForKey : CMRThreadStatusKey];
			if(nil == status_) continue;
			
			if(ThreadLogCachedStatus & [status_ unsignedIntValue])
				return YES;
		}
		if([self shouldShowContents])
			return [super validateUIItem : theItem];

		return NO;
	}
	
	if(action_ == @selector(reloadThreadsList:)){
		if(nil == [self currentThreadsList]) return NO;
		
		return (NO == [[self currentThreadsList] isFavorites]);
	}
	
	if(action_ == @selector(changeBrowserArrangement:)){
		return YES;
	}

	return [super validateUIItem : theItem];
}

- (BOOL) validateMenuItem : (NSMenuItem *) theItem
{
	SEL action_;
	int tag_;
	
	if(nil == theItem) return NO;
	tag_ = [theItem tag];

	if (tag_ == kBLAddItemItemTag) return YES;

	if (tag_ > kBLMenubarItemTagMaximalValue) {
		int					rowIndex_;
		NSDictionary		*item_;
		NSOutlineView		*bLT_ = [self boardListTable];
		int					semiSelRowIdx_ = [(BSBoardListView *)bLT_ semiSelectedRow];
	
		if ([bLT_ numberOfSelectedRows] > 1) {
			if (tag_ == kBLDeleteItemViaMenubarItemTag || tag_ == kBLDeleteItemViaContMenuItemTag) {
				return YES; // •¡”‚Ì€–Ú‚Éu‚¨‹C‚É“ü‚èv‚ªŠÜ‚Ü‚ê‚Ä‚¢‚Ä‚à–â‘è‚Í‚È‚¢
			} else if (tag_ == kBLEditItemViaContextualMenuItemTag) {
				return (NO == [[bLT_ selectedRowIndexes] containsIndex : semiSelRowIdx_]);
			} else {
				return NO;
			}
		}

		rowIndex_ = [bLT_ selectedRow];
	
		if (rowIndex_ >= [bLT_ numberOfRows]) return NO;
		// 2005-12-13 tsawada2
		if ((rowIndex_ < 0 || (rowIndex_ != semiSelRowIdx_)) && semiSelRowIdx_ != -1) {
			if ((semiSelRowIdx_ >= 0) && (tag_ > kBLContMenuItemTagMaximalValue)) // via Contextual menu
				rowIndex_ = semiSelRowIdx_;
			else
				return NO;
		}

		item_ = [bLT_ itemAtRow : rowIndex_];
		if (nil == item_) return NO;

		if ([BoardList isBoard : item_])
			return YES;
		else if ([BoardList isCategory : item_] && (tag_ != kBLOpenItemItemTag))
			return YES;
		return NO;
	}
	
	if(NO == [theItem respondsToSelector : @selector(action)]) return NO;	
	action_ = [theItem action];
	
	if(action_ == @selector(selectFilteringMask:)) 
		return ([self currentThreadsList] != nil);
	else if(action_ == @selector(searchToolbarPopupChanged:))
		return ([self currentThreadsList] != nil);
	else if(action_ == @selector(showSearchThreadPanel:))
		return ([self currentThreadsList] != nil);
	else if(action_ == @selector(chooseColumn:))
		return ([self currentThreadsList] != nil);
	else if(action_ == @selector(saveAsDefaultFrame:))
		return NO;
	else if(action_ == @selector(collapseOrExpandBoardList:)){
		[theItem setTitle : ([[self boardListSubView] isCollapsed] ? NSLocalizedString(@"Expand Boards List", "Expand")
																   : NSLocalizedString(@"Collapse Boards List", "Collapse")
							)];
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