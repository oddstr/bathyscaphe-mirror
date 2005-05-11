/**
  * $Id: PreferencesPane-Toolbar.m,v 1.1 2005/05/11 17:51:11 tsawada2 Exp $
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

/*
���ݎg���Ă��Ȃ�
static void makeToolbarItemInDictionary(
				NSString            *identifier,
				NSMutableDictionary *dictionary,
				NSString            *label,
				NSString            *paletteLabel,
				NSString            *toolTip,
				id                   target,
				SEL                  settingSelector,
				id                   itemContent,
				SEL                  action,
				NSMenu              *menu);


#define DefineStaticStr(symbol, value)		static NSString *const symbol = value
DefineStaticStr(ShowAllLabelKey, @"Label for ShowAll");
DefineStaticStr(ShowAllToolTipKey, @"ToolTip for ShowAll");

*/


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
  * �c�[���o�[�ɍ��ڂ��ǉ������Ƃ���
  * �Ă΂�郁�\�b�h�B
  * 
  * @param    notification  NSToolbarWillAddItemNotification
  */

- (void) toolbarWillAddItem : (NSNotification *) notification
{
	NSString *name_;
	
	name_ = [notification name];
	if([name_ isEqualToString : NSToolbarWillAddItemNotification]){
		NSToolbarItem *item_;
		NSString      *identifier_;
		
		item_ = [[notification userInfo] objectForKey:@"item"];
		if(nil == item_) return;
		
		identifier_ = [item_ itemIdentifier];
		
		if(nil == identifier_) return;
		/*
		if([identifier_ isEqualToString : PPShowAllIdentifier]){
			SEL runTcp_;
			
			runTcp_ = @selector(runToolbarCustomizationPalette:);
			
			[item_ setTarget : [self window]];
			[item_ setAction : runTcp_];
		}
		*/
	}
}

/**
  * ����itemIdentifier�Ŏw�肳�ꂽ�c�[���o�[�̍��ڂ�Ԃ��B
  * �d�����鍀�ڂ����肦��̂ŁA�R�s�[���쐬���邱�ƁB
  * 
  * @param    toolbar         �c�[���o�[
  * @param    itemIdentifier  ���ʎq
  * @param    flag            ���ڂ��ǉ������ꍇ��YES
  * @return                   �c�[���o�[�̍���
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
				PPAccountSettingsIdentifier,
				PPFilterPreferencesIdentifier,
				PPFontsAndColorsIdentifier,
				PPReplyDefaultIdentifier,
				NSToolbarFlexibleSpaceItemIdentifier,
				nil];
}

- (NSArray *) toolbarAllowedItemIdentifiers : (NSToolbar *) toolbar
{
	if(NO == [[toolbar identifier] isEqualToString : PPToolbarIdentifier])
		return [NSArray empty];
	
	return [NSArray arrayWithObjects :
				PPGeneralPreferencesIdentifier,
				PPAccountSettingsIdentifier,
				PPFilterPreferencesIdentifier,
				PPFontsAndColorsIdentifier,
				PPReplyDefaultIdentifier,
				NSToolbarFlexibleSpaceItemIdentifier,
				nil];
}

/*
Mac OS X 10.3�ȏ�ŁA�c�[���o�[�őI������Ă��鍀�ڂ��n�C���C�g���邽�߂̎d�|��
�n�C���C�g�������鍀�ڂ̔z�������ēn���B
10.2.x�ȑO�ł͂��̃��\�b�h�͌Ă΂�Ȃ��B
*/
- (NSArray *) toolbarSelectableItemIdentifiers : (NSToolbar *) toolbar
{
	if(NO == [[toolbar identifier] isEqualToString : PPToolbarIdentifier])
		return [NSArray empty];
	
	return [NSArray arrayWithObjects :
				PPGeneralPreferencesIdentifier,
				PPAccountSettingsIdentifier,
				PPFilterPreferencesIdentifier,
				PPFontsAndColorsIdentifier,
				PPReplyDefaultIdentifier,
				nil];
}

- (NSImage *) _imageResourceWithName : (NSString *) name
{
	NSBundle *bundle_;
	NSString *filepath_;
	bundle_ = [NSBundle bundleForClass : [self class]];
	filepath_ = [bundle_ pathForImageResource : name];
	
	if(nil == filepath_) return nil;
	
	return [[[NSImage alloc] initWithContentsOfFile : filepath_] autorelease];
}

- (NSImage *) _toolbarIconWithName : (NSString *) name
{
	static NSSize _tbItemSize = {32, 32};
	NSImage *tbItemImage_;
	NSSize   oldSize_;
	NSSize   newSize_;
	
	tbItemImage_ = [self _imageResourceWithName : name];
	if(nil == tbItemImage_) return nil;

	newSize_.width = (oldSize_.width <= _tbItemSize.width)
						? oldSize_.width 
						: _tbItemSize.width;
	newSize_.height = (oldSize_.height <= _tbItemSize.height)
						? oldSize_.height 
						: _tbItemSize.height;
	if(NO == NSEqualSizes(newSize_, _tbItemSize)){
		[tbItemImage_ setSize : newSize_];
	}
	
	return tbItemImage_;
}

- (void) setupToolbar
{
	NSToolbar				*toolbar_;
	NSToolbarItem			*tbItem_;
	NSEnumerator			*iter_;
	PreferencesController	*controller_;
	SEL action_ = @selector(selectController:);
	
	toolbar_= [[NSToolbar alloc] initWithIdentifier : PPToolbarIdentifier];
	/*
	makeToolbarItemInDictionary(
		PPShowAllIdentifier,
	    [self toolbarItems],
		PPLocalizedString(ShowAllLabelKey),
		PPLocalizedString(ShowAllLabelKey),
		PPLocalizedString(ShowAllToolTipKey),
	    [self window],
	    @selector(setImage:),
	    [[NSApplication sharedApplication] applicationIconImage],
	    @selector(runToolbarCustomizationPalette:),
	    NULL);
	*/
	
	
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
	
/*
2003-11-11 Takanori Ishikawa <takanori@gd5.so-net.ne.jp>
--------------------------------------------------------
���s����OS�o�[�W�����`�F�b�N
NSAppKitVersionNumber�ł���Ă������񂾂��ǁA10.2�Ńr���h���Ă���̂�
Objective-C�Ȃ�respondsToSelector:�Ń`�F�b�N���Ă����S
*/
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_3
	
	if([toolbar_ respondsToSelector : @selector(setSelectedItemIdentifier:)]){
		
		//Mac OS X 10.3�ȍ~�ł́A�y�C���ɉ����ăc�[���o�[�{�^�����n�C���C�g������B
		//�ŏ��Ɂu���ݒ�v���J�����ɁA�n�C���C�g����Ă���ׂ��c�[���o�[�{�^���͉����H
		NSUserDefaults *defaults_;
		NSString       *shouldSelectedTbIdentifier_;
		
		defaults_ = [NSUserDefaults standardUserDefaults];
		shouldSelectedTbIdentifier_ = [defaults_ stringForKey : PPLastOpenPaneIdentifier];
		//�Ō�ɊJ���Ă����y�C�����킩��Ȃ��ꍇ�A�u�\���v�y�C���ɂ���B�����u�\���v�c�[���o�[�{�^����I���B
		if(nil == shouldSelectedTbIdentifier_)
		        shouldSelectedTbIdentifier_ = PPFontsAndColorsIdentifier;
		
		// �n�C���C�g������
		
		[toolbar_ setSelectedItemIdentifier: shouldSelectedTbIdentifier_];
	}
	
#endif
	
	[[self window] setToolbar : toolbar_];
	[toolbar_ release];
}
@end



/*
���ݎg���Ă��Ȃ�

static void makeToolbarItemInDictionary(
				NSString            *identifier,
				NSMutableDictionary *dictionary,
				NSString            *label,
				NSString            *paletteLabel,
				NSString            *toolTip,
				id                   target,
				SEL                  settingSelector,
				id                   itemContent,
				SEL                  action,
				NSMenu              *menu)
{
	NSToolbarItem		*item_;
	
	item_ = [[NSToolbarItem alloc] initWithItemIdentifier : identifier];
	[item_ setLabel : label];
	[item_ setPaletteLabel : paletteLabel];
	[item_ setToolTip : toolTip];
	[item_ setTarget : target];
	[item_ performSelector : settingSelector withObject : itemContent];
	[item_ setAction : action];
	
	if(menu != nil){
		NSMenuItem		*mItem = [[NSMenuItem alloc] init];
		
		[mItem setSubmenu : menu];
		[mItem setTitle : [menu title]];
		[item_ setMenuFormRepresentation : mItem];
		[mItem release];
	}
	[dictionary setObject:item_ forKey:identifier];
	[item_ release];
}

*/
