//:CMRBrowserTbDelegate.m
/**
  *
  * @see CMRTrashItemButton.h
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/11/09  9:04:06 PM)
  *
  */
#import "CMRBrowserTbDelegate_p.h"

//////////////////////////////////////////////////////////////////////
////////////////////// [ 定数やマクロ置換 ] //////////////////////////
//////////////////////////////////////////////////////////////////////
// スレッド一覧の更新
static NSString *const st_reloadListItemIdentifier			= @"Reload List";
static NSString *const st_reloadListItemLabelKey			= @"Reload List Label";
static NSString *const st_reloadListItemPaletteLabelKey		= @"Reload List Palette Label";
static NSString *const st_reloadListItemToolTipKey			= @"Reload List ToolTip";
static NSString *const st_reloadList_ImageName				= @"ReloadList";

// 検索
static NSString *const st_searchThreadItemIdentifier			= @"Search Thread";
static NSString *const st_searchThreadItemLabelKey				= @"Search Thread Label";
static NSString *const st_searchThreadItemPaletteLabelKey		= @"Search Thread Palette Label";
static NSString *const st_searchThreadItemToolTipKey			= @"Search Thread ToolTip";

// 掲示板リストの表示
static NSString *const st_COEItemIdentifier			= @"Collapse Or Expand";
static NSString *const st_COEItemLabelKey			= @"Collapse Or Expand Label";
static NSString *const st_COEItemPaletteLabelKey	= @"Collapse Or Expand Palette Label";
static NSString *const st_COEItemToolTipKey			= @"Collapse Or Expand ToolTip";


static NSString *const st_toolbar_identifier			= @"Browser Window Toolbar";

@implementation CMRBrowserTbDelegate
- (NSString *) identifier
{
	return st_toolbar_identifier;
}
- (id) m_searchFieldController
{
	return searchFieldController_;
}
@end



#import "CMRBrowser_p.h"
@implementation CMRBrowserTbDelegate (Protected)
- (void) initializeToolbarItems : (NSWindow *) aWindow
{
	NSToolbarItem			*item_;
	CMRBrowser				*wcontroller_;
	
	[super initializeToolbarItems : aWindow];

	wcontroller_ = (CMRBrowser*)[aWindow windowController];
	UTILAssertNotNil(wcontroller_);

	item_ = [self appendToolbarItemWithItemIdentifier : st_reloadListItemIdentifier
									localizedLabelKey : st_reloadListItemLabelKey
							 localizedPaletteLabelKey : st_reloadListItemPaletteLabelKey
								  localizedToolTipKey : st_reloadListItemToolTipKey
											   action : @selector(reloadThreadsList:)
											   target : wcontroller_];
	[item_ setImage : [NSImage imageAppNamed : st_reloadList_ImageName]];

	item_ = [self appendToolbarItemWithItemIdentifier : st_searchThreadItemIdentifier
									localizedLabelKey : st_searchThreadItemLabelKey
							 localizedPaletteLabelKey : st_searchThreadItemPaletteLabelKey
								  localizedToolTipKey : st_searchThreadItemToolTipKey
											   action : NULL
											   target : wcontroller_];

	[self setupSearchToolbarItem:item_ itemView:[wcontroller_ searchToolbarItem]];

	item_ = [self appendToolbarItemWithItemIdentifier : st_COEItemIdentifier
									localizedLabelKey : st_COEItemLabelKey
							 localizedPaletteLabelKey : st_COEItemPaletteLabelKey
								  localizedToolTipKey : st_COEItemToolTipKey
											   action : @selector(collapseOrExpandBoardList:)
											   target : wcontroller_];
	[item_ setImage : [NSImage imageAppNamed : @"BoardList"]];

	//[self setupProgressIndicatorTbItem:item_ fromView:[wcontroller_ statusLine]];
}
@end



@implementation CMRBrowserTbDelegate(Private)
- (NSMenuItem *) searchToolbarItemMenuFormRepresentationWithItem : (NSToolbarItem *) anItem
{
	NSMenuItem		*menuItem_;
	
	menuItem_ = [[NSMenuItem alloc]
					initWithTitle : [anItem label]
						   action : @selector(showSearchThreadPanel:)
					keyEquivalent : @""];
	[menuItem_ setImage : [NSImage imageAppNamed : @"Find"]];
	
	return [menuItem_ autorelease];
}
- (void) setupSearchToolbarItem : (NSToolbarItem *) anItem
					   itemView : (NSView		 *) aView
{
	NSMenuItem		*menuItem_;
	
	[aView retain];
	[aView removeFromSuperviewWithoutNeedingDisplay];
	
	[anItem setView : aView];
	if([anItem view] != nil){
		NSSize		size_;
		
		size_ = [aView bounds].size;
		[anItem setMinSize : size_];
		
		size_.width *= 5;
		[anItem setMaxSize : size_];
	}
	[aView release];
	
	menuItem_ = [self searchToolbarItemMenuFormRepresentationWithItem:anItem];
	if(nil == menuItem_) return;
	
	[anItem setMenuFormRepresentation : menuItem_];
}
/*- (void) setupProgressIndicatorTbItem : (NSToolbarItem *) anItem
							 fromView : (NSView		   *) aView
{
	id	part_;
	
	part_ = [aView progressIndicator];
	if(part_) {
		NSSize		size_;
		[part_ retain];
		//[part_ removeFromSuperviewWithoutNeedingDisplay];
		
		[anItem setView : part_];
		[part_ release];
		
		size_ = [part_ bounds].size;
		[anItem setMinSize : size_];
		[anItem setMaxSize : size_];
	}
}*/
@end



@implementation CMRBrowserTbDelegate (NSToolbarDelegate)
- (NSArray *) toolbarDefaultItemIdentifiers : (NSToolbar *) toolbar
{
	return [NSArray arrayWithObjects :
				st_reloadListItemIdentifier,
				[self reloadThreadItemIdentifier],
				NSToolbarSeparatorItemIdentifier,
				NSToolbarFlexibleSpaceItemIdentifier,
				[self deleteItemIdentifier],
				[self addFavoritesItemIdentifier],
				st_searchThreadItemIdentifier,
				[self replyItemIdentifier],
				nil];
}
- (NSArray *) toolbarAllowedItemIdentifiers : (NSToolbar *) toolbar
{
	return [NSArray arrayWithObjects :
				st_reloadListItemIdentifier,
				[self reloadThreadItemIdentifier],
				[self stopTaskIdentifier],
				[self addFavoritesItemIdentifier],
				[self deleteItemIdentifier],
				[self replyItemIdentifier],
				st_searchThreadItemIdentifier,
				st_COEItemIdentifier,
				[self toggleOnlineModeIdentifier],
				[self launchCMLFIdentifier],
				[self historySegmentedControlIdentifier],
				NSToolbarSeparatorItemIdentifier,
				NSToolbarSpaceItemIdentifier,
				NSToolbarFlexibleSpaceItemIdentifier,
				nil];
}
@end
