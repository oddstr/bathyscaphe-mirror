//
//  CMRBrowserTbDelegate.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/07/27.
//  Copyright 2007-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRBrowserTbDelegate.h"
#import "CMRToolbarDelegateImp_p.h"
#import "CMRBrowser_p.h"
#import "BSNobiNobiToolbarItem.h"
#import "BSNSControlTbItem.h"

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

// Quick Look
// Testing...
static NSString *const st_QLItemIdentifier = @"Quick Look";
static NSString *const st_QLItemLabelKey = @"Quick Look Label";
static NSString *const st_QLItemToolTipKey = @"Quick Look ToolTip";

// Toolbar Identifier Constant
static NSString *const st_toolbar_identifier			= @"Browser Window Toolbar";

@implementation CMRBrowserTbDelegate
- (NSString *)identifier
{
	return st_toolbar_identifier;
}
@end


@implementation CMRBrowserTbDelegate(Protected)
- (void)initializeToolbarItems:(NSWindow *)aWindow
{
	NSToolbarItem			*item_;
	CMRBrowser				*wcontroller_;
	
	[super initializeToolbarItems:aWindow];

	wcontroller_ = (CMRBrowser*)[aWindow windowController];
	UTILAssertNotNil(wcontroller_);

	item_ = [self appendToolbarItemWithItemIdentifier:st_reloadListItemIdentifier
									localizedLabelKey:st_reloadListItemLabelKey
							 localizedPaletteLabelKey:st_reloadListItemPaletteLabelKey
								  localizedToolTipKey:st_reloadListItemToolTipKey
											   action:@selector(reloadThreadsList:)
											   target:wcontroller_];
	[item_ setImage:[NSImage imageAppNamed:st_reloadList_ImageName]];

	item_ = [self appendToolbarItemWithItemIdentifier:st_searchThreadItemIdentifier
									localizedLabelKey:st_searchThreadItemLabelKey
							 localizedPaletteLabelKey:st_searchThreadItemPaletteLabelKey
								  localizedToolTipKey:st_searchThreadItemToolTipKey
											   action:NULL
											   target:wcontroller_];
	[self setupSearchToolbarItem:item_ itemView:[wcontroller_ searchField]];

	item_ = [self appendToolbarItemWithClass:[BSSegmentedControlTbItem class]
							  itemIdentifier:st_viewModeSwitcherItemIdentifier
						   localizedLabelKey:st_viewModeSwitcherItemLabelKey
					localizedPaletteLabelKey:st_viewModeSwitcherItemPaletteLabelKey
						 localizedToolTipKey:st_viewModeSwitcherItemToolTipKey
									  action:NULL
									  target:nil];

	[self setupSwitcherToolbarItem:item_ itemView:[wcontroller_ viewModeSwitcher] delegate:wcontroller_ windowStyle:[aWindow styleMask]];

	item_ = [self appendToolbarItemWithClass:[BSNobiNobiToolbarItem class]
							  itemIdentifier:st_NobiNobiItemIdentifier
						   localizedLabelKey:@""
					localizedPaletteLabelKey:st_NobiNobiPaletteLabelKey
						 localizedToolTipKey:@""
									  action:NULL
									  target:nil];
	[self setupNobiNobiToolbarItem:item_];

	item_ = [self appendToolbarItemWithClass:[BSNSControlToolbarItem class] itemIdentifier:st_QLItemIdentifier
						   localizedLabelKey:st_QLItemLabelKey
					localizedPaletteLabelKey:st_QLItemLabelKey
						 localizedToolTipKey:st_QLItemToolTipKey
									  action:NULL
									  target:nil];
	[self setupQuickLookButton:item_];

	item_ = [self appendToolbarItemWithItemIdentifier:st_COEItemIdentifier
									localizedLabelKey:st_COEItemLabelKey
							 localizedPaletteLabelKey:st_COEItemPaletteLabelKey
								  localizedToolTipKey:st_COEItemToolTipKey
											   action:@selector(collapseOrExpandBoardList:)
											   target:wcontroller_];
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

- (void)setupQuickLookButton:(NSToolbarItem *)anItem
{
	// Leopard
	if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_4) {	
		if (!m_quickLookToolbarItem) {
			[NSBundle loadNibNamed:@"BSQuickLookButton" owner:self];
		}

		UTILAssertNotNil(m_quickLookToolbarItem);
		NSSize size_ = [m_quickLookToolbarItem frame].size;

		[anItem setView:m_quickLookToolbarItem];
		[anItem setMinSize:size_];
		[anItem setMaxSize:size_];

		NSMenuItem *menuItem_ = [[NSMenuItem alloc] initWithTitle:[anItem label] action:@selector(quickLook:) keyEquivalent:@""];
		[menuItem_ setTarget:nil];
		[anItem setMenuFormRepresentation:menuItem_];
		[menuItem_ release];
	}
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

- (void)setupSwitcherToolbarItem:(NSToolbarItem *)anItem itemView:(NSView *)aView delegate:(id)delegate windowStyle:(unsigned int)styleMask
{
	NSSize size_;

	[aView retain];
	[aView removeFromSuperviewWithoutNeedingDisplay];	
	[anItem setView:aView];
		
	size_ = [aView bounds].size;
	if (styleMask & NSTexturedBackgroundWindowMask || styleMask & NSUnifiedTitleAndToolbarWindowMask) size_.height += 1;
	[anItem setMinSize:size_];
	[anItem setMaxSize:size_];

	[aView release];
	[(BSSegmentedControlTbItem *)anItem setDelegate:delegate];
}

- (void)setupNobiNobiToolbarItem:(NSToolbarItem *)anItem
{
	BSNobiNobiView *aView = [[BSNobiNobiView alloc] initWithFrame:NSMakeRect(0,0,48,22)];
	NSSize size_ = NSMakeSize(48, 22);

	[anItem setView:aView];
	[anItem setMinSize:size_];
	[anItem setMaxSize:size_];

	[aView release];
}

- (NSArray *)unsupportedItemsArray
{
	static NSArray *br_cachedArray = nil;

	if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_4) {
		return [super unsupportedItemsArray];
	}
	// Tiger
	if (!br_cachedArray) {
		br_cachedArray = [[[super unsupportedItemsArray] arrayByAddingObject:st_QLItemIdentifier] retain];
	}
	return br_cachedArray;
}
@end



@implementation CMRBrowserTbDelegate(NSToolbarDelegate)
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemId willBeInsertedIntoToolbar:(BOOL)willBeInserted
{
	NSToolbarItem *item;
	item = [super toolbar:toolbar itemForItemIdentifier:itemId willBeInsertedIntoToolbar:willBeInserted];
	if (item && [itemId isEqualToString:st_NobiNobiItemIdentifier]) {
		[(BSNobiNobiView *)[item view] setShouldDrawBorder:(NO == willBeInserted)];
	}
	return item;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:
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

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:
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
				st_QLItemIdentifier,
				NSToolbarSeparatorItemIdentifier,
				NSToolbarSpaceItemIdentifier,
				NSToolbarFlexibleSpaceItemIdentifier,
				nil];
}

- (void)toolbarWillAddItem:(NSNotification *)notification
{
	NSToolbarItem *item = [[notification userInfo] objectForKey:@"item"];
	if ([[item itemIdentifier] isEqualToString:st_NobiNobiItemIdentifier]) {
		CMRBrowser *browser = CMRMainBrowser;
		UTILAssertNotNil(browser);
		float	width = [[browser boardListSubView] dimension];
		if (width <= 0) NSLog(@"WARNING!");
		NSSize size_ = NSMakeSize(width-8, 22);
		[item setMinSize:size_];
		[item setMaxSize:size_];
	}
}
@end
