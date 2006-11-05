/**
  * $Id: PreferencesPane-Toolbar.m,v 1.5 2006/11/05 13:02:22 tsawada2 Exp $
  * 
  * PreferencesPane-Toolbar.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "PreferencesPane.h"
#import "PreferencesController.h"
#import "AppDefaults.h"
#import "PreferencePanes_Prefix.h"

@implementation PreferencesPane(ToolbarSupport)
/* Accessor for _toolbarItems */
- (NSMutableDictionary *) toolbarItems
{
	if(nil == _toolbarItems){
		_toolbarItems = [[NSMutableDictionary alloc] init];
	}
	return _toolbarItems;
}


/**
  * 引数itemIdentifierで指定されたツールバーの項目を返す。
  * 重複する項目もありえるので、コピーを作成すること。
  * 
  * @param    toolbar         ツールバー
  * @param    itemIdentifier  識別子
  * @param    flag            項目が追加される場合はYES
  * @return                   ツールバーの項目
  */

- (NSToolbarItem *) toolbar : (NSToolbar *) toolbar
      itemForItemIdentifier : (NSString  *) itemIdentifier
  willBeInsertedIntoToolbar : (BOOL       ) flag
{
	NSToolbarItem	*item_;
	NSString		*name_;
	NSToolbarItem	*newItem_;
	NSArray			*list_;
	
	item_ = [[self toolbarItems] objectForKey : itemIdentifier];
	name_ = [item_ itemIdentifier];

	list_ = flag ? [self toolbarDefaultItemIdentifiers : toolbar]
	             : [self toolbarAllowedItemIdentifiers : toolbar];
	
	newItem_ = [item_ copyWithZone : [self zone]];
	
	if(NSNotFound == [list_ indexOfObject : name_]){
		[newItem_ release];
		return nil;
	}
	[newItem_ setTarget : self];
	if ([newItem_ view] != nil) {
		[newItem_ setMinSize : [[newItem_ view] bounds].size];
		[newItem_ setMaxSize : [[newItem_ view] bounds].size];
	}
	
	return [newItem_ autorelease];
}

- (NSArray *) toolbarDefaultItemIdentifiers : (NSToolbar *) toolbar
{
	if(NO == [[toolbar identifier] isEqualToString : PPToolbarIdentifier])
		return [NSArray empty];
	
	return [NSArray arrayWithObjects :
				PPGeneralPreferencesIdentifier,
				PPFontsAndColorsIdentifier,
				PPAccountSettingsIdentifier,
				PPSyncPreferencesIdentifier,
				PPFilterPreferencesIdentifier,
				PPReplyDefaultIdentifier,
				PPSoundsPreferencesIdentifier,
				PPAdvancedPreferencesIdentifier,
				NSToolbarFlexibleSpaceItemIdentifier,
				nil];
}

- (NSArray *) toolbarAllowedItemIdentifiers : (NSToolbar *) toolbar
{
	if(NO == [[toolbar identifier] isEqualToString : PPToolbarIdentifier])
		return [NSArray empty];
	
	return [NSArray arrayWithObjects :
				PPGeneralPreferencesIdentifier,
				PPFontsAndColorsIdentifier,
				PPAccountSettingsIdentifier,
				PPSyncPreferencesIdentifier,
				PPFilterPreferencesIdentifier,
				PPReplyDefaultIdentifier,
				PPSoundsPreferencesIdentifier,
				PPAdvancedPreferencesIdentifier,
				NSToolbarFlexibleSpaceItemIdentifier,
				nil];
}

- (NSArray *) toolbarSelectableItemIdentifiers : (NSToolbar *) toolbar
{
	if(NO == [[toolbar identifier] isEqualToString : PPToolbarIdentifier])
		return [NSArray empty];
	
	return [NSArray arrayWithObjects :
				PPGeneralPreferencesIdentifier,
				PPFontsAndColorsIdentifier,
				PPAccountSettingsIdentifier,
				PPSyncPreferencesIdentifier,
				PPFilterPreferencesIdentifier,
				PPReplyDefaultIdentifier,
				PPSoundsPreferencesIdentifier,
				PPAdvancedPreferencesIdentifier,
				nil];
}

- (void) setupToolbar
{
	NSToolbar				*toolbar_;
	NSToolbarItem			*tbItem_;
	NSEnumerator			*iter_;
	PreferencesController	*controller_;
	SEL action_ = @selector(selectController:);
	
	toolbar_= [[NSToolbar alloc] initWithIdentifier : PPToolbarIdentifier];
	
	iter_ = [[self controllers] objectEnumerator];
	while(controller_ = [iter_ nextObject]){
		if(nil == [controller_ identifier])
			continue;
		
		tbItem_ = [controller_ makeToolbarItem];
		[[self toolbarItems] setObject:tbItem_ forKey:[tbItem_ itemIdentifier]];
		[tbItem_ setTarget : self];
		[tbItem_ setAction : action_];
		[tbItem_ release];
	}
	
	[toolbar_ setDelegate : self];
	[toolbar_ setAllowsUserCustomization : NO];
	[toolbar_ setAutosavesConfiguration : NO];
	
	[[self window] setToolbar : toolbar_];
	[toolbar_ release];
}
@end
