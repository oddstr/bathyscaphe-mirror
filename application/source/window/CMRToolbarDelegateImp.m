//:CMRToolbarDelegateImp.m
#import "CMRToolbarDelegateImp_p.h"

@implementation CMRToolbarDelegateImp
//////////////////////////////////////////////////////////////////////
/////////////////////// [ 初期化・後始末 ] ///////////////////////////
//////////////////////////////////////////////////////////////////////
- (void) dealloc
{
	[m_itemDictionary release];
	[super dealloc];
}
//////////////////////////////////////////////////////////////////////
//////////////////// [ インスタンスメソッド ] ////////////////////////
//////////////////////////////////////////////////////////////////////
- (NSString *) identifier
{
	return nil;
}

- (NSToolbarItem *) itemForItemIdentifier : (NSString *) anIdentifier
{
	return [self itemForItemIdentifier:anIdentifier itemClass:[NSToolbarItem class]];
}

- (void) attachToolbarWithWindow : (NSWindow *) aWindow
{
	NSToolbar		*toolbar_;
	
	UTILAssertNotNilArgument(aWindow, @"Window");
	
	toolbar_ = [[NSToolbar alloc] initWithIdentifier : [self identifier]];
	
	[self configureToolbar : toolbar_];
	[self initializeToolbarItems : aWindow];
	[toolbar_ setDelegate : self];
	
	[aWindow setToolbar : toolbar_];
	[toolbar_ release];
}
@end



@implementation CMRToolbarDelegateImp(Private)
- (NSToolbarItem *) itemForItemIdentifier : (NSString *) anIdentifier
								itemClass : (Class	   ) aClass
{
	NSToolbarItem		*item_;
	item_ = [[self itemDictionary] objectForKey : anIdentifier];
	if(nil == item_){
		item_ = [[aClass alloc] initWithItemIdentifier : anIdentifier];
		[[self itemDictionary] setObject : item_ forKey : anIdentifier];
		[item_ release];
	}
	return item_;
}
- (NSToolbarItem *) appendToolbarItemWithClass : (Class		) aClass
								itemIdentifier : (NSString *) itemIdentifier
							 localizedLabelKey : (NSString *) label
					  localizedPaletteLabelKey : (NSString *) paletteLabel
						   localizedToolTipKey : (NSString *) toolTip
										action : (SEL       ) action
										target : (id        ) target
{
	NSToolbarItem		*item_;
	
	item_ = [self itemForItemIdentifier:itemIdentifier itemClass:aClass];
	[item_ setLabel : [self localizedString : label]];
	[item_ setPaletteLabel : [self localizedString : paletteLabel]];
	[item_ setToolTip : [self localizedString : toolTip]];
	[item_ setAction : action];
	[item_ setTarget : target];
	return item_;
}
- (NSToolbarItem *) appendToolbarItemWithItemIdentifier : (NSString *) itemIdentifier
                                      localizedLabelKey : (NSString *) label
                               localizedPaletteLabelKey : (NSString *) paletteLabel
                                    localizedToolTipKey : (NSString *) toolTip
                                                 action : (SEL       ) action
                                                 target : (id        ) target
{
	return [self appendToolbarItemWithClass : [NSToolbarItem class]
							 itemIdentifier : itemIdentifier
						  localizedLabelKey : label
				   localizedPaletteLabelKey : paletteLabel
						localizedToolTipKey : toolTip
									 action : action
									 target : target];
}

- (NSMutableDictionary *) itemDictionary
{
	if(nil == m_itemDictionary)
		m_itemDictionary = [[NSMutableDictionary alloc] init];
	return m_itemDictionary;
}
@end



@implementation CMRToolbarDelegateImp(Protected)
- (void) initializeToolbarItems : (NSWindow *) aWindow
{
	UTILAbstractMethodInvoked;
}

- (void) configureToolbar : (NSToolbar *) aToolbar
{
	UTILAbstractMethodInvoked;
}
@end
