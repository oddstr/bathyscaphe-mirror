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

#define BrdMgr	[BoardManager defaultManager]

static NSString *const BIINibFileNameKey		= @"BSBoardInfoInspector";
static NSString *const BIIFrameAutoSaveNameKey	= @"BathyScaphe:BoardInfoInspector Panel Autosave";

@implementation BSBoardInfoInspector
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedInstance);

- (id) init
{
	return [self initWithWindowNibName : BIINibFileNameKey];
}

- (void) dealloc
{
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
	[self willChangeValueForKey:@"defaultKotehan"];
	[self willChangeValueForKey:@"defaultMail"];
	[self willChangeValueForKey:@"shouldAlwaysBeLogin"];

	[newTarget retain];
	[_currentTargetBoardName release];
	_currentTargetBoardName = newTarget;

	[self didChangeValueForKey:@"defaultNanashi"];
	[self didChangeValueForKey:@"defaultKotehan"];
	[self didChangeValueForKey:@"defaultMail"];
	[self didChangeValueForKey:@"shouldAlwaysBeLogin"];
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
	[[self nanashiField] setStringValue : newNanashi];
}
- (IBAction) openHelpForMe : (id) sender
{
	NSLog(@"UnImplemented");
	NSBeep();
}

#pragma mark Accesors for Binding
- (NSString *) defaultNanashi
{
	return [BrdMgr defaultNoNameForBoard : [self currentTargetBoardName]];
}

- (NSString *) defaultKotehan
{
	return [BrdMgr defaultKotehanForBoard : [self currentTargetBoardName]];
}

- (void) setDefaultKotehan : (NSString *) fieldValue
{
	[BrdMgr setDefaultKotehan : fieldValue forBoard : [self currentTargetBoardName]];
}

- (NSString *) defaultMail
{
	return [BrdMgr defaultMailForBoard : [self currentTargetBoardName]];
}

- (void) setDefaultMail : (NSString *) fieldValue
{
	[BrdMgr setDefaultMail : fieldValue forBoard : [self currentTargetBoardName]];
}

- (BOOL) shouldAlwaysBeLogin
{
	return [BrdMgr alwaysBeLoginAtBoard : [self currentTargetBoardName]];
}

- (void) setShouldAlwaysBeLogin : (BOOL) checkboxState
{
	[BrdMgr setAlwaysBeLogin : checkboxState atBoard : [self currentTargetBoardName]];
}

#pragma mark -
- (void) showInspectorForTargetBoard : (NSString *) boardName
{
	[self setCurrentTargetBoardName : boardName];
	[self showWindow : self];
}
@end
