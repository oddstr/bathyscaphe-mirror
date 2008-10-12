//
//  CMRReplyDefaultsController.m
//  BathyScaphe
//
//  Modified by Tsutomu Sawada on 06/09/08.
//  Copyright 2006-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRReplyDefaultsController.h"
#import "PreferencePanes_Prefix.h"

static NSString *const kLabelKey	= @"Reply Label";
static NSString *const kToolTipKey	= @"Reply ToolTip";
static NSString *const kImageName	= @"ResToThread";
static NSString *const kHelpKey		= @"Help_Reply";

static NSString *const kReplyDefaultsControllerNibName = @"ReplySetting";

@implementation CMRReplyDefaultsController
- (NSString *)mainNibName
{
	return kReplyDefaultsControllerNibName;
}

- (void)dealloc
{
	[m_temporaryKoteHan release];
	m_temporaryKoteHan = nil;
	[super dealloc];
}

- (void)setupUIComponents
{
	[self addKoteHanSheet];
}

- (void)willUnselect
{
	[super willUnselect];
	[[[self preferences] RTTManager] writeToFileNow];
}

#pragma mark Accessors
- (NSString *)temporaryKoteHan
{
	return m_temporaryKoteHan;
}

- (void)setTemporaryKoteHan:(NSString *)someText
{
	[someText retain];
	[m_temporaryKoteHan release];
	m_temporaryKoteHan = someText;
}

- (NSPanel *)addKoteHanSheet
{
	return m_addKoteHanSheet;
}

- (NSTableView *)koteHanListTable
{
	return m_koteHanListTable;
}

- (IBAction)addKoteHan:(id)sender
{
	[self setTemporaryKoteHan:nil];

	[NSApp beginSheet:[self addKoteHanSheet]
	   modalForWindow:[self window]
	    modalDelegate:self
	   didEndSelector:@selector(addKoteHanSheetDidEnd:returnCode:contextInfo:)
		  contextInfo:nil];
}

- (IBAction)closeKoteHanSheet:(id)sender
{
	[NSApp endSheet:[self addKoteHanSheet] returnCode:[sender tag]];
}

- (void)addKoteHanSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton) {
		NSMutableArray	*newKoteHanList = [[[self preferences] defaultKoteHanList] mutableCopy];
		if (!newKoteHanList) {
			newKoteHanList = [[NSMutableArray alloc] init];
		}

		NSArray			*adds_ = [[self temporaryKoteHan] componentsSeparatedByString:@"\n"];
		[newKoteHanList addObjectsFromArray:adds_];
		[[self preferences] setDefaultKoteHanList:newKoteHanList];
		[newKoteHanList release];

		unsigned int index_ = [[[self preferences] defaultKoteHanList] count] -1;
		[[self koteHanListTable] selectRowIndexes:[NSIndexSet indexSetWithIndex:index_] byExtendingSelection:NO];
		[[self koteHanListTable] scrollRowToVisible:index_];
	}

	[sheet close];
}

#pragma mark NSTextView Delegate
- (BOOL)textView:(NSTextView *)aTextView doCommandBySelector:(SEL)aSelector
{
	if (aSelector == @selector(insertTab:)) { // tab
		[[self window] makeFirstResponder:[aTextView nextValidKeyView]];
		return YES;
	}
	
	if (aSelector == @selector(insertBacktab:)) { // shift-tab
		[[self window] makeFirstResponder:[aTextView previousValidKeyView]];
		return YES;
	}
	
	return NO;
}
@end


@implementation CMRReplyDefaultsController(Toolbar)
- (NSString *)identifier
{
	return PPReplyDefaultIdentifier;
}

- (NSString *)helpKeyword
{
	return PPLocalizedString(kHelpKey);
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
