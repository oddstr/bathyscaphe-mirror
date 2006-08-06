//
//  SyncPaneController.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/28.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <CocoMonar/CocoMonar.h>
#import "SyncPaneController.h"
#import "PreferencePanes_Prefix.h"

#define kLabelKey		@"Sync Label"
#define kToolTipKey		@"Sync ToolTip"
#define kImageName		@"Sync"

@implementation SyncPaneController
- (NSString *) mainNibName
{
	return @"SyncPane";
}

- (void) updateUIComponents
{
	NSDate *date_ = [[self preferences] lastSyncDate];
	[[self statusTitle] setStringValue: PPLocalizedString(@"last sync")];
	[[self statusField] setStringValue: date_ ? [date_ descriptionWithCalendarFormat: @"%y/%m/%d %H:%M:%S" timeZone: nil locale: nil]
											  : PPLocalizedString(@"no history")];
	[[self statusIconView] setHidden: YES];
	[[self comboBox] setStringValue: [[[self preferences] BBSMenuURL] absoluteString]];
}

- (void) setupUIComponents
{
	if (nil == _contentView)
		return;

	[self updateUIComponents];
}

- (NSImage *) imageResourceWithName : (NSString *) name
{
	NSBundle *bundle_;
	NSString *filepath_;
	bundle_ = [NSBundle bundleForClass : [self class]];
	filepath_ = [bundle_ pathForImageResource : name];
	
	if(nil == filepath_) return nil;
	
	return [[[NSImage alloc] initWithContentsOfFile : filepath_] autorelease];
}

- (NSButton *) startBtn
{
	return m_startBtn;
}
- (NSTextField *) statusField
{
	return m_statusField;
}
- (NSProgressIndicator *) statusBar
{
	return m_statusBar;
}

- (NSTextField *) statusTitle
{
	return m_statusTitle;
}

- (NSComboBox *) comboBox
{
	return m_comboBox;
}

- (NSImageView *) statusIconView
{
	return m_statusIconView;
}

- (IBAction) startSync: (id) sender
{
	[[self statusTitle] setStringValue: PPLocalizedString(@"sync status")];
	[[self statusField] setStringValue: PPLocalizedString(@"downloading")];

	[[self statusBar] startAnimation: self];
	[[self startBtn] setEnabled: NO];
	[[self preferences] letBoardWarriorStartSyncing: self];
}

- (IBAction) comboBoxDidEndEditing: (id) sender
{
	NSString *typedText = [sender stringValue];
	if (!typedText || [typedText isEqualToString: @""]) {
		[sender setStringValue: [[[self preferences] BBSMenuURL] absoluteString]];
		return;
	}
	
	[[self preferences] setBBSMenuURL: [NSURL URLWithString: typedText]]; 
}

- (void) taskDidFail: (NSNotification *) aNotification
{
	NSBeep();
	
	[[self statusBar] stopAnimation: self];
	
	NSLog(@"Sync board list error: %@", [[aNotification userInfo] objectForKey: @"ErrorDescription"]);
	[[self statusField] setStringValue: PPLocalizedString(@"error abort")];
	[[self statusIconView] setImage: [self imageResourceWithName: @"syncFail"]];
	[[self statusIconView] setHidden: NO];
	[[self startBtn] setEnabled: YES];
	[[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void) downloadBBSMenuDidFinish: (NSNotification *) aNotification
{
	;
}

- (void) createDefaultListWillStart: (NSNotification *) aNotification
{
	[[self statusField] setStringValue: PPLocalizedString(@"parsing")];
	[[self statusField] display];
}

- (void) syncUserListWillStart: (NSNotification *) aNotification
{
	[[self statusField] setStringValue: PPLocalizedString(@"merging")];
	[[self statusField] display];
}

- (void) allSyncTaskDidFinish: (NSNotification *) aNotification
{
	[[self statusBar] stopAnimation: self];

	[[self startBtn] setEnabled: YES];
	[[NSNotificationCenter defaultCenter] removeObserver: self];

	NSString	*soundName_ = [[self preferences] HEADCheckNewArrivedSound];
	NSSound		*finishedSound_ = nil;

	if (![soundName_ isEqualToString : @""])
		finishedSound_ = [NSSound soundNamed : soundName_];

	if(finishedSound_)
		[finishedSound_ play];

	[self updateUIComponents];

	[[self statusIconView] setImage: [self imageResourceWithName: @"syncFinish"]];
	[[self statusIconView] setHidden: NO];
}
@end

@implementation SyncPaneController(Toolbar)
- (NSString *) identifier
{
	return PPSyncPreferencesIdentifier;
}
- (NSString *) helpKeyword
{
	return PPLocalizedString(@"Help_Sync");
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
