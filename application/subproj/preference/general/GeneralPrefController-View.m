/**
  * $Id: GeneralPrefController-View.m,v 1.4 2005/07/29 21:18:28 tsawada2 Exp $
  * 
  * GeneralPrefController-View.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "GeneralPrefController.h"
#import <CocoMonar/CocoMonar.h>



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
- (NSButton *) collectByNewCheckBox
{
	return _collectByNewCheckBox;
}
- (NSTextField *) ignoreCharsField
{
	return _ignoreCharsField;
}
- (NSPopUpButton *) resAnchorActionPopUp
{
	return _resAnchorActionPopUp;
}
- (NSButton *) isMailShownCheckBox
{
	return _isMailShownCheckBox;
}
- (NSButton *) showsAllCheckBox
{
	return _showsAllCheckBox;
}
- (NSButton *) mailAttachCheckBox
{
	return _mailAttachCheckBox;
}
- (NSPopUpButton *) openInBrowserPopUp;
{
	return _openInBrowserPopUp;
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
	
	[[self ignoreCharsField] setStringValue : [[self preferences] ignoreTitleCharacters]];
	if ([[self collectByNewCheckBox] isEnabled]) {
		[[self collectByNewCheckBox] setState : ([[self preferences] collectByNew] ? NSOnState : NSOffState)];
	}
}
- (void) updateThreadUIComponents
{
	if ([[self resAnchorActionPopUp] isEnabled]) {
        [[self resAnchorActionPopUp] selectItemAtIndex : 
            [[self resAnchorActionPopUp] indexOfItemWithTag : 
                [[self preferences] threadViewerLinkType]]];
	}

	if ([[self mailAttachCheckBox] isEnabled]) {
		[[self mailAttachCheckBox] setState : 
			([[self preferences] mailAttachmentShown] ? NSOnState : NSOffState)];
	}
	if ([[self isMailShownCheckBox] isEnabled]) {
		[[self isMailShownCheckBox] setState : ([[self preferences] mailAddressShown] ? NSOnState : NSOffState)];
	}
	if ([[self showsAllCheckBox] isEnabled]) {
		[[self showsAllCheckBox] setState : ([[self preferences] showsAllMessagesWhenDownloaded] ? NSOnState : NSOffState)];
	}
	if ([[self openInBrowserPopUp] isEnabled]) {
        [[self openInBrowserPopUp] selectItemAtIndex : 
            [[self openInBrowserPopUp] indexOfItemWithTag : 
                [[self preferences] openInBrowserType]]];
	}

}

- (void) updateUIComponents
{
	[self updateListUIComponents];
	[self updateThreadUIComponents];
}

- (void) setupListUIComponents
{
	[self preferencesRespondsTo : @selector(ignoreTitleCharacters)
					  ofControl : [self ignoreCharsField]];
	[self preferencesRespondsTo : @selector(collectByNew)
					  ofControl : [self collectByNewCheckBox]];
}
- (void) setupThreadUIComponents
{
	[self preferencesRespondsTo : @selector(threadViewerLinkType)
					  ofControl : [self resAnchorActionPopUp]];
	[self preferencesRespondsTo : @selector(mailAttachmentShown)
					  ofControl : [self mailAttachCheckBox]];
	[self preferencesRespondsTo : @selector(mailAddressShown)
					  ofControl : [self showsAllCheckBox]];
	[self preferencesRespondsTo : @selector(showsAllMessagesWhenDownloaded)
					  ofControl : [self mailAttachCheckBox]];
	[self preferencesRespondsTo : @selector(openInBrowserType)
					  ofControl : [self openInBrowserPopUp]];
}


- (void) setupUIComponents
{
	if (nil == _contentView)
		return;
	
	[self setupListUIComponents];
	[self setupThreadUIComponents];
	
	[self updateUIComponents];
}
@end
