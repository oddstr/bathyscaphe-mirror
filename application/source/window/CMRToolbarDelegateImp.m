//
//  CMRToolbarDelegateImp.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/08/05.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRToolbarDelegateImp_p.h"

static NSString *const st_pIndicatorItemIdentifier		= @"progressIndicator";

static NSString *const st_localizableStringsTableName	= @"ToolbarItems";

@implementation CMRToolbarDelegateImp
- (void)dealloc
{
	[m_itemDictionary release];
	[super dealloc];
}

+ (NSString *)localizableStringsTableName
{
	return st_localizableStringsTableName;
}

#pragma mark CMRToolbarDelegate Protocol
- (NSString *)identifier
{
	return nil;
}

- (NSToolbarItem *)itemForItemIdentifier:(NSString *)anIdentifier
{
	if ([[self unsupportedItemsArray] containsObject:anIdentifier]) return nil;
	return [self itemForItemIdentifier:anIdentifier itemClass:[NSToolbarItem class]];
}

- (void)attachToolbarWithWindow:(NSWindow *)aWindow
{
	NSToolbar		*toolbar_;
	
	UTILAssertNotNilArgument(aWindow, @"Window");
	
	toolbar_ = [[NSToolbar alloc] initWithIdentifier:[self identifier]];

	[self configureToolbar:toolbar_];
	[self initializeToolbarItems:aWindow];
	[toolbar_ setDelegate:self];

	[aWindow setToolbar:toolbar_];
	[toolbar_ release];
}
@end


@implementation CMRToolbarDelegateImp(Private)
- (NSToolbarItem *)itemForItemIdentifier:(NSString *)anIdentifier itemClass:(Class)aClass
{
	NSToolbarItem		*item_;
	item_ = [[self itemDictionary] objectForKey:anIdentifier];
	if(!item_){
		item_ = [[aClass alloc] initWithItemIdentifier:anIdentifier];
		[[self itemDictionary] setObject:item_ forKey:anIdentifier];
		[item_ release];
	}
	return item_;
}

- (NSToolbarItem *)appendToolbarItemWithClass:(Class) aClass
							   itemIdentifier:(NSString *)itemIdentifier
							localizedLabelKey:(NSString *)label
					 localizedPaletteLabelKey:(NSString *)paletteLabel
						  localizedToolTipKey:(NSString *)toolTip
									   action:(SEL)action
									   target:(id)target
{
	NSToolbarItem		*item_;
	
	item_ = [self itemForItemIdentifier:itemIdentifier itemClass:aClass];
	[item_ setLabel:[self localizedString:label]];
	[item_ setPaletteLabel:[self localizedString:paletteLabel]];
	[item_ setToolTip:[self localizedString:toolTip]];
	[item_ setAction:action];
	[item_ setTarget:target];
	return item_;
}

- (NSToolbarItem *)appendToolbarItemWithItemIdentifier:(NSString *)itemIdentifier
									 localizedLabelKey:(NSString *)label
							  localizedPaletteLabelKey:(NSString *)paletteLabel
								   localizedToolTipKey:(NSString *)toolTip
												action:(SEL)action
												target:(id)target
{
	return [self appendToolbarItemWithClass:[NSToolbarItem class]
							 itemIdentifier:itemIdentifier
						  localizedLabelKey:label
				   localizedPaletteLabelKey:paletteLabel
						localizedToolTipKey:toolTip
									 action:action
									 target:target];
}

-(NSArray *)unsupportedItemsArray
{
	static NSArray *cachedUnsupportedItems = nil;
	if (!cachedUnsupportedItems) {
		cachedUnsupportedItems = [[NSArray alloc] initWithObjects:st_pIndicatorItemIdentifier, nil];
	}
	return cachedUnsupportedItems;
}

- (NSMutableDictionary *)itemDictionary
{
	if(!m_itemDictionary) {
		m_itemDictionary = [[NSMutableDictionary alloc] init];
	}
	return m_itemDictionary;
}
@end


@implementation CMRToolbarDelegateImp(Protected)
- (void)initializeToolbarItems:(NSWindow *)aWindow
{
	UTILAbstractMethodInvoked;
}

- (void)configureToolbar:(NSToolbar *)aToolbar
{
	UTILAbstractMethodInvoked;
}
@end

@implementation CMRToolbarDelegateImp(NSToolbarDelegate)
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemId willBeInsertedIntoToolbar:(BOOL)willBeInserted
{
	UTILAssertNotNilArgument(toolbar, @"Toolbar");
	UTILAssertNotNilArgument(itemId, @"itemIdentifier");
	
	if(![[self identifier] isEqualToString:[toolbar identifier]]) return nil;

	return [self itemForItemIdentifier:itemId];
}
@end
