//
//  CMRReplyDefaultsController.m
//  BathyScaphe
//
//  Modified by Tsutomu Sawada on 06/09/08.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "CMRReplyDefaultsController.h"
#import "PreferencePanes_Prefix.h"

static NSString *const kLabelKey	= @"Reply Label";
static NSString *const kToolTipKey	= @"Reply ToolTip";
static NSString *const kImageName	= @"ResToThread";
static NSString *const kHelpKey		= @"Help_Reply";

static NSString *const kReplyDefaultsControllerNibName = @"ReplySetting";

@implementation CMRReplyDefaultsController
- (NSString *) mainNibName
{
	return kReplyDefaultsControllerNibName;
}

- (void) dealloc
{
	[m_temporaryKoteHan release];
	m_temporaryKoteHan = nil;
	[m_addKoteHanSheet release];
	[super dealloc];
}

- (void) setupUIComponents
{
	[self addKoteHanSheet];
}

#pragma mark -
- (NSString *) temporaryKoteHan
{
	return m_temporaryKoteHan;
}
- (void) setTemporaryKoteHan: (NSString *) someText
{
	[someText retain];
	[m_temporaryKoteHan release];
	m_temporaryKoteHan = someText;
}

- (NSPanel *) addKoteHanSheet
{
	return m_addKoteHanSheet;
}

- (IBAction) addKoteHan : (id) sender
{
	[self setTemporaryKoteHan: nil];

	[NSApp beginSheet: [self addKoteHanSheet]
	   modalForWindow: [self window]
	    modalDelegate: self
	   didEndSelector: @selector(addKoteHanSheetDidEnd:returnCode:contextInfo:)
		  contextInfo: nil];
}

- (IBAction) closeKoteHanSheet: (id) sender
{
	[NSApp endSheet: [self addKoteHanSheet] returnCode: [sender tag]];
}

- (void) addKoteHanSheetDidEnd: (NSWindow *) sheet returnCode: (int) returnCode contextInfo: (void *) contextInfo
{
	if (returnCode == NSOKButton) {
		NSMutableArray	*hoge_ = [[[self preferences] defaultKoteHanList] mutableCopy];
		NSArray			*adds_ = [[self temporaryKoteHan] componentsSeparatedByString: @"\n"];
		[hoge_ addObjectsFromArray: adds_];
		[[self preferences] setDefaultKoteHanList: hoge_];
		[hoge_ release];
	}
	
	[sheet close];
}
@end

#pragma mark -
@implementation CMRReplyDefaultsController(Toolbar)
- (NSString *) identifier
{
	return PPReplyDefaultIdentifier;
}
- (NSString *) helpKeyword
{
	return PPLocalizedString(kHelpKey);
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

