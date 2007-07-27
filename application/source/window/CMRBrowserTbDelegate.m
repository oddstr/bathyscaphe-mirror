//
//  CMRBrowserTbDelegate.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/07/27.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRBrowserTbDelegate.h"
#import "CMRToolbarDelegateImp_p.h"
#import "CMRBrowser_p.h"
#import <SGAppKit/BSSegmentedControlTbItem.h>
#import "BSNobiNobiToolbarItem.h"

// Reload Threads List
static NSString *const st_reloadListItemIdentifier			= @"Reload List";
static NSString *const st_reloadListItemLabelKey			= @"Reload List Label";
static NSString *const st_reloadListItemPaletteLabelKey		= @"Reload List Palette Label";
static NSString *const st_reloadListItemToolTipKey			= @"Reload List ToolTip";
static NSString *const st_reloadList_ImageName				= @"ReloadList";

// Search Field
static NSString *const st_searchThreadItemIdentifier			= @"Search Thread";
static NSString *const st_searchThreadItemLabelKey				= @"Search Thread Label";
static NSString *const st_searchThreadItemPaletteLabelKey		= @"Search Thread Palette Label";
static NSString *const st_searchThreadItemToolTipKey			= @"Search Thread ToolTip";

// Collapse/Expand Boards List
static NSString *const st_COEItemIdentifier			= @"Collapse Or Expand";
static NSString *const st_COEItemLabelKey			= @"Collapse Or Expand Label";
static NSString *const st_COEItemPaletteLabelKey	= @"Collapse Or Expand Palette Label";
static NSString *const st_COEItemToolTipKey			= @"Collapse Or Expand ToolTip";

// NobiNobi Space
static NSString *const st_NobiNobiItemIdentifier = @"Boards List Space";
static NSString *const st_NobiNobiPaletteLabelKey = @"NobiNobi Palette Label";

// Toggle Threads List View Mode
// Available in Twincam Angel.
static NSString *const st_viewModeSwitcherItemIdentifier = @"Toggle View Mode";
static NSString *const st_viewModeSwitcherItemLabelKey = @"Toggle View Mode Label";
static NSString *const st_viewModeSwitcherItemPaletteLabelKey = @"Toggle View Mode Palette Label";
static NSString *const st_viewModeSwitcherItemToolTipKey = @"Toggle View Mode ToolTip";

// Toolbar Identifier Constant
static NSString *const st_toolbar_identifier			= @"Browser Window Toolbar";

@implementation CMRBrowserTbDelegate
- (NSString *) identifier
{
	return st_toolbar_identifier;
}
@end


@implementation CMRBrowserTbDelegate (Protected)
- (void)initializeToolbarItems:(NSWindow *)aWindow
{
	NSToolbarItem			*item_;
	CMRBrowser				*wcontroller_;
	
	[super initializeToolbarItems:aWindow];

	wcontroller_ = (CMRBrowser*)[aWindow windowController];
	UTILAssertNotNil(wcontroller_);

	item_ = [self appendToolbarItemWithItemIdentifier : st_reloadListItemIdentifier
									localizedLabelKey : st_reloadListItemLabelKey
							 localizedPaletteLabelKey : st_reloadListItemPaletteLabelKey
								  localizedToolTipKey : st_reloadListItemToolTipKey
											   action : @selector(reloadThreadsList:)
											   target : wcontroller_];
	[item_ setImage:[NSImage imageAppNamed:st_reloadList_ImageName]];

	item_ = [self appendToolbarItemWithItemIdentifier : st_searchThreadItemIdentifier
									localizedLabelKey : st_searchThreadItemLabelKey
							 localizedPaletteLabelKey : st_searchThreadItemPaletteLabelKey
								  localizedToolTipKey : st_searchThreadItemToolTipKey
											   action : NULL
											   target : wcontroller_];

	[self setupSearchToolbarItem:item_ itemView:[wcontroller_ searchField]];

	item_ = [self appendToolbarItemWithClass:[BSSegmentedControlTbItem class]
							  itemIdentifier:st_viewModeSwitcherItemIdentifier
						   localizedLabelKey:st_viewModeSwitcherItemLabelKey
					localizedPaletteLabelKey:st_viewModeSwitcherItemPaletteLabelKey
						 localizedToolTipKey:st_viewModeSwitcherItemToolTipKey
									  action:NULL
									  target:nil];

	[self setupSwitcherToolbarItem:item_ itemView:[wcontroller_ viewModeSwitcher]];
	[(BSSegmentedControlTbItem *)item_ setDelegate:wcontroller_];

	item_ = [self appendToolbarItemWithClass : [BSNobiNobiToolbarItem class]
							  itemIdentifier : st_NobiNobiItemIdentifier
						   localizedLabelKey : @""
					localizedPaletteLabelKey : st_NobiNobiPaletteLabelKey
						 localizedToolTipKey : @""
									  action : NULL
									  target : nil];

	[self setupNobiNobiToolbarItem:item_];

	item_ = [self appendToolbarItemWithItemIdentifier : st_COEItemIdentifier
									localizedLabelKey : st_COEItemLabelKey
							 localizedPaletteLabelKey : st_COEItemPaletteLabelKey
								  localizedToolTipKey : st_COEItemToolTipKey
											   action : @selector(collapseOrExpandBoardList:)
											   target : wcontroller_];
	[item_ setImage:[NSImage imageAppNamed:@"BoardList"]];
}
@end



@implementation CMRBrowserTbDelegate(Private)
static NSMenuItem* searchToolbarItemMenuFormRep(NSString *labelText)
{
	NSMenuItem		*menuItem_;
	
	menuItem_ = [[NSMenuItem alloc] initWithTitle:labelText action:@selector(showSearchThreadPanel:) keyEquivalent:@""];
	[menuItem_ setImage:[NSImage imageAppNamed:@"Find"]];

	return [menuItem_ autorelease];
}
- (void)setupSearchToolbarItem:(NSToolbarItem *)anItem itemView:(NSView *)aView
{
	NSMenuItem *menuItem_;
	NSSize size_;
	
	[aView retain];

	[aView removeFromSuperviewWithoutNeedingDisplay];
	[anItem setView:aView];
	size_ = [aView bounds].size;
	[anItem setMinSize:size_];
	size_.width *= 3;
	[anItem setMaxSize:size_];

	[aView release];
	
	menuItem_ = searchToolbarItemMenuFormRep([anItem label]);
	if (menuItem_) {
		[anItem setMenuFormRepresentation:menuItem_];
	}
}

- (void)setupSwitcherToolbarItem:(NSToolbarItem *)anItem itemView:(NSView *)aView
{
	NSSize size_;

	[aView retain];

	[aView removeFromSuperviewWithoutNeedingDisplay];	
	[anItem setView:aView];
		
	size_ = [aView bounds].size;
	size_.height += 1;
	[anItem setMinSize:size_];
	[anItem setMaxSize:size_];

	[aView release];
}

- (void)setupNobiNobiToolbarItem:(NSToolbarItem *)anItem
{
	BSNobiNobiView *aView = [[BSNobiNobiView alloc] init];
	NSSize size_ = NSMakeSize(48, 29);

	[anItem setView:aView];
	[anItem setMinSize:size_];
	[anItem setMaxSize:size_];

	[aView release];
}
@end



@implementation CMRBrowserTbDelegate (NSToolbarDelegate)
- (NSToolbarItem *) toolbar : (NSToolbar *) tb
      itemForItemIdentifier : (NSString  *) itemId
  willBeInsertedIntoToolbar : (BOOL       ) willBeInserted
{
	NSToolbarItem *item;
	item = [super toolbar:tb itemForItemIdentifier:itemId willBeInsertedIntoToolbar:willBeInserted];
	if (item && [itemId isEqualToString:st_NobiNobiItemIdentifier]) {
		[(BSNobiNobiView *)[item view] setShouldDrawBorder:(NO == willBeInserted)];
	}
	return item;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
	static NSArray *s_browser_defaultItemsCache = nil;
	if (!s_browser_defaultItemsCache) {
		s_browser_defaultItemsCache = [[NSArray alloc] initWithObjects:
				st_NobiNobiItemIdentifier,
				st_reloadListItemIdentifier,
				NSToolbarSpaceItemIdentifier,
				[self reloadThreadItemIdentifier],
				[self deleteItemIdentifier],
				[self addFavoritesItemIdentifier],
				NSToolbarSeparatorItemIdentifier,
				[self replyItemIdentifier],
				NSToolbarFlexibleSpaceItemIdentifier,
				st_searchThreadItemIdentifier,
				nil];
	}
	return s_browser_defaultItemsCache;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
	static NSArray *s_browser_allowedItemsCache = nil;
	if (!s_browser_allowedItemsCache) {
		s_browser_allowedItemsCache = [[NSArray alloc] initWithObjects:
				st_reloadListItemIdentifier,
				[self reloadThreadItemIdentifier],
				[self stopTaskIdentifier],
				[self addFavoritesItemIdentifier],
				[self deleteItemIdentifier],
				[self replyItemIdentifier],
				st_searchThreadItemIdentifier,
				st_COEItemIdentifier,
				[self toggleOnlineModeIdentifier],
				[self scaleSegmentedControlIdentifier],
				[self historySegmentedControlIdentifier],
				st_NobiNobiItemIdentifier,
				st_viewModeSwitcherItemIdentifier,
				NSToolbarSeparatorItemIdentifier,
				NSToolbarSpaceItemIdentifier,
				NSToolbarFlexibleSpaceItemIdentifier,
				nil];
	}
	return s_browser_allowedItemsCache;
}

//- (void)adjustNobiNobiViewTbItem:(NSToolbarItem *)item to:(float)width
//{
//}

- (void)toolbarWillAddItem:(NSNotification *)notification
{
	NSToolbarItem *item = [[notification userInfo] objectForKey:@"item"];
	if ([[item itemIdentifier] isEqualToString:st_NobiNobiItemIdentifier]) {
		CMRBrowser *browser = CMRMainBrowser;
		float	width = [[browser boardListSubView] dimension];
		NSSize size_ = NSMakeSize(width-8, 29);
		[item setMinSize:size_];
		[item setMaxSize:size_];
//		[self adjustNobiNobiViewTbItem:item to:width];
	} else if ([[item itemIdentifier] isEqualToString:st_viewModeSwitcherItemIdentifier]) {
		[[item view] bind:@"selectedTag" toObject:CMRPref withKeyPath:@"threadsListViewMode" options:nil];
	}
}

- (void)toolbarDidRemoveItem:(NSNotification *)notification
{
	NSToolbarItem *item = [[notification userInfo] objectForKey:@"item"];
	if ([[item itemIdentifier] isEqualToString:st_viewModeSwitcherItemIdentifier]) {
		[[item view] unbind:@"selectedTag"];
	}
}
@end
