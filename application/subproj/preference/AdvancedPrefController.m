//
//  AdvancedPrefController.m
//  BachyScaphe
//
//  Created by Tsutomu Sawada on 05/05/22.
//  Copyright 2005 tsawada2. All rights reserved.
//

#import <CocoMonar/CocoMonar.h>
#import "AdvancedPrefController.h"
#import "PreferencePanes_Prefix.h"
#import "BSIconTextFieldCell.h"

#define kLabelKey		@"Advanced Label"
#define kToolTipKey		@"Advanced ToolTip"
#define kImageName		@"AdvancedPreferences"


@implementation AdvancedPrefController
- (NSString *) mainNibName
{
	return @"AdvancedPane";
}
#pragma mark -
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
- (IBAction) changeQuietDeletion : (id) sender
{
	[[self preferences] setQuietDeletion : (NSOffState == [[self quietDeletionCheckBox] state])];
}
- (IBAction) changeOpenLinkInBg : (id) sender
{
	[[self preferences] setOpenInBg : (NSOnState == [[self openLinkInBgCheckBox] state])];
}
- (void) didEndChooseAppSheet : (NSOpenPanel *) sheet
                   returnCode : (int          ) returnCode
                  contextInfo : (void        *) contextInfo
{
	NSImage		*appIcon_;
	NSString	*appPath_;
	NSString	*displayName_;
	
	if (NO == (returnCode == NSOKButton)) return;
	
	appPath_ =	[sheet filename];
	[[self preferences] setHelperAppPath : appPath_];

	appIcon_ = [[NSWorkspace sharedWorkspace] iconForFile : appPath_];
	[[[self appNameField] cell] setImage : appIcon_];
	displayName_ = [[self preferences] helperAppDisplayName];
	[[[self appNameField] cell] setObjectValue : displayName_];
	[[self appNameField] setNeedsDisplay : YES];
	
}

- (IBAction) chooseApplication : (id) sender
{
	NSArray *fileTypes = [NSArray arrayWithObjects:@"app", nil];
	NSArray	*tmp = NSSearchPathForDirectoriesInDomains (NSApplicationDirectory, NSLocalDomainMask, YES);
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];

	[openPanel setAllowsMultipleSelection:NO];
	
	[openPanel
		beginSheetForDirectory : [tmp objectAtIndex : 0]
				  file : nil
			     types : fileTypes
		modalForWindow : [self window]
		 modalDelegate : self
		didEndSelector : @selector(didEndChooseAppSheet:returnCode:contextInfo:)
		   contextInfo : nil];
}

#pragma mark -
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
- (NSButton *) quietDeletionCheckBox
{
	return _quietDeletionCheckBox;
}
- (NSButton *) openLinkInBgCheckBox
{
	return _openLinkInBgCheckBox;
}
- (id) appNameField
{
	return _appNameField;
}
#pragma mark -
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

- (void) updateUIComponents
{
	NSString	*path_;
	[self updateProxyUIComponents];
	[[self quietDeletionCheckBox] setState : 
			([[self preferences] quietDeletion] ? NSOffState : NSOnState)];
	[[self openLinkInBgCheckBox] setState : 
			([[self preferences] openInBg] ? NSOnState : NSOffState)];

	path_ = [[self preferences] helperAppPath];
	if (path_) {
		NSImage *img_ = [[NSWorkspace sharedWorkspace] iconForFile : path_];
		[[[self appNameField] cell] setImage : img_];
		[[[self appNameField] cell] setObjectValue : [[self preferences] helperAppDisplayName]];
	}
}

- (void) setupUIComponents
{
	BSIconTextFieldCell	*cell_;
	if (nil == _contentView)
		return;
	
	cell_ = [[BSIconTextFieldCell alloc] init];
    [[self appNameField] setCell : cell_];
    [cell_ release];
	
	[self setupProxyUIComponents];
	
	[self updateUIComponents];
}

@end

@implementation AdvancedPrefController(Toolbar)
- (NSString *) identifier
{
	return PPAdvancedPreferencesIdentifier;
}
- (NSString *) helpKeyword
{
	return PPLocalizedString(@"Help_Advanced");
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

