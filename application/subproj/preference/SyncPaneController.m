//
//  SyncPaneController.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/28.
//  Copyright 2006-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <CocoMonar/CocoMonar.h>
#import "SyncPaneController.h"
#import "PreferencePanes_Prefix.h"
#import "BoardWarrior.h"

#define kLabelKey		@"Sync Label"
#define kToolTipKey		@"Sync ToolTip"
#define kImageName		@"Sync"

@implementation SyncPaneController
- (NSString *)mainNibName
{
	return @"SyncPane";
}

- (void)updateUIComponents
{
	[[self statusIconView] setHidden:YES];
	[[self comboBox] setStringValue:[[[self preferences] BBSMenuURL] absoluteString]];
}

- (void)setupUIComponents
{
	if (!_contentView) return;
	[self updateUIComponents];
}

- (NSImage *)imageResourceWithName:(NSString *)name
{
	NSBundle *bundle_;
	NSString *filepath_;
	bundle_ = [NSBundle bundleForClass:[self class]];
	filepath_ = [bundle_ pathForImageResource:name];
	
	if (!filepath_) return nil;
	
	return [[[NSImage alloc] initWithContentsOfFile:filepath_] autorelease];
}

- (NSComboBox *)comboBox
{
	return m_comboBox;
}

- (NSImageView *)statusIconView
{
	return m_statusIconView;
}

- (IBAction)startSync:(id)sender
{
	BoardWarrior *warrior = [[self preferences] sharedBoardWarrior];
	[[self window] endEditingFor:nil];
	[warrior setDelegate:self];
	[warrior syncBoardLists];
}

- (IBAction)comboBoxDidEndEditing:(id)sender
{
	NSString *typedText = [sender stringValue];
	NSString *currentURLStr = [[[self preferences] BBSMenuURL] absoluteString];

	if (!typedText || [typedText isEqualToString: @""]) {
		[sender setStringValue:currentURLStr];
		return;
	}
	
	if ([typedText isEqualToString:currentURLStr]) return;
	
	[[self preferences] setBBSMenuURL:[NSURL URLWithString:typedText]]; 
}

- (IBAction)openLogFile:(id)sender
{
	NSString *filePath = [[[self preferences] sharedBoardWarrior] logFilePath];
	if (!filePath) return;

	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	NSString *appPath = [ws absolutePathForAppBundleWithIdentifier:@"com.apple.Console"];
	if (!appPath) return;

	[ws openFile:filePath withApplication:appPath];
}

- (void)warrior:(BoardWarrior *)warrior didFailSync:(NSError *)error
{
	[[self statusIconView] setImage:[self imageResourceWithName:@"syncFail"]];
	[[self statusIconView] setHidden:NO];
	[warrior setDelegate:nil];
}

- (void)warriorDidFinishSyncing:(BoardWarrior *)warrior
{
	[warrior setDelegate:nil];
	[[self statusIconView] setImage:[self imageResourceWithName:@"syncFinish"]];
	[[self statusIconView] setHidden:NO];
}
@end


@implementation SyncPaneController(Toolbar)
- (NSString *)identifier
{
	return PPSyncPreferencesIdentifier;
}

- (NSString *)helpKeyword
{
	return PPLocalizedString(@"Help_Sync");
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
