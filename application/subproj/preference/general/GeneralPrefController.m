/**
  * $Id: GeneralPrefController.m,v 1.1 2005/05/11 17:51:10 tsawada2 Exp $
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
- (IBAction) changeDrawerEdgeMask : (id) sender
{
	int		mask_;
	mask_ = [[[self drawerEdgeMaskMatrix] selectedCell] tag];
	
	[[self preferences] setBoardListDrawerEdge : (NSRectEdge)mask_];
}

- (IBAction) changeIgnoreCharacters : (id) sender
{
	UTILAssertRespondsTo(sender, @selector(stringValue));
	[[self preferences] setIgnoreTitleCharacters : [sender stringValue]];
}
- (IBAction) changeCollectByNew : (id) sender
{
	[[self preferences] setCollectByNew : (0 == [[[self collectByNewMatrix] selectedCell] tag])];
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
	[[self preferences] setMailAddressShown : (0 == [[[self isMailShownMatrix] selectedCell] tag])];
}
- (IBAction) changeShowsAll : (id) sender
{
	[[self preferences] setShowsAllMessagesWhenDownloaded : (0 == [[[self showsAllMatrix] selectedCell] tag])];
}
- (IBAction) changeOpenInBrowserType : (id) sender
{
    NSPopUpButton *popUp = [self openInBrowserPopUp];
    NSMenuItem *menuItem = (NSMenuItem *)[popUp itemAtIndex : [popUp indexOfSelectedItem]];
    
    [[self preferences] setOpenInBrowserType : [menuItem tag]];
}
// Proxy
- (IBAction) changeProxyURL : (id) sender
{
	id		location_;
	
	location_ = [[self proxyURLField] stringValue];
	[[self preferences] setProxyHost : location_];
}
- (IBAction) changeProxyPort : (id) sender
{
	int		v;
	
	v = [[self proxyPortField] intValue];
	if(v <= 0){
		[[self proxyPortField] setStringValue : @""];
		v = 0;
	}
	[[self preferences] setProxyPort : v];
}
- (IBAction) enableProxy : (id) sender
{
	UTILAssertRespondsTo(sender, @selector(state));
	[[self preferences] setUsesProxy : 
		([sender state] == NSOnState)];
	[self updateProxyUIComponents];
}
- (IBAction) enableProxyWhenPOST : (id) sender
{
	UTILAssertRespondsTo(sender, @selector(state));
	[[self preferences] setUsesProxyOnlyWhenPOST : 
		([sender state] == NSOnState)];
	[self updateProxyUIComponents];
}
- (IBAction) syncSystemConfigProxy : (id) sender
{
	UTILAssertRespondsTo(sender, @selector(state));
	[[self preferences] setUsesSystemConfigProxy : 
		([sender state] == NSOnState)];
	[self updateProxyUIComponents];
}
@end



@implementation GeneralPrefController(Toolbar)
- (NSString *) identifier
{
	return PPGeneralPreferencesIdentifier;
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
