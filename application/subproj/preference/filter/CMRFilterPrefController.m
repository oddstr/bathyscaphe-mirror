/**
  * $Id: CMRFilterPrefController.m,v 1.1.1.1 2005/05/11 17:51:10 tsawada2 Exp $
  * 
  * CMRFilterPrefController.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRFilterPrefController_p.h"


#define kLabelKey		@"Filter Label"
#define kToolTipKey		@"Filter ToolTip"
#define kImageName		@"FilterPreferences"



@implementation CMRFilterPrefController
- (NSString *) mainNibName
{
	return @"FilterPreferences";
}
- (void) dealloc
{
	UTILMethodLog;
	
	[_detailSheet release];
	[super dealloc];
}
- (IBAction) changeSpamFilterEnabled : (id) sender
{
	UTILAssertRespondsTo(sender, @selector(state));
	[[self preferences] setSpamFilterEnabled : 
		(NSOnState == [sender state])];
}
- (IBAction) changeUsesSpamMessageCorpus : (id) sender
{
	UTILAssertRespondsTo(sender, @selector(state));
	[[self preferences] setUsesSpamMessageCorpus : 
		(NSOnState == [sender state])];
}
- (IBAction) changeSpamFilterBehavior : (id) sender
{
	UTILAssertRespondsTo(sender, @selector(selectedCell));
	[[self preferences] setSpamFilterBehavior : [[sender selectedCell] tag]];
}
- (IBAction) resetSpamDB : (id) sender
{
	int		result;
	
	result = NSRunAlertPanel(
				PPLocalizedString(@"ResetSpamFilterDBTitle"),	// title
				PPLocalizedString(@"ResetSpamFilterDBMessage"),	// msg
				PPLocalizedString(@"OK"),		// defaultButton
				PPLocalizedString(@"Cencel"),	// alternateButton
				nil								// otherButton
			);
	
	if (result != NSOKButton) 
		return;
	
	[[self preferences] resetSpamFilter];
}

- (void)detailSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[sheet close];
	[[self preferences] setUpSpamMessageCorpusWithString : [[self spamMessageCorpusTextView] string]];
}
- (IBAction) openDetailSheet : (id) sender
{
	[[self spamMessageCorpusTextView] setString :
		[[self preferences] spamMessageCorpusStringRepresentation]];
	
	[NSApp beginSheet : [self detailSheet]
		modalForWindow : [self window]
		modalDelegate : self
		didEndSelector : @selector(detailSheetDidEnd:returnCode:contextInfo:) 
		contextInfo : NULL];
}
- (IBAction) closeDetailSheet : (id) sender
{
	[NSApp endSheet : [self detailSheet]];
}
@end




@implementation CMRFilterPrefController(Toolbar)
- (NSString *) identifier
{
	return PPFilterPreferencesIdentifier;
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
