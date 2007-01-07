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

- (IBAction) chooseApplication : (id) sender
{
	NSArray *fileTypes = [NSArray arrayWithObjects: @"app", nil];
	NSArray	*tmp = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSLocalDomainMask, YES);
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];

	[openPanel setAllowsMultipleSelection: NO];
	
	[openPanel beginSheetForDirectory: [tmp objectAtIndex: 0]
								 file: nil
								types: fileTypes
					   modalForWindow: [self window]
						modalDelegate: self
					   didEndSelector: @selector(didEndChooseAppSheet:returnCode:contextInfo:)
						  contextInfo: nil];
}

/*- (IBAction) startCheckingForUpdate: (id) sender
{
	NSBeep();
	NSLog(@"Not implemented yet");
}*/

#pragma mark Accessors
- (NSPopUpButton *) helperAppBtn
{
	return m_helperAppBtn;
}

/*- (NSButton *) checkNowBtn
{
	return m_checkNowBtn;
}*/

- (int) previewOption
{
	return [[self preferences] previewLinkWithNoModifierKey] ? 0 : 1;
}

- (void) setPreviewOption : (int) selectedTag
{
	BOOL	tmp_ = (selectedTag == 0) ? YES : NO;
	[[self preferences] setPreviewLinkWithNoModifierKey : tmp_];
}

#pragma mark Setting up UIs
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

- (void) updateUIComponents
{
	[self updateHelperAppUI];
}

- (void) setupUIComponents
{
	if (nil == _contentView)
		return;
	
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

