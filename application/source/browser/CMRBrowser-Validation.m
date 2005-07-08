//:CMRBrowser-Validation.m

#import "CMRBrowser_p.h"

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
	
	if(action_ == @selector(clear:))
		return ([[self threadsListTable] selectedRow] != -1);
	
	// 「掲示板を表示」
	if(action_ == @selector(toggleBoardDrawer:)){
		return NO;
	}
	if(action_ == @selector(beginBoardListSheet:)){
		return YES;
	}
	
	if(action_ == @selector(changeBrowserArrangement:)){
		return YES;
	}

	return [super validateUIItem : theItem];
}

- (BOOL) validateMenuItem : (NSMenuItem *) theItem
{
	SEL action_;
	
	if(nil == theItem) return NO;
	if([theItem tag] == 1001 || [theItem tag] == 1002) {
		// 掲示板リスト の Contextual Menu
		int					rowIndex_;
		NSDictionary		*item_;
	
		rowIndex_ = [[self boardListTable] selectedRow];
	
		if ([[self boardListTable] numberOfSelectedRows] > 1) return NO;
		if (rowIndex_ < 0) return NO;
		if (rowIndex_ >= [[self boardListTable] numberOfRows]) return NO;
	
		item_ = [[self boardListTable] itemAtRow : rowIndex_];
		if (nil == item_) return NO;

		if ([BoardList isBoard : item_])
			return YES;
		else if ([BoardList isCategory : item_] && [theItem tag] == 1002)
			return YES;
		return NO;
	}
	
	// 1003 は、掲示板リスト の Contextual Menu の一部項目のタグ
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

	if([super validateMenuItem : theItem] || [theItem tag] == 1003) return YES;
	
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