/**
  * $Id: GeneralPrefController.m,v 1.6.2.1 2005/12/17 14:59:49 masakih Exp $
  * 
  * GeneralPrefController.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "GeneralPrefController.h"
#import "PreferencePanes_Prefix.h"

#define kLabelKey		@"General Label"
#define kToolTipKey		@"General ToolTip"
#define kImageName		@"GeneralPreferences"



@implementation GeneralPrefController
- (NSString *) mainNibName
{
	return @"GeneralPreferences";
}

// List
- (IBAction) changeAutoscrollMask : (id) sender
{
	int		mask_ = 0;
	int		cnt = [[self autoscrollMaskCheckBox] numberOfRows];
	int		i;
	
	UTILAssertRespondsTo(sender, @selector(cellWithTag:));
	for(i = 0; i < cnt; i++){
		if(NSOnState == [[[self autoscrollMaskCheckBox] cellWithTag : i] state])
			mask_ = (mask_ | [self autoscrollMaskForTag : i]);
	}
	
	[[self preferences] setThreadsListAutoscrollMask : mask_];
}

- (IBAction) changeIgnoreCharacters : (id) sender
{
	UTILAssertRespondsTo(sender, @selector(stringValue));
	[[self preferences] setIgnoreTitleCharacters : [sender stringValue]];
}
- (IBAction) changeCollectByNew : (id) sender
{
	[[self preferences] setCollectByNew : (NSOnState == [[self collectByNewCheckBox] state])];
}
// Thread
- (IBAction) changeLinkType : (id) sender
{
    NSPopUpButton *popUp = [self resAnchorActionPopUp];
    NSMenuItem *menuItem = (NSMenuItem *)[popUp itemAtIndex : [popUp indexOfSelectedItem]];
    
    [[self preferences] setThreadViewerLinkType : [menuItem tag]];
}
- (IBAction) changeMailAttachShown : (id) sender
{
	[[self preferences] setMailAttachmentShown : (NSOnState == [[self mailAttachCheckBox] state])];
}
- (IBAction) changeMailAddressShown : (id) sender
{
	[[self preferences] setMailAddressShown : (NSOnState == [[self isMailShownCheckBox] state])];
}
- (IBAction) changeShowsAll : (id) sender
{
	[[self preferences] setShowsAllMessagesWhenDownloaded : (NSOnState == [[self showsAllCheckBox] state])];
}

#pragma mark ShortCircuit Additions
/*
	2005-10-08 tsawada2<ben-sawa@td5.so-net.ne.jp>
	firstVisible メソッドの返り値が、ポップアップボタンの各項目の tag とバインドされている。
	ただし、NSNotFound だけは -1 に変換する。NSNotFound は「すべてを表示」に対応している。
	他の項目は、メニューの「xxレス」のxxと tag が同じ数字になっている（やや汎用性に欠ける？）。
	lastVisible も同様。
*/
- (int) firstVisible
{
	if ([[self preferences] firstVisibleCount] == NSNotFound) {
		//NSLog(@"NSNotFound converted to -1");
		return -1;
	}
	return [[self preferences] firstVisibleCount];
}

- (void) setFirstVisible : (int) tag_
{
	if (tag_ == -1) {
		[[self preferences] setFirstVisibleCount : NSNotFound];
		return;
	}
	[[self preferences] setFirstVisibleCount : tag_];
}
- (int) lastVisible
{
	if ([[self preferences] lastVisibleCount] == NSNotFound) {
		//NSLog(@"NSNotFound converted to -1");
		return -1;
	}
	return [[self preferences] lastVisibleCount];
}
- (void) setLastVisible : (int) tag_;
{
	if (tag_ == -1) {
		[[self preferences] setLastVisibleCount : NSNotFound];
		return;
	}
	[[self preferences] setLastVisibleCount : tag_];
}

#pragma mark InnocentStarter Additions
- (BOOL) autoReloadListWhenWake
{
	return [[self preferences] autoReloadListWhenWake];
}
- (void) setAutoReloadListWhenWake : (BOOL) boxState_
{
	[[self preferences] setAutoReloadListWhenWake : boxState_];
}
@end



@implementation GeneralPrefController(Toolbar)
- (NSString *) identifier
{
	return PPGeneralPreferencesIdentifier;
}
- (NSString *) helpKeyword
{
	return PPLocalizedString(@"Help_General");
}
- (NSString *) label
{
	return PPLocalizedString(kLabelKey);
}
- (NSString *) paletteLabel
{
	return PPLocalizedString(kLabelKey);
}
- (NSString *) toolTip
{
	return PPLocalizedString(kToolTipKey);
}
- (NSString *) imageName
{
	return kImageName;
}
@end
