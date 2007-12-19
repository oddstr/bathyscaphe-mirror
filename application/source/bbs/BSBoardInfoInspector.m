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
#import "CMRBrowser.h"
#import "BoardListItem.h"
#import "EditBoardSheetController.h"

#define BrdMgr	[BoardManager defaultManager]

static NSString *const BIINibFileNameKey		= @"BSBoardInfoInspector";
static NSString *const BIIFrameAutoSaveNameKey	= @"BathyScaphe:BoardInfoInspector Panel Autosave";
static NSString *const BIIHelpKeywordKey		= @"BoardInspector Help Keyword";

@implementation BSBoardInfoInspector
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedInstance);

+ (void)initialize
{
	if (self == [BSBoardInfoInspector class]) {
		NSArray	*keyArray = [NSArray arrayWithObject: @"currentTargetBoardName"];

		[self setKeys:keyArray triggerChangeNotificationsForDependentKey:@"noNamesArray"];
		[self setKeys:keyArray triggerChangeNotificationsForDependentKey:@"boardURLAsString"];
		[self setKeys:keyArray triggerChangeNotificationsForDependentKey:@"shouldEnableUI"];
		[self setKeys:keyArray triggerChangeNotificationsForDependentKey:@"defaultKotehan"];
		[self setKeys:keyArray triggerChangeNotificationsForDependentKey:@"defaultMail"];
		[self setKeys:keyArray triggerChangeNotificationsForDependentKey:@"shouldAlwaysBeLogin"];
		[self setKeys:keyArray triggerChangeNotificationsForDependentKey:@"shouldAllThreadsAAThread"];
		[self setKeys:keyArray triggerChangeNotificationsForDependentKey:@"boardListItem"];
		[self setKeys:keyArray triggerChangeNotificationsForDependentKey:@"shouldEnableBeBtn"];
		[self setKeys:keyArray triggerChangeNotificationsForDependentKey:@"shouldEnableURLEditing"];
		[self setKeys:keyArray triggerChangeNotificationsForDependentKey:@"nanashiAllowed"];
	}
}

- (id)init
{
	if (self = [super initWithWindowNibName:BIINibFileNameKey]) {
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc
			 addObserver : self
				selector : @selector(browserBoardChanged:)
					name : CMRBrowserDidChangeBoardNotification
				  object : nil];

		[nc
			 addObserver : self
				selector : @selector(mainWindowChanged:)
					name : NSWindowDidBecomeMainNotification
				  object : nil];

		[nc
			 addObserver : self
				selector : @selector(viewerThreadChanged:)
					name : CMRThreadViewerDidChangeThreadNotification
				  object : nil];
		[self setIsDetecting:NO];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[m_currentTargetBoardName release];
	[super dealloc];
}

- (void)awakeFromNib
{
	[[self window] setFrameAutosaveName:BIIFrameAutoSaveNameKey];

	if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_3) {
		[[self addNoNameBtn] setBezelStyle:NSSmallSquareBezelStyle];
		[[self removeNoNameBtn] setBezelStyle:NSSmallSquareBezelStyle];
		[[self editBoardURLButton] setBezelStyle:NSRoundRectBezelStyle];
	}
}

- (void) showInspectorForTargetBoard : (NSString *) boardName
{
	[self setCurrentTargetBoardName : boardName];
	[self showWindow : self];
}

#pragma mark Accessors
- (NSString *)currentTargetBoardName
{
	return m_currentTargetBoardName;
}
- (void)setCurrentTargetBoardName:(NSString *)newTarget
{
	[newTarget retain];
	[m_currentTargetBoardName release];
	m_currentTargetBoardName = newTarget;
}

- (BOOL)isDetecting
{
	return m_isDetecting;
}

- (void)setIsDetecting:(BOOL)flag
{
	m_isDetecting = flag;
}

- (NSButton *)addNoNameBtn
{
	return m_addNoNameBtn;
}

- (NSButton *)removeNoNameBtn
{
	return m_removeNoNameBtn;
}

- (NSButton *)editBoardURLButton
{
	return m_editBoardURLButton;
}

#pragma mark IBActions
- (IBAction)showWindow:(id)sender
{
	// toggle-Action : すでにパネルが表示されているときは、パネルを閉じる
	if ([[self window] isVisible]) {
		[[self window] performClose:sender];
	} else {
		[super showWindow:sender];
	}
}

- (IBAction)addNoName:(id)sender
{
	NSString	*newNanashi;
	newNanashi = [BrdMgr askUserAboutDefaultNoNameForBoard:[self currentTargetBoardName]
											   presetValue:nil];
	if (!newNanashi) return;
	[self willChangeValueForKey:@"noNamesArray"];
	[BrdMgr addNoName:newNanashi forBoard:[self currentTargetBoardName]];
	[self didChangeValueForKey:@"noNamesArray"];
}

- (IBAction)startDetect:(id)sender
{
	if ([BrdMgr startDownloadSettingTxtForBoard:[self currentTargetBoardName] askIfOffline:NO]) {
		[[NSNotificationCenter defaultCenter]
			 addObserver:self
				selector:@selector(boardManagerDidDetectSettingTxt:)
					name:BoardManagerDidFinishDetectingSettingTxtNotification
				  object:BrdMgr];
		[self setIsDetecting:YES];
	} else {
		NSBeep();
	}
}

- (IBAction)editBoardURL:(id)sender
{
	EditBoardSheetController *controller = [[EditBoardSheetController alloc] init];
	[controller beginEditBoardSheetForWindow:[self window] modalDelegate:self contextInfo:[self boardListItem]];
}

- (IBAction)openHelpForMe:(id)sender
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor:NSLocalizedString(BIIHelpKeywordKey, @"Board options")
											   inBook:[NSBundle applicationHelpBookName]];
}

#pragma mark Accesors For Binding
- (NSMutableArray *)noNamesArray
{
	return [[[BrdMgr defaultNoNameArrayForBoard:[self currentTargetBoardName]] mutableCopy] autorelease];
}

- (void)setNoNamesArray:(NSMutableArray *)anArray
{
	[BrdMgr setDefaultNoNameArray:[NSArray arrayWithArray:anArray] forBoard:[self currentTargetBoardName]];
}

- (NSString *)boardURLAsString
{
	BoardListItem	*tmp = [self boardListItem];
	if ([tmp type] != BoardListBoardItem) return nil;
	return [[tmp url] absoluteString];
}

- (BOOL)shouldEnableUI
{
	BoardListItem *tmp_ = [self boardListItem];
	if ([[self boardListItem] type] != BoardListBoardItem) return NO;
	if ([[tmp_ representName] hasSuffix:@"headline"]) return NO;
	return YES;
}

- (BOOL)shouldEnableBeBtn
{
	return (BSBeLoginDecidedByUser == [BrdMgr typeOfBeLoginPolicyForBoard:[self currentTargetBoardName]]);
}

- (BOOL)shouldEnableURLEditing
{
	return ([[self boardListItem] type] == BoardListBoardItem);
}

- (NSString *)defaultKotehan
{
	return [BrdMgr defaultKotehanForBoard:[self currentTargetBoardName]];
}

- (void)setDefaultKotehan:(NSString *)fieldValue
{
	[BrdMgr setDefaultKotehan:((fieldValue != nil) ? fieldValue : @"") forBoard:[self currentTargetBoardName]];
}

- (NSString *)defaultMail
{
	return [BrdMgr defaultMailForBoard:[self currentTargetBoardName]];
}

- (void)setDefaultMail:(NSString *)fieldValue
{
	[BrdMgr setDefaultMail:((fieldValue != nil) ? fieldValue : @"") forBoard:[self currentTargetBoardName]];
}

- (BOOL)shouldAlwaysBeLogin
{
	return [BrdMgr alwaysBeLoginAtBoard:[self currentTargetBoardName]];
}

- (void)setShouldAlwaysBeLogin:(BOOL)checkboxState
{
	[BrdMgr setAlwaysBeLogin:checkboxState atBoard:[self currentTargetBoardName]];
}

- (BOOL)shouldAllThreadsAAThread
{
	return [BrdMgr allThreadsShouldAAThreadAtBoard:[self currentTargetBoardName]];
}

- (void)setShouldAllThreadsAAThread:(BOOL)checkboxState
{
	[BrdMgr setAllThreadsShouldAAThread:checkboxState atBoard:[self currentTargetBoardName]];
}

- (BoardListItem *)boardListItem
{
	return [BrdMgr itemForName:[self currentTargetBoardName]];
}

- (int)nanashiAllowed
{
	return [BrdMgr allowsNanashiAtBoard:[self currentTargetBoardName]] ? 0 : 1;
}

#pragma mark Notification
- (void) mainWindowChanged : (NSNotification *) theNotification
{
	if (![[self window] isVisible]) return;

	id winController_ = [[theNotification object] windowController];

	if ([winController_ respondsToSelector: @selector(boardName)]) {
		NSString *tmp_ = [winController_ boardName];
				
		if (!tmp_) return;
		
		[self setCurrentTargetBoardName: tmp_];
		[[self window] update];
	}
}

- (void) browserBoardChanged : (NSNotification *) theNotification
{
	if (![[self window] isVisible]) return;
	id winController_ = [theNotification object];

	if (NO == [(NSWindow *)[winController_ window] isMainWindow]) return;

	if ([winController_ respondsToSelector:@selector(currentThreadsList)]) {
		NSString *tmp_;
		tmp_ = [[winController_ currentThreadsList] BBSName];
		if (!tmp_) return;
		[self setCurrentTargetBoardName:tmp_];
		[[self window] update];
	}
}

- (void) viewerThreadChanged : (NSNotification *) theNotification
{
	if (![[self window] isVisible]) return;
	id winController_ = [theNotification object];

	if ([winController_ isMemberOfClass: [CMRThreadViewer class]]) {
		NSString *tmp_;
		tmp_ = [(CMRThreadViewer *)winController_ boardName];
	
		if (nil == tmp_)
			return;
		if ([[self currentTargetBoardName] isEqualToString : tmp_])
			return;

		[self setCurrentTargetBoardName : tmp_];
		[[self window] update];
	}
}

- (void)boardManagerDidDetectSettingTxt:(NSNotification *)aNotification
{
	[self setIsDetecting:NO];
	if ([[self window] isVisible]) {
		[self setCurrentTargetBoardName:m_currentTargetBoardName];
		[[self window] update];
	}

	[[NSNotificationCenter defaultCenter] removeObserver:self name:BoardManagerDidFinishDetectingSettingTxtNotification object:BrdMgr];
}

- (void)controller:(EditBoardSheetController *)controller didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode
{
	[controller autorelease];
}
@end
