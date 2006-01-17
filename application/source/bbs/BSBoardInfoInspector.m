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
static NSString *const BIITitlebarFormatKey		= @"BoardInspector TitleBar";
static NSString *const BIIHelpKeywordKey		= @"BoardInspector Help Keyword";

@implementation BSBoardInfoInspector
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedInstance);

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

		/*[[NSNotificationCenter defaultCenter]
			 addObserver : self
				selector : @selector(windowWillCloseNow:)
					name : NSWindowWillCloseNotification
				  object : nil];*/
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
	//[(NSPanel*)[self window] setBecomesKeyOnlyIfNeeded : YES];
	[(NSPanel*)[self window] setFrameAutosaveName : BIIFrameAutoSaveNameKey];
}

#pragma mark Accessors
- (NSString *) currentTargetBoardName
{
	return _currentTargetBoardName;
}
- (void) setCurrentTargetBoardName : (NSString *) newTarget
{
	// 参考：<http://www.cocoadev.com/index.pl?KeyValueObserving>
	[self willChangeValueForKey:@"defaultNanashi"];
	[self willChangeValueForKey:@"boardURLAsString"];
	[self willChangeValueForKey:@"shouldEnableUI"];
	[self willChangeValueForKey:@"titleBarString"];
	[self willChangeValueForKey:@"defaultKotehan"];
	[self willChangeValueForKey:@"defaultMail"];
	[self willChangeValueForKey:@"shouldAlwaysBeLogin"];
	[self willChangeValueForKey:@"shouldAllThreadsAAThread"];
	[self willChangeValueForKey:@"icon"];
	[self willChangeValueForKey:@"shouldEnableBeBtn"];

	[newTarget retain];
	[_currentTargetBoardName release];
	_currentTargetBoardName = newTarget;

	[self didChangeValueForKey:@"defaultNanashi"];
	[self didChangeValueForKey:@"boardURLAsString"];
	[self didChangeValueForKey:@"shouldEnableUI"];
	[self didChangeValueForKey:@"titleBarString"];
	[self didChangeValueForKey:@"defaultKotehan"];
	[self didChangeValueForKey:@"defaultMail"];
	[self didChangeValueForKey:@"shouldAlwaysBeLogin"];
	[self didChangeValueForKey:@"shouldAllThreadsAAThread"];
	[self didChangeValueForKey:@"icon"];
	[self didChangeValueForKey:@"shouldEnableBeBtn"];
}

- (NSButton *) helpButton
{
	return m_helpButton;
}
- (NSButton *) changeKotehanBtn
{
	return m_changeKotehanBtn;
}
- (NSTextField *) nanashiField;
{
	return m_nanashiField;
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

- (IBAction) changeDefaultNanashi : (id) sender
{
	NSString	*newNanashi;
	newNanashi = [BrdMgr askUserAboutDefaultNoNameForBoard : [self currentTargetBoardName]
											   presetValue : [self defaultNanashi]];
	if(newNanashi != nil) [[self nanashiField] setStringValue : newNanashi];
}
- (IBAction) openHelpForMe : (id) sender
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor : NSLocalizedString(BIIHelpKeywordKey, @"Board options")
											   inBook : [NSBundle applicationHelpBookName]];
}

#pragma mark Accesors for Binding
- (NSString *) defaultNanashi
{
	return [BrdMgr defaultNoNameForBoard : [self currentTargetBoardName]];
}

- (NSString *) boardURLAsString
{
	return [[BrdMgr URLForBoardName : [self currentTargetBoardName]] stringValue];
}

- (BOOL) shouldEnableUI
{
	return (![[self currentTargetBoardName] isEqualToString : CMXFavoritesDirectoryName]);
}

- (NSString *) titleBarString
{
	return [NSString stringWithFormat : NSLocalizedString(BIITitlebarFormatKey, @"%@ options"), [self currentTargetBoardName]];
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

- (BOOL) shouldEnableBeBtn
{
	return (BSBeLoginDecidedByUser == [BrdMgr typeOfBeLoginPolicyForBoard : [self currentTargetBoardName]]);
}

#pragma mark -
- (void) showInspectorForTargetBoard : (NSString *) boardName
{
	[self setCurrentTargetBoardName : boardName];
	[self showWindow : self];
}

- (void) mainWindowChanged : (NSNotification *) theNotification
{
	if (![[self window] isVisible]) return;

	id winController_ = [[theNotification object] windowController];

	if (([winController_ class] == [CMRThreadViewer class]) || ([winController_ class] == [CMRBrowser class])) {
		NSString *tmp_;
		tmp_ = [(CMRThreadViewer *)winController_ boardName];
		if(tmp_ == nil)
			tmp_ = [(CMRBBSSignature *)[(CMRThreadViewer *)winController_ boardIdentifier] name];
	
		if (nil == tmp_)
			return;
		[self setCurrentTargetBoardName : tmp_];
		[[self window] update];
	}
}

- (void) browserBoardChanged : (NSNotification *) theNotification
{
	if (![[self window] isVisible]) return;
	id winController_ = [theNotification object];

	if ([winController_ class] == [CMRBrowser class]) {
		NSString *tmp_;
		//tmp_ = [(CMRBrowser *)winController_ boardName];
		//if(tmp_ == nil)
			tmp_ = [(CMRBBSSignature *)[(CMRBrowser *)winController_ boardIdentifier] name];
	
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

	if ([winController_ class] == [CMRThreadViewer class]) {
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

/*- (void) windowWillCloseNow : (NSNotification *) theNotification
{
	// ウインドウが一つもなくなったらインスペクタを閉じたいけど、なんかうまくいかないのでとりあえず何もしない。
}*/
@end
