/**
  * $Id: GeneralPrefController.m,v 1.6.2.3 2006/09/01 13:46:54 masakih Exp $
  * 
  * GeneralPrefController.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "GeneralPrefController.h"
#import "PreferencePanes_Prefix.h"
#import <CocoMonar/CocoMonar.h>

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

#pragma mark ShortCircuit Additions
/*
	2005-10-08 tsawada2<ben-sawa@td5.so-net.ne.jp>
	firstVisible メソッドの返り値が、ポップアップボタンの各項目の tag とバインドされている。
	ただし、NSNotFound だけは -1 に変換する。NSNotFound は「すべてを表示」に対応している。
	他の項目は、メニューの「xxレス」のxxと tag が同じ数字になっている（やや汎用性に欠ける？）。
	lastVisible も同様。
*/
/*- (int) firstVisible
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
*/
#pragma mark Vita Additions
- (int) mailFieldOption
{
	BOOL	_mailAddressShown = [[self preferences] mailAddressShown];
	BOOL	_mailIconShown = [[self preferences] mailAttachmentShown];
	
	if (_mailAddressShown && _mailIconShown)
		return 1;
	else if (_mailAddressShown)
		return 0;
	else
		return 2;
}

- (void) setMailFieldOption : (int) selectedTag
{
	
	switch(selectedTag) {
	case 0:
		[[self preferences] setMailAddressShown : YES];
		[[self preferences] setMailAttachmentShown : NO];
		break;
	case 1:
		[[self preferences] setMailAddressShown : YES];
		[[self preferences] setMailAttachmentShown : YES];
		break;
	case 2:
		[[self preferences] setMailAddressShown : NO];
		[[self preferences] setMailAttachmentShown : YES];
		break;
	default:
		break;
	}
}
@end


@implementation GeneralPrefController(View)
- (int) autoscrollMaskForTag : (int) tag
{
	static int masks_[] = {
					CMRAutoscrollWhenTLUpdate,
					CMRAutoscrollWhenTLSort,
					CMRAutoscrollWhenThreadUpdate
			};

	NSAssert2(
		tag >= 0 && tag < UTILNumberOfCArray(masks_),
		@"Accessing over bounds(%d) length = %u",
		tag,
		UTILNumberOfCArray(masks_));
	return masks_[tag];
}

- (NSMatrix *) autoscrollMaskCheckBox
{
	return _autoscrollMaskCheckBox;
}

- (void) updateListUIComponents
{
	int	i;
	int	cnt		= [[self autoscrollMaskCheckBox] numberOfRows];
	int	mask_	= [[self preferences] threadsListAutoscrollMask];
	
	for (i = 0; i < cnt; i++) {
		[[[self autoscrollMaskCheckBox] cellWithTag : i] setState : 
			(([self autoscrollMaskForTag : i] & mask_)
				? NSOnState
				: NSOffState)];
	}
}

- (void) updateUIComponents
{
	[self updateListUIComponents];
}

- (void) setupUIComponents
{
	if (nil == _contentView)
		return;
	
	[self updateUIComponents];
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
