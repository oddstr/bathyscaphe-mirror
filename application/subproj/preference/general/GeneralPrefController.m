/**
  * $Id: GeneralPrefController.m,v 1.5 2005/07/29 21:18:28 tsawada2 Exp $
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
- (IBAction) changeOpenInBrowserType : (id) sender
{
    NSPopUpButton *popUp = [self openInBrowserPopUp];
    NSMenuItem *menuItem = (NSMenuItem *)[popUp itemAtIndex : [popUp indexOfSelectedItem]];
    
    [[self preferences] setOpenInBrowserType : [menuItem tag]];
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
