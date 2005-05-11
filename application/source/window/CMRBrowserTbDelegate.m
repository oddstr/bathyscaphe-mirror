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
static NSString *const st_toggleBBSListItemIdentifier			= @"Toggle BBSList";
static NSString *const st_toggleBBSListItemLabelKey				= @"Toggle BBSList Label";
static NSString *const st_toggleBBSListItemPaletteLabelKey		= @"Toggle BBSList Palette Label";
static NSString *const st_toggleBBSListItemToolTipKey			= @"Toggle BBSList ToolTip";
static NSString *const st_toggleBBSList_imageName				= @"openBoard";


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
	NSDrawer				*BBSDrawer_;
	CMRBrowser				*wcontroller_;

	//Class NSSFExist;
	
	[super initializeToolbarItems : aWindow];
	
	UTILAssertNotNil([aWindow drawers]);
	NSAssert1(	[[aWindow drawers] count] > 0,
				@"Window Drawers count must be bigger than 1 but was %d.",
				[[aWindow drawers] count]);

	wcontroller_ = (CMRBrowser*)[aWindow windowController];
	BBSDrawer_ = [[aWindow drawers] objectAtIndex : 0];
	UTILAssertKindOfClass(wcontroller_, CMRBrowser);
	
	UTILAssertNotNil(wcontroller_);
	UTILAssertNotNil(BBSDrawer_);

	item_ = [self appendToolbarItemWithItemIdentifier : st_reloadListItemIdentifier
									localizedLabelKey : st_reloadListItemLabelKey
							 localizedPaletteLabelKey : st_reloadListItemPaletteLabelKey
								  localizedToolTipKey : st_reloadListItemToolTipKey
											   action : @selector(reloadThreadsList:)
											   target : wcontroller_];
	[item_ setImage : [NSImage imageAppNamed : st_reloadList_ImageName]];
	
	
	item_ = [self appendToolbarItemWithItemIdentifier : st_toggleBBSListItemIdentifier
									localizedLabelKey : st_toggleBBSListItemLabelKey
							 localizedPaletteLabelKey : st_toggleBBSListItemPaletteLabelKey
								  localizedToolTipKey : st_toggleBBSListItemToolTipKey
											   action : @selector(toggleBoardDrawer:)
											   target : wcontroller_];
	[item_ setImage : [NSImage imageAppNamed : st_toggleBBSList_imageName]];
	
	item_ = [self appendToolbarItemWithItemIdentifier : st_searchThreadItemIdentifier
									localizedLabelKey : st_searchThreadItemLabelKey
							 localizedPaletteLabelKey : st_searchThreadItemPaletteLabelKey
								  localizedToolTipKey : st_searchThreadItemToolTipKey
											   action : NULL
											   target : wcontroller_];


	//NSSFExist = objc_msgSend(objc_getClass("NSSuperSearchField"), @selector(class));
	//NSSFExist = NSClassFromString(@"NSSearchField");

	//if(NSSFExist){
		//NSLog(@"There exists NSSearchField class, so we use NSSearchField... Yeah!");
		[self setupSearchToolbarItem:item_];
	/*
	} else {
		//NSLog(@"NSSearchField class not found.");
		[self setupSearchToolbarItem:item_ itemView:[wcontroller_ searchToolbarItem]];
	}*/
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
- (void) setupSearchToolbarItem : (NSToolbarItem *) anItem
{
	id aView;
	NSMenuItem		*menuItem_;

	if (!searchFieldController_) {
		searchFieldController_ = [[CMRNSSearchField alloc] init];
	}
	
	aView = [[searchFieldController_ pantherSearchField] retain];
	[anItem  setView : aView];
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
@end



@implementation CMRBrowserTbDelegate (NSToolbarDelegate)
- (NSArray *) toolbarDefaultItemIdentifiers : (NSToolbar *) toolbar
{
	return [NSArray arrayWithObjects :
				st_reloadListItemIdentifier,
				[self reloadThreadItemIdentifier],
				NSToolbarSeparatorItemIdentifier,
				st_toggleBBSListItemIdentifier,
				NSToolbarFlexibleSpaceItemIdentifier,
				[self deleteItemIdentifier],
				[self toggleOnlineModeIdentifier],
				st_searchThreadItemIdentifier,
				[self replyItemIdentifier],
				nil];
}
- (NSArray *) toolbarAllowedItemIdentifiers : (NSToolbar *) toolbar
{
	return [NSArray arrayWithObjects :
				st_reloadListItemIdentifier,
				[self reloadThreadItemIdentifier],
				[self addFavoritesItemIdentifier],
				[self toggleOnlineModeIdentifier],
				[self launchCMLFIdentifier],
				st_toggleBBSListItemIdentifier,
				[self deleteItemIdentifier],
				st_searchThreadItemIdentifier,
				[self replyItemIdentifier],
				NSToolbarSeparatorItemIdentifier,
				NSToolbarSpaceItemIdentifier,
				NSToolbarFlexibleSpaceItemIdentifier,
				NSToolbarPrintItemIdentifier,
				nil];
}
@end
