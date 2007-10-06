/**
 * $Id: CMRAppDelegate.m,v 1.37 2007/10/06 21:12:32 tsawada2 Exp $
 * 
 * CMRAppDelegate.m
 *
 * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
 * See the file LICENSE for copying permission.
 */
#import "CMRAppDelegate_p.h"
#import "BoardWarrior.h"
#import "CMRBrowser.h"
#import "CMRThreadDocument.h"
#import "TS2SoftwareUpdate.h"
#import "CMRTrashbox.h"
#import <SGAppKit/SGAppKit.h>

@class CMRDocumentController;

static NSString *const kOnlineItemKey = @"On Line";
static NSString *const kOfflineItemKey = @"Off Line";
static NSString *const kOnlineItemImageName = @"online";
static NSString *const kOfflineItemImageName = @"offline";
static NSString *const kRGBColorSpace = @"NSCalibratedRGBColorSpace";

static NSString *const kSWCheckURLKey = @"System - Software Update Check URL";
static NSString *const kSWDownloadURLKey = @"System - Software Update Download Page URL";

@implementation CMRAppDelegate
- (void) awakeFromNib
{
	m_shouldCascadeBrowserWindow = YES;
    [self setupMenu];
}

- (void) dealloc
{
	[m_threadPath release];
	[super dealloc];
}

- (BOOL) shouldCascadeBrowserWindow
{
	return m_shouldCascadeBrowserWindow;
}

- (void) setShouldCascadeBrowserWindow: (BOOL) flag
{
	m_shouldCascadeBrowserWindow = flag;
}

- (NSString *) threadPath
{
	return m_threadPath;
}

- (void) setThreadPath: (NSString *) aString
{
	[aString retain];
	[m_threadPath release];
	m_threadPath = aString;
}

#pragma mark IBAction

- (IBAction) showPreferencesPane : (id) sender
{
    [[CMRPref sharedPreferencesPane] showWindow : sender];
}
- (IBAction) showStandardFindPanel : (id) sender
{
    [[TextFinder standardTextFinder] showWindow : sender];
}
- (IBAction) toggleOnlineMode : (id) sender
{    
/*    [NSApp sendAction : @selector(toggleOnlineMode:)
                   to : CMRPref
                 from : sender];*/
	AppDefaults *defaults_ = CMRPref;
	[defaults_ setIsOnlineMode: (NO == [defaults_ isOnlineMode])];
}

- (IBAction) togglePreviewPanel : (id) sender
{
	[NSApp sendAction : @selector(togglePreviewPanel:)
				   to : [CMRPref sharedImagePreviewer]
				 from : sender];
}

- (IBAction) showTaskInfoPanel : (id) sender
{
    [[CMRTaskManager defaultManager] showWindow : sender];
}

// For Help Menu
- (IBAction) openURL : (id) sender
{
    NSURL *url;
    
    UTILAssertRespondsTo(sender, @selector(representedObject));
    if (url = [sender representedObject]) {
        UTILAssertKindOfClass(url, NSURL);
        [[NSWorkspace sharedWorkspace] openURL : url];
    }
}

// Application Reset Alert's help button delegate
- (BOOL) alertShowHelp : (NSAlert *) alert
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor : [alert helpAnchor]
											   inBook : [NSBundle applicationHelpBookName]];
	return YES;
}

- (IBAction) resetApplication : (id) sender
{
    CMRApplicationReset(self);
}

- (IBAction) openURLPanel : (id) sender
{
	if (NO == [NSApp isActive]) [NSApp activateIgnoringOtherApps: YES];
	[[CMROpenURLManager defaultManager] askUserURL];
}

- (IBAction) clearHistory : (id) sender
{
	[[CMRHistoryManager defaultManager] removeAllItems];
}

- (IBAction) showThreadFromHistoryMenu: (id) sender
{
	if (NO == [sender isKindOfClass: [NSMenuItem class]]) return;

	id historyItem = [sender representedObject];
	id winController_ = [[NSApp mainWindow] windowController];

	if (winController_ && [winController_ respondsToSelector: @selector(showThreadWithMenuItem:)]) {
		if ([NSEvent currentCarbonModifierFlags] & NSCommandKeyMask) {
			[CMRThreadDocument showDocumentWithHistoryItem: historyItem];
		} else {
			[winController_ showThreadWithMenuItem: sender];
		}
	} else {
		[CMRThreadDocument showDocumentWithHistoryItem: historyItem];
	}
}

- (IBAction) showAcknowledgment : (id) sender
{
	NSBundle	*mainBundle;
    NSString	*fileName;
	NSString	*appName;
	NSWorkspace	*ws = [NSWorkspace sharedWorkspace];

    mainBundle = [NSBundle mainBundle];
    fileName = [mainBundle pathForResource : @"Acknowledgments" ofType : @"rtf"];
	appName = [ws absolutePathForAppBundleWithIdentifier : @"com.apple.TextEdit"];
	
    [ws openFile : fileName withApplication : appName];
}

- (IBAction) closeAll : (id) sender
{
	NSArray *allWindows = [NSApp windows];
	if (!allWindows) return;
	NSEnumerator	*iter = [allWindows objectEnumerator];
	NSWindow		*window;
	while (window = [iter nextObject]) {
		if ([window isVisible] && NO == [window isSheet]) {
			[window performClose: sender];
		}
	}
}

- (IBAction) miniaturizeAll : (id) sender
{
	[NSApp miniaturizeAll : sender];
}

- (IBAction) launchCMLF : (id) sender
{
//    [[NSWorkspace sharedWorkspace] launchApplication: [CMRPref helperAppPath]];
}

- (IBAction) runBoardWarrior: (id) sender
{
	[[BoardWarrior warrior] syncBoardLists];
}

- (void) mainBrowserDidFinishShowThList : (NSNotification *) aNotification
{
	UTILAssertNotificationName(
		aNotification,
		CMRBrowserThListUpdateDelegateTaskDidFinishNotification);

	[CMRMainBrowser selectRowWithThreadPath: [self threadPath]
					   byExtendingSelection: NO
							scrollToVisible: YES];

	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: CMRBrowserThListUpdateDelegateTaskDidFinishNotification
												  object: CMRMainBrowser];
}

- (void) showThreadsListForBoard: (NSString *) boardName selectThread: (NSString *) path addToListIfNeeded: (BOOL) addToList
{
	if (CMRMainBrowser != nil) {
		[[CMRMainBrowser window] makeKeyAndOrderFront : self];
	} else {
		[[CMRDocumentController sharedDocumentController] newDocument : self];
	}

	if (path) {
		[self setThreadPath: path];
		[[NSNotificationCenter defaultCenter] addObserver : self
												 selector : @selector(mainBrowserDidFinishShowThList:)
													 name : CMRBrowserThListUpdateDelegateTaskDidFinishNotification
												   object : CMRMainBrowser];
	}
	// addBrdToUsrListIfNeeded オプションは当面の間無視（常に YES 扱いで）
	[CMRMainBrowser selectRowWhoseNameIs: boardName]; // この結果として outlineView の selectionDidChange: が「確実に」
													  // 呼び出される限り、そこから showThreadsListForBoardName: が呼び出される
}

- (IBAction) showBoardFromHistoryMenu: (id) sender
{
	if (NO == [sender isKindOfClass: [NSMenuItem class]]) return;

	id boardListItem = [sender representedObject];
	if (boardListItem && [boardListItem respondsToSelector: @selector(representName)]) {
		[self showThreadsListForBoard: [boardListItem representName] selectThread: nil addToListIfNeeded: YES];
	}
}

- (IBAction) startHEADCheckDirectly: (id) sender
{
	BOOL	hasBeenOnline = [CMRPref isOnlineMode];

	// 簡単のため、いったんオンラインモードを切る
	if(hasBeenOnline) [self toggleOnlineMode: sender];
	
	[self showThreadsListForBoard: CMXFavoritesDirectoryName selectThread: nil addToListIfNeeded: NO];
	[CMRMainBrowser reloadThreadsList: sender];

	// 必要ならオンラインに復帰
	if(hasBeenOnline) [self toggleOnlineMode: sender];
}

- (IBAction) openWebSiteForUpdate: (id) sender
{
	[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: SGTemplateResource(kSWDownloadURLKey)]];
}
- (IBAction) checkForUpdate: (id) sender
{
	[[TS2SoftwareUpdate sharedInstance] startUpdateCheck: sender];
}
- (IBAction) changeUpdateSettings: (id) sender
{
	id prefs = [CMRPref sharedPreferencesPane];
	[prefs showWindow: sender];
	if ([prefs respondsToSelector: @selector(selectControllerWithIdentifier:)]) {
		[prefs selectControllerWithIdentifier: @"General"];
	}
}

#pragma mark validation
- (BOOL) validateToolbarItem : (NSToolbarItem *) theItem
{
	SEL action_ = [theItem action];
	if (action_ == @selector(launchCMLF:)) {
/*		NSString	*name_ = [CMRPref helperAppDisplayName];

		if (nil == name_) {
			return NO;
		} else {
			[theItem setLabel : name_];
			[theItem setPaletteLabel : name_];
			return YES;
		}*/
		return NO;
	}

	if (action_ == @selector(toggleOnlineMode:)) {
		NSString		*title_;
		NSImage			*image_;
		
		title_ = [CMRPref isOnlineMode]
					? [self localizedString : kOnlineItemKey]
					: [self localizedString : kOfflineItemKey];

		image_ = [CMRPref isOnlineMode]
					? [NSImage imageAppNamed : kOnlineItemImageName]
					: [NSImage imageAppNamed : kOfflineItemImageName];
		
		[theItem setImage : image_];
		[theItem setLabel : title_];
		return YES;
	}

	return YES;
}

- (BOOL) validateMenuItem : (NSMenuItem *) theItem
{
	SEL action_ = [theItem action];

	if (action_ == @selector(launchCMLF:)) {
/*		NSString	*name_ = [CMRPref helperAppDisplayName];

		if (nil == name_) {
			[theItem setTitle : [self localizedString : APP_MAINMENU_HELPER_NOTFOUND]];
			return NO;
		} else {
			[theItem setTitle : name_];
			return YES;
		}*/
		return NO;
	} else if (action_ == @selector(closeAll:)) {
		return ([NSApp makeWindowsPerform : @selector(isVisible) inOrder : YES] != nil);
	} else if (action_ == @selector(miniaturizeAll:)) {
		return ([NSApp makeWindowsPerform : @selector(isNotMiniaturizedButCanMinimize) inOrder : YES] != nil);
	} else if (action_ == @selector(togglePreviewPanel:)) {
		id tmp_ = [CMRPref sharedImagePreviewer];
		return [tmp_ respondsToSelector : @selector(togglePreviewPanel:)];
	} else if (action_ == @selector(startHEADCheckDirectly:)) {
		return [CMRPref canHEADCheck];
	} else if (action_ == @selector(toggleOnlineMode:)) {
		[theItem setState: [CMRPref isOnlineMode] ? NSOnState : NSOffState];
		return YES;
	}
	return YES;
}

#pragma mark AppleEvent Support
// Available in BathyScaphe 1.2 and later.
- (void) handleGetURLEvent : (NSAppleEventDescriptor *) event withReplyEvent : (NSAppleEventDescriptor *) replyEvent
{
    NSString	*urlStr_;
    NSURL		*url_;

    urlStr_ = [[event paramDescriptorForKeyword : keyDirectObject] stringValue];
	url_ = [NSURL URLWithString : urlStr_];

	// scheme の違い（bathyscaphe: or http:）は CMROpenURLManager が吸収する
    [[CMROpenURLManager defaultManager] openLocation : url_];
}

#pragma mark NSApplication Delegates
- (void) applicationWillFinishLaunching : (NSNotification *) aNotification
// available in BathyScaphe 1.2 and later.
{
	NSAppleEventManager	*aeMgr = [NSAppleEventManager sharedAppleEventManager];
	
	[aeMgr setEventHandler : self
			   andSelector : @selector(handleGetURLEvent:withReplyEvent:)
			 forEventClass : 'GURL'
				andEventID : 'GURL']; // 'GURL' is different from 'gurl'

	TS2SoftwareUpdate *checker = [TS2SoftwareUpdate sharedInstance];
	[checker setUpdateInfoURL: [NSURL URLWithString: SGTemplateResource(kSWCheckURLKey)]];
	[checker setOpenPrefsSelector: @selector(changeUpdateSettings:)];
	[checker setUpdateNowSelector: @selector(openWebSiteForUpdate:)];
}

- (void) applicationDidFinishLaunching : (NSNotification *) aNotification
{
	CMRMainMenuManager *tmp = [CMRMainMenuManager defaultManager];
    /* Service menu */
    [NSApp setServicesProvider : [CMROpenURLManager defaultManager]];

	/* Remove 'Open Recent' menu */
	int openURLMenuItemIndex = [[tmp fileMenu] indexOfItemWithTarget : self andAction : @selector(openURLPanel:)];

    if (openURLMenuItemIndex >= 0 && [[[tmp fileMenu] itemAtIndex : openURLMenuItemIndex+1] hasSubmenu])
    {
		[[tmp fileMenu] removeItemAtIndex : openURLMenuItemIndex+1];
    }
	
	/* BoardWarrior Task */
	if ([CMRPref isOnlineMode] && [CMRPref autoSyncBoardList]) {
		NSDate *lastDate = [CMRPref lastSyncDate];
		if (!lastDate || [[NSDate date] timeIntervalSinceDate: lastDate] > [CMRPref timeIntervalForAutoSyncPrefs]) {
			[self runBoardWarrior: nil];
		}
	}

	if ([CMRPref isOnlineMode]) [[TS2SoftwareUpdate sharedInstance] startUpdateCheck: nil];
}

- (BOOL) applicationShouldHandleReopen: (NSApplication *) theApplication hasVisibleWindows: (BOOL) flag
{
	if (NO == flag) {
		m_shouldCascadeBrowserWindow = NO;
	}
	return YES;
}
@end

#pragma mark -
@implementation CMRAppDelegate(CMRLocalizableStringsOwner)
+ (NSString *) localizableStringsTableName
{
    return APP_MAINMENU_LOCALIZABLE_FILE_NAME;
}
@end

#pragma mark -
@implementation NSApplication(ScriptingSupport)
- (BOOL) isOnlineMode
{
	return [CMRPref isOnlineMode];
}
- (void) setIsOnlineMode : (BOOL) flag
{
	[CMRPref setIsOnlineMode : flag];
}

- (NSArray *) browserTableViewColor
{
	float red,green,blue;
	
	NSColor *color_ = [CMRPref browserSTableBackgroundColor];
		
	[[color_ colorUsingColorSpaceName : kRGBColorSpace] getRed: &red green: &green blue: &blue alpha: NULL];

	return [NSArray arrayWithObjects : [NSNumber numberWithFloat:red], [NSNumber numberWithFloat:green], [NSNumber numberWithFloat:blue], nil];
}

- (void) setBrowserTableViewColor : (NSArray *) colorValue;
{
	// colorValue 配列の要素数が 0 のときは、デフォルトのカラーに戻す。
	// また、配列の要素数が 0,3 以外のときは何もしない。
	if ([colorValue count] == 0) {
		[CMRPref setBrowserSTableBackgroundColor: [NSColor whiteColor]];
	} else if ([colorValue count] == 3) {
		float red,green,blue;
		red		= [[colorValue objectAtIndex : 0] floatValue];
		green	= [[colorValue objectAtIndex : 1] floatValue];
		blue	= [[colorValue objectAtIndex : 2] floatValue];
	
		if (red == 0 && green == 0 && blue == 0) {
			[CMRPref setBrowserSTableBackgroundColor: [NSColor whiteColor]];
		} else {
			[CMRPref setBrowserSTableBackgroundColor : [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1.0]];
		}
	}
}
- (NSArray *) boardListColor
{
	float red,green,blue;
	
	NSColor *color_ = [CMRPref boardListBackgroundColor];		
	[[color_ colorUsingColorSpaceName : kRGBColorSpace] getRed: &red green: &green blue: &blue alpha: NULL];

	return [NSArray arrayWithObjects : [NSNumber numberWithFloat:red], [NSNumber numberWithFloat:green], [NSNumber numberWithFloat:blue], nil];
}

- (void) setBoardListColor : (NSArray *) colorValue;
{
	// colorValue 配列の要素数が 0 のときは、デフォルトのカラーに戻す。
	// また、配列の要素数が 0,3 以外のときは何もしない。
	if ([colorValue count] == 0) {
		[CMRPref setBoardListBackgroundColor : nil];
	} else if ([colorValue count] == 3) {
		float red,green,blue;
		red		= [[colorValue objectAtIndex : 0] floatValue];
		green	= [[colorValue objectAtIndex : 1] floatValue];
		blue	= [[colorValue objectAtIndex : 2] floatValue];

		[CMRPref setBoardListBackgroundColor : [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1.0]];
	}
}

- (void) handleOpenURLCommand : (NSScriptCommand *) command
{
	NSURL		*url_;
	NSString	*urlstr_ = [command directParameter];
	
	if(!urlstr_ || [urlstr_ isEqualToString : @""])
		return;
	
	url_ = [NSURL URLWithString : urlstr_];	
	[[CMROpenURLManager defaultManager] openLocation : url_];
}

- (void)handleRemoveFromDBCommand:(NSScriptCommand *)command
{
	NSString *filePath_ = [command directParameter];
	if (!filePath_ || [filePath_ isEqualToString:@""]) return;

	NSNumber *number = [NSNumber numberWithInt:noErr];
	NSNotification *notification = [NSNotification notificationWithName:CMRTrashboxDidPerformNotification
																 object:[CMRTrashbox trash]
															   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:number, kAppTrashUserInfoStatusKey,
																							[NSArray arrayWithObject:filePath_], kAppTrashUserInfoFilesKey,
																							[NSNumber numberWithBool:YES], kAppTrashUserInfoAfterFetchKey,
																							NULL]];
	if (notification) [[NSNotificationCenter defaultCenter] postNotification:notification];
}
@end
