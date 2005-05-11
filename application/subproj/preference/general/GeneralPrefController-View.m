/**
  * $Id: GeneralPrefController-View.m,v 1.1.1.1 2005/05/11 17:51:10 tsawada2 Exp $
  * 
  * GeneralPrefController-View.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "GeneralPrefController.h"
#import <CocoMonar/CocoMonar.h>



@implementation GeneralPrefController(View)
//- (NSTextField *) dataRootPathField
//{
//	return _dataRootPathField;
//}
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
- (NSMatrix *) drawerEdgeMaskMatrix
{
	return _drawerEdgeMaskMatrix;
}
- (NSMatrix *) collectByNewMatrix
{
	return _collectByNewMatrix;
}
- (NSTextField *) ignoreCharsField
{
	return _ignoreCharsField;
}
- (NSPopUpButton *) resAnchorActionPopUp
{
	return _resAnchorActionPopUp;
}
- (NSMatrix *) isMailShownMatrix
{
	return _isMailShownMatrix;
}
- (NSMatrix *) showsAllMatrix
{
	return _showsAllMatrix;
}
- (NSButton *) mailAttachCheckBox
{
	return _mailAttachCheckBox;
}
- (NSPopUpButton *) openInBrowserPopUp;
{
	return _openInBrowserPopUp;
}
// Proxy
- (NSButton *) usesProxyCheckBox
{
	return _usesProxyCheckBox;
}
- (NSButton *) proxyWhenPOSTCheckBox
{
	return _proxyWhenPOSTCheckBox;
}
- (NSButton *) usesSystemConfigProxyCheckBox
{
	return _usesSystemConfigProxyCheckBox;
}
- (NSTextField *) proxyURLField
{
	return _proxyURLField;
}
- (NSTextField *) proxyPortField
{
	return _proxyPortField;
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
	if ([[self collectByNewMatrix] isEnabled]) {
		int		tag_;
		
		tag_ = [[self preferences] collectByNew] ? 0 : 1;
		[[self collectByNewMatrix] deselectSelectedCell];
		[[self collectByNewMatrix] selectCellWithTag : tag_];
	}

	int	tag2_;
	tag2_ = (int)[[self preferences] boardListDrawerEdge];
	[[self drawerEdgeMaskMatrix] deselectSelectedCell];
	[[self drawerEdgeMaskMatrix] selectCellWithTag : tag2_];
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
	if ([[self isMailShownMatrix] isEnabled]) {
		int		tag_;
		
		tag_ = [[self preferences] mailAddressShown] ? 0 : 1;
		[[self isMailShownMatrix] deselectSelectedCell];
		[[self isMailShownMatrix] selectCellWithTag : tag_];
	}
	if ([[self showsAllMatrix] isEnabled]) {
		int		tag_;
		
		tag_ = [[self preferences] showsAllMessagesWhenDownloaded] ? 0 : 1;
		[[self showsAllMatrix] deselectSelectedCell];
		[[self showsAllMatrix] selectCellWithTag : tag_];
	}
	if ([[self openInBrowserPopUp] isEnabled]) {
        [[self openInBrowserPopUp] selectItemAtIndex : 
            [[self openInBrowserPopUp] indexOfItemWithTag : 
                [[self preferences] openInBrowserType]]];
	}

}
- (void) updateProxyUIComponents
{
	BOOL		usesProxy_;
	BOOL		syncSysConfing;
	NSString	*proxyHost_;
	CFIndex		proxyPort_;
	
	if (NO == [[self usesProxyCheckBox] isEnabled] &&
	   NO == [[self proxyWhenPOSTCheckBox] isEnabled] &&
	   NO == [[self proxyURLField] isEnabled] &&
	   NO == [[self proxyPortField] isEnabled] &&
	   NO == [[self usesSystemConfigProxyCheckBox] isEnabled])
	{ return; }
	
	usesProxy_ = [[self preferences] usesProxy];
	syncSysConfing = [[self preferences] usesSystemConfigProxy];
	[[self preferences] getProxy:&proxyHost_ port:&proxyPort_];
	
	[[self usesProxyCheckBox] setState : 
		(usesProxy_ ? NSOnState : NSOffState)];
	[[self proxyWhenPOSTCheckBox] setState : 
		([[self preferences] usesProxyOnlyWhenPOST] ? NSOnState : NSOffState)];
	[[self usesSystemConfigProxyCheckBox] setState : 
		(syncSysConfing ? NSOnState : NSOffState)];
	
	/* configure UI components */
	[[self usesSystemConfigProxyCheckBox] setEnabled : usesProxy_];
	[[self proxyWhenPOSTCheckBox] setEnabled : usesProxy_];
	[[self proxyURLField] setEnabled : usesProxy_];
	[[self proxyPortField] setEnabled : usesProxy_];
	
	[[self proxyURLField] setEditable : (NO == syncSysConfing)];
	[[self proxyPortField] setEditable : (NO == syncSysConfing)];
	
	
	[[self proxyURLField] setStringValue : 
		proxyHost_ ? proxyHost_: @""];
	[[self proxyPortField] setObjectValue : 
		proxyPort_ 
			? (id)[NSNumber numberWithInt : proxyPort_]
			: (id)@""];
	
}

- (void) updateUIComponents
{
	/*SGFileRef		*fileRef_ = [[CMRFileManager defaultManager] dataRootDirectory];
	NSString		*displayName_;
	
	// •\Ž¦–¼
	displayName_ = [fileRef_ displayPath];
	[[self dataRootPathField] setStringValue : 
		displayName_ ? displayName_ : @""];*/
	
	[self updateListUIComponents];
	[self updateThreadUIComponents];
	[self updateProxyUIComponents];
	
}

/*
- (void) setupLogSettingsUIComponents
{
	[[self dataRootPathField] setEnabled : YES];
	[[self dataRootPathField] setEditable : NO];
	[[self dataRootPathField] setSelectable : YES];
}
*/
- (void) setupListUIComponents
{
	//[self preferencesRespondsTo : @selector(threadsListAutoscrollMask)
	//				  ofControl : [self autoscrollMaskCheckBox]];
	[self preferencesRespondsTo : @selector(ignoreTitleCharacters)
					  ofControl : [self ignoreCharsField]];
	[self preferencesRespondsTo : @selector(collectByNew)
					  ofControl : [self collectByNewMatrix]];
}
- (void) setupThreadUIComponents
{
	[self preferencesRespondsTo : @selector(threadViewerLinkType)
					  ofControl : [self resAnchorActionPopUp]];
	[self preferencesRespondsTo : @selector(mailAttachmentShown)
					  ofControl : [self mailAttachCheckBox]];
	[self preferencesRespondsTo : @selector(mailAddressShown)
					  ofControl : [self showsAllMatrix]];
	[self preferencesRespondsTo : @selector(showsAllMessagesWhenDownloaded)
					  ofControl : [self mailAttachCheckBox]];
	[self preferencesRespondsTo : @selector(openInBrowserType)
					  ofControl : [self openInBrowserPopUp]];
}


- (void) setupProxyUIComponents
{
	[self preferencesRespondsTo : @selector(usesProxy)
					  ofControl : [self usesProxyCheckBox]];
	[self preferencesRespondsTo : @selector(usesProxyOnlyWhenPOST)
					  ofControl : [self proxyWhenPOSTCheckBox]];
	[self preferencesRespondsTo : @selector(usesSystemConfigProxy)
					  ofControl : [self usesSystemConfigProxyCheckBox]];
	[self preferencesRespondsTo : @selector(proxyHost)
					  ofControl : [self proxyURLField]];
	[self preferencesRespondsTo : @selector(proxyPort)
					  ofControl : [self proxyPortField]];
}

- (void) setupUIComponents
{
	if (nil == _contentView)
		return;
	
	//[self setupLogSettingsUIComponents];
	[self setupListUIComponents];
	[self setupThreadUIComponents];
	[self setupProxyUIComponents];
	
	[self updateUIComponents];
}
@end
