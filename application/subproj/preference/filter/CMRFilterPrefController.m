//
//  CMRFilterPrefController.m
//  BachyScaphe
//
//  Updated by Tsutomu Sawada on 07/08/11.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRFilterPrefController.h"
#import "PreferencePanes_Prefix.h"

static NSString *const kLabelKey = @"Filter Label";
static NSString *const kToolTipKey = @"Filter ToolTip";
static NSString *const kImageName = @"FilterPreferences";


@implementation CMRFilterPrefController
- (NSString *)mainNibName
{
	return @"FilterPreferences";
}

- (NSWindow *)detailSheet
{
	return m_detailSheet;
}

#pragma mark IBActions
- (IBAction)resetSpamDB:(id)sender
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];

	[alert setAlertStyle:NSWarningAlertStyle];
	[alert setMessageText:PPLocalizedString(@"ResetSpamFilterDBTitle")];
	[alert setInformativeText:PPLocalizedString(@"ResetSpamFilterDBMessage")];
	[alert addButtonWithTitle:PPLocalizedString(@"OK")];
	[alert addButtonWithTitle:PPLocalizedString(@"Cencel")];

	if ([alert runModal] == NSAlertFirstButtonReturn) {
		[[self preferences] resetSpamFilter];
	}
}

- (void)detailSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[sheet close];
}

- (IBAction)openDetailSheet:(id)sender
{
	[NSApp beginSheet:[self detailSheet]
	   modalForWindow:[self window]
		modalDelegate:self
	   didEndSelector:@selector(detailSheetDidEnd:returnCode:contextInfo:) 
		  contextInfo:NULL];
}

- (IBAction)closeDetailSheet:(id)sender
{
	[NSApp endSheet:[self detailSheet]];
}
@end



@implementation CMRFilterPrefController(Toolbar)
- (NSString *)identifier
{
	return PPFilterPreferencesIdentifier;
}
- (NSString *)helpKeyword
{
	return PPLocalizedString(@"Help_Filter");
}
- (NSString *)label
{
	return PPLocalizedString(kLabelKey);
}
- (NSString *)paletteLabel
{
	return PPLocalizedString(kLabelKey);
}
- (NSString *)toolTip
{
	return PPLocalizedString(kToolTipKey);
}
- (NSString *)imageName
{
	return kImageName;
}
@end
