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

- (void) updateHelperAppUI
{
	NSString	*title = [self helperAppName];
	id<NSMenuItem>	theItem = [[self helperAppBtn] itemAtIndex : 0];
	
	if (title != nil) {
		[theItem setTitle : title];
		[theItem setImage : [self helperAppIcon]];
	} else {
		[theItem setTitle : PPLocalizedString(@"NilHelper")];
	}
	[[self helperAppBtn] selectItem : nil];
	[[self helperAppBtn] synchronizeTitleAndSelectedItem];
}
	
- (void) didEndChooseAppSheet : (NSOpenPanel *) sheet
                   returnCode : (int          ) returnCode
                  contextInfo : (void        *) contextInfo
{
	if (returnCode == NSOKButton) {
		NSString	*appPath_;

		appPath_ =	[sheet filename];
		[[self preferences] setHelperAppPath : appPath_];
	}
	[self updateHelperAppUI];
}

- (NSString *) helperAppName
{
	return [[self preferences] helperAppDisplayName];
}

- (NSImage *) helperAppIcon
{
	NSImage	*icon32 = [[NSWorkspace sharedWorkspace] iconForFile : [[self preferences] helperAppPath]];
	[icon32 setSize : NSMakeSize(16, 16)];
	return icon32;
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

- (void)proxySheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[sheet close];
}

- (IBAction) openSheet : (id) sender
{
	[self updateProxyUIComponents];
	[NSApp beginSheet : [self proxySheet]
		modalForWindow : [self window]
		modalDelegate : self
		didEndSelector : @selector(proxySheetDidEnd:returnCode:contextInfo:) 
		contextInfo : NULL];
}
- (IBAction) closeSheet : (id) sender
{
	[self changeProxyURL : nil];	// 念のため
	[self changeProxyPort : nil]; // 念のため
	[NSApp endSheet : [self proxySheet]];
}


#pragma mark Accessors (IB outlet)
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
- (NSPopUpButton *) helperAppBtn
{
	return _helperAppBtn;
}

- (NSWindow *) proxySheet
{
	return _proxySheet;
}

- (NSButton *) openSheetBtn
{
	return _openSheetBtn;
}
- (NSButton *) closeSheetBtn
{
	return _closeSheetBtn;
}

#pragma mark setting up UIs
- (void) updateProxyUIComponents
{
	BOOL		usesProxy_;
	BOOL		syncSysConfing;
	NSString	*proxyHost_;
	CFIndex		proxyPort_;
	
	/*if (NO == [[self usesProxyCheckBox] isEnabled] &&
	   NO == [[self proxyWhenPOSTCheckBox] isEnabled] &&
	   NO == [[self proxyURLField] isEnabled] &&
	   NO == [[self proxyPortField] isEnabled] &&
	   NO == [[self usesSystemConfigProxyCheckBox] isEnabled])
	{ return; }*/
	
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
/*
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
*/
- (void) updateUIComponents
{
	//[self updateProxyUIComponents];

	[self updateHelperAppUI];
}

- (void) setupUIComponents
{
	if (nil == _contentView)
		return;
	
	//[self setupProxyUIComponents];
	[self updateUIComponents];
}

#pragma mark ShortCircuit Additions

- (int) openInBrowserType
{
	return [[self preferences] openInBrowserType];
}

- (void) setOpenInBrowserType : (int) aType
{
    [[self preferences] setOpenInBrowserType : aType];
}

#pragma mark InnocentStarter Additions
- (float) mouseDownTrackingTime
{
	return [[self preferences] mouseDownTrackingTime];
}
- (void) setMouseDownTrackingTime : (float) sliderValue
{
	[[self preferences] setMouseDownTrackingTime : sliderValue];
}

#pragma mark Vita Additions
- (BOOL) quietDeletion
{
	return (NO == [[self preferences] quietDeletion]);
}
- (void) setQuietDeletion : (BOOL) boxState
{
	[[self preferences] setQuietDeletion : (NO == boxState)];
}
- (BOOL) openLinkInBg
{
	return [[self preferences] openInBg];
}
- (void) setOpenLinkInBg : (BOOL) boxState
{
	[[self preferences] setOpenInBg : boxState];
}

- (int) previewOption
{
	return [[self preferences] previewLinkWithNoModifierKey] ? 0 : 1;
}

- (void) setPreviewOption : (int) selectedTag
{
	BOOL	tmp_ = (selectedTag == 0) ? YES : NO;
	[[self preferences] setPreviewLinkWithNoModifierKey : tmp_];
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

