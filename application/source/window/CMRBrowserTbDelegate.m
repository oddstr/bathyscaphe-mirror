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
#import "BSNobiNobiToolbarItem.h"
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

// ノビノビスペース
static NSString *const st_NobiNobiItemIdentifier = @"Boards List Space";
static NSString *const st_NobiNobiPaletteLabelKey = @"NobiNobi Palette Label";

static NSString *const st_toolbar_identifier			= @"Browser Window Toolbar";

@implementation CMRBrowserTbDelegate
- (NSString *) identifier
{
	return st_toolbar_identifier;
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

	[self setupSearchToolbarItem:item_ itemView:[wcontroller_ searchField]];

	item_ = [self appendToolbarItemWithClass : [BSNobiNobiToolbarItem class]
							  itemIdentifier : st_NobiNobiItemIdentifier
						   localizedLabelKey : @""
					localizedPaletteLabelKey : st_NobiNobiPaletteLabelKey
						 localizedToolTipKey : @""
									  action : NULL
									  target : nil];

	[self setupSpace:item_];

	item_ = [self appendToolbarItemWithItemIdentifier : st_COEItemIdentifier
									localizedLabelKey : st_COEItemLabelKey
							 localizedPaletteLabelKey : st_COEItemPaletteLabelKey
								  localizedToolTipKey : st_COEItemToolTipKey
											   action : @selector(collapseOrExpandBoardList:)
											   target : wcontroller_];
	[item_ setImage : [NSImage imageAppNamed : @"BoardList"]];
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
		
		size_.width *= 3;
		[anItem setMaxSize : size_];
	}
	[aView release];
	
	menuItem_ = [self searchToolbarItemMenuFormRepresentationWithItem:anItem];
	if(nil == menuItem_) return;
	
	[anItem setMenuFormRepresentation : menuItem_];
}

- (void) setupSpace: (NSToolbarItem *) anItem
{
	BSNobiNobiView *aView = [[BSNobiNobiView alloc] init];
	[anItem setView : aView];
	if([anItem view] != nil){
		NSSize		size_;

		size_ = NSMakeSize(48, 29);
		[anItem setMinSize : size_];
		[anItem setMaxSize : size_];
	}
	[aView release];
}
@end



@implementation CMRBrowserTbDelegate (NSToolbarDelegate)
- (NSToolbarItem *) toolbar : (NSToolbar *) toolbar
      itemForItemIdentifier : (NSString  *) itemIdentifier
  willBeInsertedIntoToolbar : (BOOL       ) willBeInsertedIntoToolbar
{
	NSToolbarItem *hoge = [super toolbar:toolbar itemForItemIdentifier:itemIdentifier willBeInsertedIntoToolbar:willBeInsertedIntoToolbar];
	if (hoge && [itemIdentifier isEqualToString: st_NobiNobiItemIdentifier]) {
		[(BSNobiNobiView *)[hoge view] setShouldDrawBorder: (NO == willBeInsertedIntoToolbar)];
	}
	return hoge;
}

- (NSArray *) toolbarDefaultItemIdentifiers : (NSToolbar *) toolbar
{
	return [NSArray arrayWithObjects :
				st_NobiNobiItemIdentifier,
				st_reloadListItemIdentifier,
				NSToolbarSpaceItemIdentifier,
				[self reloadThreadItemIdentifier],
				NSToolbarSeparatorItemIdentifier,
				[self deleteItemIdentifier],
				[self addFavoritesItemIdentifier],
				NSToolbarSeparatorItemIdentifier,
				[self replyItemIdentifier],
				NSToolbarFlexibleSpaceItemIdentifier,
				st_searchThreadItemIdentifier,
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
				[self scaleSegmentedControlIdentifier],
				[self historySegmentedControlIdentifier],
				st_NobiNobiItemIdentifier,
				NSToolbarSeparatorItemIdentifier,
				NSToolbarSpaceItemIdentifier,
				NSToolbarFlexibleSpaceItemIdentifier,
				nil];
}

- (void) adjustNobiNobiViewTbItem: (NSToolbarItem *) item to: (float) width
{
	NSSize		size_;
	size_ = NSMakeSize(width-10, 29);
	[item setMinSize : size_];
	[item setMaxSize : size_];
}

- (void)toolbarWillAddItem:(NSNotification *)notification
{
	NSToolbarItem *item = [[notification userInfo] objectForKey: @"item"];
	if ([[item itemIdentifier] isEqualToString: st_NobiNobiItemIdentifier]) {
		CMRBrowser *browser = CMRMainBrowser;
		float	width = [[browser boardListSubView] dimension];
		[self adjustNobiNobiViewTbItem: item to: width];
	}
}
@end
