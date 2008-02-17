//
//  CMRAppDelegate.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/12/19.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRAppDelegate_p.h"
#import "BoardWarrior.h"
#import "CMRBrowser.h"
#import "BoardListItem.h"
#import "CMRThreadDocument.h"
#import "TS2SoftwareUpdate.h"
#import "CMRDocumentController.h"
#import "BSDateFormatter.h"

static NSString *const kOnlineItemKey = @"On Line";
static NSString *const kOfflineItemKey = @"Off Line";
static NSString *const kOnlineItemImageName = @"online";
static NSString *const kOfflineItemImageName = @"offline";

static NSString *const kSWCheckURLKey = @"System - Software Update Check URL";
static NSString *const kSWDownloadURLKey = @"System - Software Update Download Page URL";

@implementation CMRAppDelegate
- (void)awakeFromNib
{
	m_shouldCascadeBrowserWindow = YES;
    [self setupMenu];
}

- (void)dealloc
{
	[m_threadPath release];
	[super dealloc];
}

- (BOOL)shouldCascadeBrowserWindow
{
	return m_shouldCascadeBrowserWindow;
}

- (void)setShouldCascadeBrowserWindow:(BOOL)flag
{
	m_shouldCascadeBrowserWindow = flag;
}

- (NSString *)threadPath
{
	return m_threadPath;
}

- (void)setThreadPath:(NSString *)aString
{
	[aString retain];
	[m_threadPath release];
	m_threadPath = aString;
}

#pragma mark IBAction
- (IBAction)checkForUpdate:(id)sender
{
	[[TS2SoftwareUpdate sharedInstance] startUpdateCheck:sender];
}

- (IBAction)showPreferencesPane:(id)sender
{
	[NSApp sendAction:@selector(showWindow:) to:[CMRPref sharedPreferencesPane] from:sender];
}

- (IBAction)toggleOnlineMode:(id)sender
{   
	[CMRPref setIsOnlineMode:(![CMRPref isOnlineMode])];
}

- (IBAction)resetApplication:(id)sender
{
    CMRApplicationReset(self);
}

- (IBAction)customizeTextTemplates:(id)sender
{
	[[CMRPref sharedPreferencesPane] showPreferencesPaneWithIdentifier:PPReplyDefaultIdentifier];
}

- (IBAction)togglePreviewPanel:(id)sender
{
	[NSApp sendAction:@selector(togglePreviewPanel:) to:[CMRPref sharedImagePreviewer] from:sender];
}

- (IBAction)showTaskInfoPanel:(id)sender
{
    [[CMRTaskManager defaultManager] showWindow:sender];
}

// For Help Menu
- (IBAction)openURL:(id)sender
{
    NSURL *url;
    
    UTILAssertRespondsTo(sender, @selector(representedObject));
    if (url = [sender representedObject]) {
        UTILAssertKindOfClass(url, NSURL);
        [[NSWorkspace sharedWorkspace] openURL:url];
    }
}

- (IBAction)showAcknowledgment:(id)sender
{
	NSBundle	*mainBundle;
    NSString	*fileName;
	NSString	*appName;
	NSWorkspace	*ws = [NSWorkspace sharedWorkspace];

    mainBundle = [NSBundle mainBundle];
    fileName = [mainBundle pathForResource:@"Acknowledgments" ofType:@"rtf"];
	appName = [ws absolutePathForAppBundleWithIdentifier:@"com.apple.TextEdit"];
	
    [ws openFile:fileName withApplication:appName];
}

- (IBAction)openURLPanel:(id)sender
{
	if (![NSApp isActive]) [NSApp activateIgnoringOtherApps:YES];
	[[CMROpenURLManager defaultManager] askUserURL];
}

- (IBAction)closeAll:(id)sender
{
	NSArray *allWindows = [NSApp windows];
	if (!allWindows) return;
	NSEnumerator	*iter = [allWindows objectEnumerator];
	NSWindow		*window;
	while (window = [iter nextObject]) {
		if ([window isVisible] && ![window isSheet]) {
			[window performClose:sender];
		}
	}
}

- (IBAction)clearHistory:(id)sender
{
	[[CMRHistoryManager defaultManager] removeAllItems];
}

- (IBAction)showThreadFromHistoryMenu:(id)sender
{
	UTILAssertRespondsTo(sender, @selector(representedObject));
	[CMRThreadDocument showDocumentWithHistoryItem:[sender representedObject]];
}

- (IBAction)showBoardFromHistoryMenu:(id)sender
{
    UTILAssertRespondsTo(sender, @selector(representedObject));

	BoardListItem *boardListItem = [sender representedObject];
	if (boardListItem && [boardListItem respondsToSelector: @selector(representName)]) {
		[self showThreadsListForBoard:[boardListItem representName] selectThread:nil addToListIfNeeded:YES];
	}
}

- (IBAction)startHEADCheckDirectly:(id)sender
{
	BOOL	hasBeenOnline = [CMRPref isOnlineMode];

	// 簡単のため、いったんオンラインモードを切る
	if (hasBeenOnline) [self toggleOnlineMode:sender];
	
	[self showThreadsListForBoard:CMXFavoritesDirectoryName selectThread:nil addToListIfNeeded:NO];
	[CMRMainBrowser reloadThreadsList:sender];

	// 必要ならオンラインに復帰
	if (hasBeenOnline) [self toggleOnlineMode:sender];
}

- (IBAction)runBoardWarrior:(id)sender
{
	[[BoardWarrior warrior] syncBoardLists];
}

- (IBAction)openAEDictionary:(id)sender
{
	NSString *selfPath = [[NSBundle mainBundle] bundlePath];
	NSString *toysPath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:@"com.apple.ScriptEditor2"];
	if (selfPath && toysPath) {
		[[NSWorkspace sharedWorkspace] openFile:selfPath withApplication:toysPath];
	}
}

// Application Reset Alert's help button delegate
- (BOOL)alertShowHelp:(NSAlert *)alert
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor:[alert helpAnchor] inBook:[NSBundle applicationHelpBookName]];
	return YES;
}

- (void)mainBrowserDidFinishShowThList:(NSNotification *)aNotification
{
	UTILAssertNotificationName(
		aNotification,
		CMRBrowserThListUpdateDelegateTaskDidFinishNotification);

	[CMRMainBrowser selectRowWithThreadPath:[self threadPath]
					   byExtendingSelection:NO
							scrollToVisible:YES];

	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:CMRBrowserThListUpdateDelegateTaskDidFinishNotification
												  object:CMRMainBrowser];
}

- (void)showThreadsListForBoard:(NSString *)boardName selectThread:(NSString *)path addToListIfNeeded:(BOOL)addToList
{
	if (CMRMainBrowser != nil) {
		[[CMRMainBrowser window] makeKeyAndOrderFront:self];
	} else {
		[[CMRDocumentController sharedDocumentController] newDocument:self];
	}

	if (path) {
		[self setThreadPath:path];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(mainBrowserDidFinishShowThList:)
													 name:CMRBrowserThListUpdateDelegateTaskDidFinishNotification
												   object:CMRMainBrowser];
	}
	// addBrdToUsrListIfNeeded オプションは当面の間無視（常に YES 扱いで）
	[CMRMainBrowser selectRowWhoseNameIs:boardName]; // この結果として outlineView の selectionDidChange: が「確実に」
													 // 呼び出される限り、そこから showThreadsListForBoardName: が呼び出される
}

- (IBAction)openWebSiteForUpdate:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:SGTemplateResource(kSWDownloadURLKey)]];
}

- (IBAction) changeUpdateSettings:(id)sender
{
	[[CMRPref sharedPreferencesPane] showPreferencesPaneWithIdentifier:PPGeneralPreferencesIdentifier];
}

#pragma mark Validation
- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
	SEL action_ = [theItem action];

	if (action_ == @selector(toggleOnlineMode:)) {
		BOOL			isOnline = [CMRPref isOnlineMode];
		NSString		*title_;
		NSImage			*image_;
		
		title_ = isOnline ? [self localizedString:kOnlineItemKey] : [self localizedString:kOfflineItemKey];
		image_ = isOnline ? [NSImage imageAppNamed:kOnlineItemImageName] : [NSImage imageAppNamed:kOfflineItemImageName];
		
		[theItem setImage:image_];
		[theItem setLabel:title_];
		return YES;
	}

	return YES;
}

- (BOOL)validateMenuItem:(NSMenuItem *)theItem
{
	SEL action_ = [theItem action];

	if (action_ == @selector(closeAll:)) {
		return ([NSApp makeWindowsPerform:@selector(isVisible) inOrder:YES] != nil);
	} else if (action_ == @selector(togglePreviewPanel:)) {
		id tmp_ = [CMRPref sharedImagePreviewer];
		return [tmp_ respondsToSelector:@selector(togglePreviewPanel:)];
	} else if (action_ == @selector(startHEADCheckDirectly:)) {
		return [CMRPref canHEADCheck];
	} else if (action_ == @selector(toggleOnlineMode:)) {
		[theItem setState:[CMRPref isOnlineMode] ? NSOnState : NSOffState];
		return YES;
	}
	return YES;
}

#pragma mark NSApplication Delegates
- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
	BSStringFromDateTransformer *transformer;
	NSAppleEventManager	*aeMgr = [NSAppleEventManager sharedAppleEventManager];

	[aeMgr setEventHandler:[CMROpenURLManager defaultManager]
			   andSelector:@selector(handleGetURLEvent:withReplyEvent:)
			 forEventClass:'GURL'
				andEventID:'GURL'];

	TS2SoftwareUpdate *checker = [TS2SoftwareUpdate sharedInstance];
	[checker setUpdateInfoURL:[NSURL URLWithString:SGTemplateResource(kSWCheckURLKey)]];
	[checker setOpenPrefsSelector:@selector(changeUpdateSettings:)];
	[checker setUpdateNowSelector:@selector(openWebSiteForUpdate:)];

	transformer = [[[BSStringFromDateTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:transformer forName:@"BSStringFromDateTransformer"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	AppDefaults *defaults_ = CMRPref;

    /* Service menu */
    [NSApp setServicesProvider:[CMROpenURLManager defaultManager]];

	/* Remove 'Open Recent' menu */
	CMRMainMenuManager *menuManager = [CMRMainMenuManager defaultManager];
	[menuManager removeOpenRecentsMenuItem];
	[menuManager removeQuickLookMenuItemIfNeeded];
	[menuManager removeShowLocalRulesMenuItemIfNeeded];
	
	/* BoardWarrior Task */
	if ([defaults_ isOnlineMode] && [defaults_ autoSyncBoardList]) {
		NSDate *lastDate = [defaults_ lastSyncDate];
		if (!lastDate || [[NSDate date] timeIntervalSinceDate: lastDate] > [defaults_ timeIntervalForAutoSyncPrefs]) {
			[self runBoardWarrior:nil];
		}
	}

	if ([defaults_ isOnlineMode]) [[TS2SoftwareUpdate sharedInstance] startUpdateCheck:nil];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
	if (!flag) {
		m_shouldCascadeBrowserWindow = NO;
	}
	return YES;
}
@end


@implementation CMRAppDelegate(CMRLocalizableStringsOwner)
+ (NSString *)localizableStringsTableName
{
    return APP_MAINMENU_LOCALIZABLE_FILE_NAME;
}
@end
