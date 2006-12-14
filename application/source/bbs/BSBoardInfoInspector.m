//
//  BSBoardInfoInspector.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/10/08.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import "BSBoardInfoInspector.h"

#import <SGFoundation/SGFoundation.h>
#import <CocoMonar/CocoMonar.h>

#import "BoardManager.h"
#import "CMRThreadViewer.h"
#import "CMRBBSSignature.h"
#import "CMRBrowser.h"

#define BrdMgr	[BoardManager defaultManager]

static NSString *const BIINibFileNameKey		= @"BSBoardInfoInspector";
static NSString *const BIIFrameAutoSaveNameKey	= @"BathyScaphe:BoardInfoInspector Panel Autosave";
static NSString *const BIIHelpKeywordKey		= @"BoardInspector Help Keyword";

@implementation BSBoardInfoInspector
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedInstance);

+ (void) initialize
{
	if (self == [BSBoardInfoInspector class]) {
		NSArray	*keyArray = [NSArray arrayWithObject: @"currentTargetBoardName"];

		[self setKeys: keyArray triggerChangeNotificationsForDependentKey: @"noNamesArray"];
		[self setKeys: keyArray triggerChangeNotificationsForDependentKey: @"boardURLAsString"];
		[self setKeys: keyArray triggerChangeNotificationsForDependentKey: @"shouldEnableUI"];
		[self setKeys: keyArray triggerChangeNotificationsForDependentKey: @"defaultKotehan"];
		[self setKeys: keyArray triggerChangeNotificationsForDependentKey: @"defaultMail"];
		[self setKeys: keyArray triggerChangeNotificationsForDependentKey: @"shouldAlwaysBeLogin"];
		[self setKeys: keyArray triggerChangeNotificationsForDependentKey: @"shouldAllThreadsAAThread"];
		[self setKeys: keyArray triggerChangeNotificationsForDependentKey: @"icon"];
		[self setKeys: keyArray triggerChangeNotificationsForDependentKey: @"shouldEnableBeBtn"];
		[self setKeys: keyArray triggerChangeNotificationsForDependentKey: @"shouldEnableURLEditing"];
		[self setKeys: keyArray triggerChangeNotificationsForDependentKey: @"nanashiAllowed"];
	}
}

- (id) init
{
	if (self = [self initWithWindowNibName : BIINibFileNameKey]) {
		[[NSNotificationCenter defaultCenter]
			 addObserver : self
				selector : @selector(browserBoardChanged:)
					name : CMRBrowserDidChangeBoardNotification
				  object : nil];

		[[NSNotificationCenter defaultCenter]
			 addObserver : self
				selector : @selector(mainWindowChanged:)
					name : NSWindowDidBecomeMainNotification
				  object : nil];

		[[NSNotificationCenter defaultCenter]
			 addObserver : self
				selector : @selector(viewerThreadChanged:)
					name : CMRThreadViewerDidChangeThreadNotification
				  object : nil];
	}
	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver : self];
	[_currentTargetBoardName release];
	[super dealloc];
}

- (void) awakeFromNib
{
	NSWorkspace *ws_ = [NSWorkspace sharedWorkspace];

	[[self window] setFrameAutosaveName : BIIFrameAutoSaveNameKey];
	if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_3) {
		[[self addNoNameBtn] setBezelStyle: NSSmallSquareBezelStyle];
		[[self removeNoNameBtn] setBezelStyle: NSSmallSquareBezelStyle];
		[[self editNoNameBtn] setBezelStyle: NSSmallSquareBezelStyle];
	}
	
	[[self lockButton] setImage: [ws_ systemIconForType: kLockedIcon]];
	[[self lockButton] setAlternateImage: [ws_ systemIconForType: kUnlockedIcon]];
	
	[[self URLField] setAllowsEditingTextAttributes: NO];
	[[self URLField] setImportsGraphics: NO];
}

- (void) showInspectorForTargetBoard : (NSString *) boardName
{
	[self setCurrentTargetBoardName : boardName];
	[self showWindow : self];
}

#pragma mark Accessors
- (NSString *) currentTargetBoardName
{
	return _currentTargetBoardName;
}
- (void) setCurrentTargetBoardName : (NSString *) newTarget
{
	[newTarget retain];
	[_currentTargetBoardName release];
	_currentTargetBoardName = newTarget;
}

- (NSButton *) helpButton
{
	return m_helpButton;
}
- (NSButton *) addNoNameBtn
{
	return m_addNoNameBtn;
}
- (NSButton *) removeNoNameBtn
{
	return m_removeNoNameBtn;
}
- (NSButton *) editNoNameBtn
{
	return m_editNoNameBtn;
}
- (NSButton *) detectSettingTxtBtn
{
	return m_detectSettingTxtBtn;
}
- (NSButton *) lockButton
{
	return m_lockButton;
}
- (NSTextField *) URLField
{
	return m_URLField;
}
- (NSArrayController *) greenCube
{
	return m_greenCube;
}
- (NSProgressIndicator *) spin
{
	return m_spin;
}

#pragma mark IBActions
- (IBAction) showWindow : (id) sender
{
	// toggle-Action : すでにパネルが表示されているときは、パネルを閉じる
	if ([[self window] isVisible]) {
		[[self window] performClose : sender];
	} else {
		[super showWindow : sender];
	}
}

- (IBAction) addNoName : (id) sender;
{
	NSString	*newNanashi;
	newNanashi = [BrdMgr askUserAboutDefaultNoNameForBoard : [self currentTargetBoardName]
											   presetValue : nil];
	if (!newNanashi) return;
	[self willChangeValueForKey: @"noNamesArray"];
	[BrdMgr addNoName: newNanashi forBoard: [self currentTargetBoardName]];
	[self didChangeValueForKey: @"noNamesArray"];
}

- (IBAction) editNoName: (id) sender
{
	NSString	*newNanashi;
	id			tmp_ = [[[self greenCube] selectedObjects] objectAtIndex: 0];

	newNanashi = [BrdMgr askUserAboutDefaultNoNameForBoard : [self currentTargetBoardName]
											   presetValue : tmp_];
	if (!newNanashi) return;
	[self willChangeValueForKey: @"noNamesArray"];
	[BrdMgr exchangeNoName: tmp_ toNewValue: newNanashi forBoard: [self currentTargetBoardName]];
	[self didChangeValueForKey: @"noNamesArray"];
}

- (IBAction) startDetect: (id) sender
{
	if ([BrdMgr startDownloadSettingTxtForBoard: [self currentTargetBoardName]]) {
		[[NSNotificationCenter defaultCenter]
			 addObserver : self
				selector : @selector(boardManagerDidDetectSettingTxt:)
					name : BoardManagerDidFinishDetectingSettingTxtNotification
				  object : BrdMgr];
		[[self spin] startAnimation: nil];
		[[self detectSettingTxtBtn] setEnabled: NO];
	} else {
		NSBeep();
		NSLog(@"Sorry... non-2ch boards are not supported.");
	}
}

- (IBAction) toggleAllowEditingBoardURL: (id) sender
{
	int state_ = [sender state];
	
	if (state_ == NSOffState) { // unlock --> lock
		if (NO == [[self currentTargetBoardName] isEqualToString: BSbbynewsBoardName]) {
			[[self window] makeFirstResponder: m_namesTable];
		} else {
			[[self window] makeFirstResponder: [self window]];
		}
		[[self URLField] setEditable: NO];
		[[self URLField] setNeedsDisplay: YES];
	} else if (state_ == NSOnState) {
		[[self URLField] setEditable: YES];
		[[self URLField] selectText: nil];
	}
}

- (IBAction) openHelpForMe : (id) sender
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor : NSLocalizedString(BIIHelpKeywordKey, @"Board options")
											   inBook : [NSBundle applicationHelpBookName]];
}

#pragma mark Accesors For Binding
- (NSMutableArray *) noNamesArray
{
	return [[[[BrdMgr defaultNoNameSetForBoard: [self currentTargetBoardName]] allObjects] mutableCopy] autorelease];
}

- (void) setNoNamesArray: (NSMutableArray *) anArray
{
	[BrdMgr setDefaultNoNameSet: [NSSet setWithArray: anArray] forBoard: [self currentTargetBoardName]];
}

- (NSString *) boardURLAsString
{
	return [[BrdMgr URLForBoardName : [self currentTargetBoardName]] stringValue];
}

- (void) setBoardURLAsString: (NSString *) stringValue
{
	[BrdMgr editBoardOfName: [self currentTargetBoardName] newURLString: stringValue];
}

// URL フィールドが空欄にされるのを防止
- (BOOL) control: (NSControl *) control textShouldEndEditing: (NSText *) fieldEditor
{
	if ([[fieldEditor string] isEqualToString: @""]) {
		[fieldEditor setString: [self boardURLAsString]];
		return YES;
	}
	return YES;
}

- (BOOL) shouldEnableUI
{
	NSString *tmp_ = [self currentTargetBoardName];
	if ([tmp_ isEqualToString : CMXFavoritesDirectoryName] || [tmp_ isEqualToString: BSbbynewsBoardName]) return NO;
	
	return YES;
}

- (BOOL) shouldEnableBeBtn
{
	return (BSBeLoginDecidedByUser == [BrdMgr typeOfBeLoginPolicyForBoard : [self currentTargetBoardName]]);
}

- (BOOL) shouldEnableURLEditing
{
	return (![[self currentTargetBoardName] isEqualToString : CMXFavoritesDirectoryName]);
}

- (NSString *) defaultKotehan
{
	return [BrdMgr defaultKotehanForBoard : [self currentTargetBoardName]];
}

- (void) setDefaultKotehan : (NSString *) fieldValue
{
	[BrdMgr setDefaultKotehan : ((fieldValue != nil) ? fieldValue : @"") forBoard : [self currentTargetBoardName]];
}

- (NSString *) defaultMail
{
	return [BrdMgr defaultMailForBoard : [self currentTargetBoardName]];
}

- (void) setDefaultMail : (NSString *) fieldValue
{
	[BrdMgr setDefaultMail : ((fieldValue != nil) ? fieldValue : @"") forBoard : [self currentTargetBoardName]];
}

- (BOOL) shouldAlwaysBeLogin
{
	return [BrdMgr alwaysBeLoginAtBoard : [self currentTargetBoardName]];
}

- (void) setShouldAlwaysBeLogin : (BOOL) checkboxState
{
	[BrdMgr setAlwaysBeLogin : checkboxState atBoard : [self currentTargetBoardName]];
}

- (BOOL) shouldAllThreadsAAThread
{
	return [BrdMgr allThreadsShouldAAThreadAtBoard : [self currentTargetBoardName]];
}

- (void) setShouldAllThreadsAAThread : (BOOL) checkboxState
{
	[BrdMgr setAllThreadsShouldAAThread : checkboxState atBoard : [self currentTargetBoardName]];
}

- (NSImage *) icon
{
	return [BrdMgr iconForBoard : [self currentTargetBoardName]];
}

- (int) nanashiAllowed
{
	return [BrdMgr allowsNanashiAtBoard: [self currentTargetBoardName]] ? 0 : 1;
}

#pragma mark Notification
- (void) mainWindowChanged : (NSNotification *) theNotification
{
	if (![[self window] isVisible]) return;

	id winController_ = [[theNotification object] windowController];
/*
	if (([winController_ class] == [CMRThreadViewer class]) || ([winController_ class] == [CMRBrowser class])) {
		NSString *tmp_;
		tmp_ = [(CMRThreadViewer *)winController_ boardName];
		if(tmp_ == nil)
			tmp_ = [(CMRBBSSignature *)[(CMRThreadViewer *)winController_ boardIdentifier] name];
	
		if (nil == tmp_)
			return;
		[self setCurrentTargetBoardName : tmp_];
		[[self window] update];
	}*/
	if ([winController_ respondsToSelector: @selector(boardIdentifier)]) {
		NSString *tmp_ = [winController_ boardIdentifier];
				
		if (!tmp_) return;
		
		[self setCurrentTargetBoardName: [(CMRBBSSignature *)tmp_ name]];
		[[self window] update];
	}
}

- (void) browserBoardChanged : (NSNotification *) theNotification
{
	if (![[self window] isVisible]) return;
	id winController_ = [theNotification object];

	if (NO == [(NSWindow *)[winController_ window] isMainWindow]) return;

//	if ([winController_ class] == [CMRBrowser class]) { // 発信者は常に CMRBrowser class
	if ([winController_ respondsToSelector: @selector(boardIdentifier)]) {
		NSString *tmp_;
		tmp_ = [(CMRBBSSignature *)[winController_ boardIdentifier] name];
	
		if (nil == tmp_)
			return;
		[self setCurrentTargetBoardName : tmp_];
		[[self window] update];
	}
}

- (void) viewerThreadChanged : (NSNotification *) theNotification
{
	if (![[self window] isVisible]) return;
	id winController_ = [theNotification object];

//	if ([winController_ class] == [CMRThreadViewer class]) {
	if ([winController_ isMemberOfClass: [CMRThreadViewer class]]) {
		NSString *tmp_;
		tmp_ = [(CMRThreadViewer *)winController_ boardName];
		if(tmp_ == nil)
			tmp_ = [(CMRBBSSignature *)[(CMRThreadViewer *)winController_ boardIdentifier] name];
	
		if (nil == tmp_)
			return;
		if ([[self currentTargetBoardName] isEqualToString : tmp_])
			return;

		[self setCurrentTargetBoardName : tmp_];
		[[self window] update];
	}
}

- (void) boardManagerDidDetectSettingTxt: (NSNotification *) aNotification
{
	[[self spin] stopAnimation: nil];
	[[self detectSettingTxtBtn] setEnabled: YES];

	if ([[self window] isVisible]) {
		[self setCurrentTargetBoardName : _currentTargetBoardName];
		[[self window] update];
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver: self name: BoardManagerDidFinishDetectingSettingTxtNotification object: BrdMgr];
}
@end
