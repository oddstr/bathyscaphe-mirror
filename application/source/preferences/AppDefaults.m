/**
  * $Id: AppDefaults.m,v 1.27 2007/10/31 20:54:23 tsawada2 Exp $
  * 
  * AppDefaults.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "AppDefaults_p.h"
#import "TS2SoftwareUpdate.h"

NSString *const AppDefaultsWillSaveNotification = @"AppDefaultsWillSaveNotification";
NSString *const AppDefaultsThreadViewThemeDidChangeNotification = @"AppDefaultsThreadViewThemeDidChangeNotification";


#define AppDefaultsDefaultReplyNameKey		    @"Reply Name"
#define AppDefaultsDefaultKoteHanListKey	    @"ReplyNameList"
#define AppDefaultsDefaultReplyMailKey		    @"Reply Mail"
#define AppDefaultsIsOnlineModeKey		        @"Online Mode ON"
#define AppDefaultsThreadSearchOptionKey		@"Thread Search Option" // Deprecated in Starlight Breaker.
#define AppDefaultsContentsSearchOptionKey		@"Contents Search Option"
static NSString *const AppDefaultsFindPanelExpandedKey = @"Find Panel Expanded";
static NSString *const AppDefaultsContentsSearchTargetKey = @"Contents Search Targets";

#define AppDefaultsBrowserSplitViewIsVerticalKey		@"Browser SplitView isVertical"
#define AppDefaultsBrowserLastBoardKey					@"LastBoard"
#define AppDefaultsBrowserSortColumnIdentifierKey		@"ThreadSortKey"
#define AppDefaultsListCollectByNewKey					@"CollectByNewKey"
#define AppDefaultsBrowserSortAscendingKey				@"ThreadSortAscending"
#define AppDefaultsBrowserStatusFilteringMaskKey		@"StatusFilteringMask"

#define AppDefaultsIsFavImportedKey			@"Old Favorites Updated" // Deprecated in Starlight Breaker.
#define AppDefaultsOldMsgScrlBehvrKey		@"OldScrollingBehavior"

#define AppDefaultsOpenInBgKey				@"OpenLinkInBg"
#define AppDefaultsQuietDeletionKey			@"QuietDeletion"

#define	AppDefaultsInformDatOchiKey			@"InformWhenDatOchi"
//#define AppDefaultsMoveFocusKey				@"MoveFocusToViewerWhenShowThreadAtRow"

// History
#define AppDefaultsHistoryThreadsKey		@"ThreadHistoryItemLimit"
#define AppDefaultsHistoryBoardsKey			@"BoardHistoryItemLimit"
#define AppDefaultsHistorySearchKey			@"RecentSearchItemLimit"

// Proxy (Deprecated)
#define AppDefaultsProxyURLKey				@"ProxyURL"
#define AppDefaultsProxyPortKey				@"ProxyPort"

static NSString *const AppDefaultsUseCustomThemeKey = @"Use Custom ThreadViewTheme";
static NSString *const AppDefaultsThemeFileNameKey = @"ThreadViewTheme FileName";
static NSString *const AppDefaultsDefaultThemeFileNameKey = @"ThreadViewerDefaultTheme"; // + ".plist"

#pragma mark -

@implementation AppDefaults
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedInstance);

- (id) init
{
	if (self = [super init]) {
		NSNotificationCenter *center_;
		center_ = [NSNotificationCenter defaultCenter];
		
		[center_ addObserver : self
					selector : @selector(applicationWillTerminateNotified:)
					    name : NSApplicationWillTerminateNotification
					  object : NSApp];
		
		[self loadDefaults];
	}
	return self;
}
- (void) dealloc
{
	[m_backgroundColorDictionary release];
	[m_threadsListDictionary release];
	[m_threadViewerDictionary release];
	[m_imagePreviewerDictionary release];
	[_dictAppearance release];
	[m_soundsDictionary release];
	[m_boardWarriorDictionary release];
	[m_threadViewTheme release];
	[super dealloc];
}

- (NSUserDefaults *) defaults
{
	return [NSUserDefaults standardUserDefaults];
}
- (void) postLayoutSettingsUpdateNotification
{
	UTILNotifyName(AppDefaultsLayoutSettingsUpdatedNotification);
}

- (void) cleanUpDeprecatedKeyAndValues
{
	NSUserDefaults *defaults_ = [self defaults];
	// threadSearchOption
	if ([defaults_ integerForKey: AppDefaultsThreadSearchOptionKey]) {
		[defaults_ removeObjectForKey: AppDefaultsThreadSearchOptionKey];
		NSLog(@"Unused key %@ removed.", AppDefaultsThreadSearchOptionKey);
	}
	// oldFavoritesUpdated
	if ([defaults_ boolForKey: AppDefaultsIsFavImportedKey]) {
		[defaults_ removeObjectForKey: AppDefaultsIsFavImportedKey];
		NSLog(@"Unused key %@ removed.", AppDefaultsIsFavImportedKey);
	}
	// proxy
	if ([defaults_ boolForKey: @"UsesBSsOwnProxySettings"]) {
		[defaults_ removeObjectForKey: @"UsesBSsOwnProxySettings"];
		NSLog(@"Unused key UsesBSsOwnProxySettings removed.");
	}
	if ([defaults_ stringForKey: AppDefaultsProxyURLKey]) {
		[defaults_ removeObjectForKey: AppDefaultsProxyURLKey];
		NSLog(@"Unused key %@ removed.", AppDefaultsProxyURLKey);
	}
	if ([defaults_ integerForKey: AppDefaultsProxyPortKey]) {
		[defaults_ removeObjectForKey: AppDefaultsProxyPortKey];
		NSLog(@"Unused key %@ removed.", AppDefaultsProxyPortKey);
	}	
}

- (void) loadThreadViewTheme
{
	NSString *themeFileName = [self themeFileName];
	NSString *finalFilePath = nil;
	if (!themeFileName) {
		if ([self usesCustomTheme] && [[NSFileManager defaultManager] fileExistsAtPath: [self customThemeFilePath]]) {
			finalFilePath = [self customThemeFilePath];
		}
	} else {
		if ([[NSFileManager defaultManager] fileExistsAtPath: [self createFullPathFromThemeFileName: themeFileName]]) {
			finalFilePath = [self createFullPathFromThemeFileName: themeFileName];
		}
	}
	if (!finalFilePath) {
		finalFilePath = [[NSBundle mainBundle] pathForResource: AppDefaultsDefaultThemeFileNameKey ofType: @"plist"];
	}

	BSThreadViewTheme *defaultTheme = [[BSThreadViewTheme alloc] initWithContentsOfFile: finalFilePath];
	[self setThreadViewTheme: defaultTheme];
	[defaultTheme release];
}

- (BOOL) loadDefaults
{
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool: YES], TS2SoftwareUpdateCheckKey,
							[NSNumber numberWithUnsignedInt: TS2SUCheckWeekly], TS2SoftwareUpdateCheckIntervalKey,
							[NSNumber numberWithBool: NO], AppDefaultsUseCustomThemeKey,
							[NSNumber numberWithBool: NO], AppDefaultsOldFontsAndColorsConvertedKey, NULL];
	[[self defaults] registerDefaults: dict];

	if (NO == [[self defaults] boolForKey: AppDefaultsOldFontsAndColorsConvertedKey])
		[self convertOldFCToThemeFile];

	[self loadThreadViewTheme];

	[self cleanUpDeprecatedKeyAndValues];

	[self _loadBackgroundColors];
	[self _loadFontAndColor];
	[self _loadFilter];
	[self _loadThreadsListSettings];
	[self _loadThreadViewerSettings];
	[self _loadImagePreviewerSettings];
	[self loadAccountSettings];
	[self _loadSoundsSettings];
	[self _loadBWSettings];
	
	return YES;
}
- (BOOL) saveDefaults
{
	BOOL	syncResult = NO;
	
	UTILNotifyName(AppDefaultsWillSaveNotification);

NS_DURING
	
	[self _saveBackgroundColors];
	[self _saveFontAndColor];
	[self _saveThreadsListSettings];
	[self _saveThreadViewerSettings];
	[self _saveImagePreviewerSettings];
	[self _saveFilter];
	[self _saveSoundsSettings];
	[self _saveBWSettings];

	syncResult = [[self defaults] synchronize];
	
NS_HANDLER
	
	NSLog(
		@"***EXCEPTION*** in %@:\n%@",
		self,
		[localException description]);
	
NS_ENDHANDLER
	
	return syncResult;
}

- (void) applicationWillTerminateNotified : (NSNotification *) notification
{
	UTILAssertNotificationName(
		notification,
		NSApplicationWillTerminateNotification);
	UTILAssertNotificationObject(
		notification,
		NSApp);
	
	[self saveDefaults];
}

#pragma mark General

- (BOOL) isOnlineMode
{
	return [[self defaults] 
				boolForKey : AppDefaultsIsOnlineModeKey
			  defaultValue : kPreferencesDefault_OnlineMode];
}
- (void) setIsOnlineMode : (BOOL) flag
{
	[[self defaults] setBool : flag
					  forKey : AppDefaultsIsOnlineModeKey];
//	[[CMRMainMenuManager defaultManager] synchronizeIsOnlineModeMenuItemState];
}
- (IBAction) toggleOnlineMode : (id) sender
{
	[self setIsOnlineMode : (NO == [self isOnlineMode])];
}


- (BOOL) isSplitViewVertical;
{
	return [[self defaults] 
				boolForKey : AppDefaultsBrowserSplitViewIsVerticalKey
			  defaultValue : DEFAULT_IS_BROWSER_VERTICAL];
}
- (void) setIsSplitViewVertical : (BOOL) flag
{
	[[self defaults] setBool : flag
					  forKey : AppDefaultsBrowserSplitViewIsVerticalKey];
}
// スレッドを削除するときに警告しない
- (BOOL) quietDeletion
{
    return [[self defaults]
				boolForKey : AppDefaultsQuietDeletionKey
			  defaultValue : NO];
}

- (void) setQuietDeletion : (BOOL) flag
{
	[[self defaults] setBool : flag
					  forKey : AppDefaultsQuietDeletionKey];
}

- (BOOL) openInBg
{
	return [[self defaults]
				boolForKey : AppDefaultsOpenInBgKey
			  defaultValue : NO];
}

- (void) setOpenInBg : (BOOL) flag
{
	[[self defaults] setBool : flag
					  forKey : AppDefaultsOpenInBgKey];
}

#pragma mark Search Options
- (CMRSearchMask) contentsSearchOption
{
	return [[self defaults] integerForKey : AppDefaultsContentsSearchOptionKey
						defaultValue : DEFAULT_CONTENTS_SEARCH_OPTION];
}
- (void) setContentsSearchOption : (CMRSearchMask) option
{
	[[self defaults] setInteger : option
						 forKey : AppDefaultsContentsSearchOptionKey];
}

- (BOOL) findPanelExpanded
{
	return [[self defaults] boolForKey: AppDefaultsFindPanelExpandedKey defaultValue: DEFAULT_SEARCH_PANEL_EXPANDED];
}

- (void) setFindPanelExpanded: (BOOL) isExpanded
{
	[[self defaults] setBool: isExpanded forKey: AppDefaultsFindPanelExpandedKey];
}

- (NSArray *) contentsSearchTargetArray
{
	NSArray *array = [[self defaults] arrayForKey: AppDefaultsContentsSearchTargetKey];
	if (nil == array) {
		NSNumber *tmp = [NSNumber numberWithInt: NSOnState];
		array = [NSArray arrayWithObjects: tmp, tmp, tmp, tmp, tmp, nil];
	}
	return array;
}

- (void) setContentsSearchTargetArray: (NSArray *) array
{
	[[self defaults] setObject: array forKey: AppDefaultsContentsSearchTargetKey];
}

#pragma mark Reply

/*** 書き込み：名前欄 ***/
- (NSString *) defaultReplyName
{
	NSString		*name_;
	
	name_ = [[self defaults] stringForKey : AppDefaultsDefaultReplyNameKey];
	
	return name_ ? name_ : @"";
}

- (void) setDefaultReplyName : (NSString *) name
{
	if (nil == name) {
		[[self defaults] removeObjectForKey : AppDefaultsDefaultReplyNameKey];
		return;
	}
	[[self defaults] setObject : name
						forKey : AppDefaultsDefaultReplyNameKey];
}
- (NSString *) defaultReplyMailAddress;
{
	NSString		*mail_;
	
	mail_ = [[self defaults] stringForKey : AppDefaultsDefaultReplyMailKey];
	return mail_ ? mail_ : @"";
}
- (void) setDefaultReplyMailAddress : (NSString *) mail;
{
	if (nil == mail) {
		[[self defaults] removeObjectForKey : AppDefaultsDefaultReplyMailKey];
		return;
	}
	[[self defaults] setObject : mail
						forKey : AppDefaultsDefaultReplyMailKey];
}
- (NSArray *) defaultKoteHanList
{
    return [[self defaults] stringArrayForKey : AppDefaultsDefaultKoteHanListKey];
}

- (void) setDefaultKoteHanList : (NSArray *) anArray
{
	if (nil == anArray) {
		[[self defaults] removeObjectForKey: AppDefaultsDefaultKoteHanListKey];
	} else {
		[[self defaults] setObject: anArray forKey: AppDefaultsDefaultKoteHanListKey];
	}
}

#pragma mark Software Update Support
- (BOOL) autoCheckForUpdate
{
	return [[self defaults] boolForKey: TS2SoftwareUpdateCheckKey];
}
- (void) setAutoCheckForUpdate: (BOOL) autoCheck
{
	[[self defaults] setBool: autoCheck forKey: TS2SoftwareUpdateCheckKey];
}
- (int) softwareUpdateCheckInterval
{
	return [[self defaults] integerForKey: TS2SoftwareUpdateCheckIntervalKey];
}
- (void) setSoftwareUpdateCheckInterval: (int) type
{
	[[self defaults] setInteger: type forKey: TS2SoftwareUpdateCheckIntervalKey];
}

#pragma mark Browser
- (NSString *) browserLastBoard
{
	NSString			*rep_;
	rep_ = [[self defaults] objectForKey : AppDefaultsBrowserLastBoardKey];

	UTILRequireCondition(rep_, default_browserLastBoard);
	return rep_;
	
default_browserLastBoard:
	return CMXFavoritesDirectoryName;
}

- (void) setBrowserLastBoard : (NSString *) boardName
{
	if (nil == boardName) {
		[[self defaults] removeObjectForKey : AppDefaultsBrowserLastBoardKey];
		return;
	}
	[[self defaults] setObject : boardName
						forKey : AppDefaultsBrowserLastBoardKey];
}

- (NSString *) browserSortColumnIdentifier
{
	NSString	*key_;
	
	key_ = [[self defaults] stringForKey : AppDefaultsBrowserSortColumnIdentifierKey];
	if (nil == key_) return CMRThreadStatusKey;

	return key_;
}
- (void) setBrowserSortColumnIdentifier : (NSString *) identifier
{
	if (nil == identifier) {
		[[self defaults] removeObjectForKey : AppDefaultsBrowserSortColumnIdentifierKey];
		return;
	}
	[[self defaults] setObject:identifier forKey:AppDefaultsBrowserSortColumnIdentifierKey];
}


- (BOOL) browserSortAscending
{
	return [[self defaults] boolForKey : AppDefaultsBrowserSortAscendingKey
						  defaultValue : DEFAULT_BROWSER_SORT_ASCENDING];
}
- (void) setBrowserSortAscending : (BOOL) isAscending
{
	[[self defaults] setBool:isAscending forKey:AppDefaultsBrowserSortAscendingKey];
}

- (BOOL) collectByNew
{
	return [[self defaults] boolForKey : AppDefaultsListCollectByNewKey
						  defaultValue : YES];
}
- (void) setCollectByNew : (BOOL) flag
{
	[[self defaults] setBool:flag forKey:AppDefaultsListCollectByNewKey];
}


- (int) browserStatusFilteringMask
{
		return [[self defaults] integerForKey : AppDefaultsBrowserStatusFilteringMaskKey
								 defaultValue : DEFAULT_BROWSER_STATUS_FILTERINGMAS];
}
- (void) setBrowserStatusFilteringMask : (int) mask
{
	[[self defaults] setInteger:mask forKey:AppDefaultsBrowserStatusFilteringMaskKey];
}

#pragma mark Hidden Options
- (int) maxCountForThreadsHistory
{
	return [[self defaults] integerForKey : AppDefaultsHistoryThreadsKey
							 defaultValue : DEFAULT_MAX_FOR_THREADS_HISTORY];
}
- (void) setMaxCountForThreadsHistory : (int) counts
{
	[[self defaults] setInteger : counts forKey : AppDefaultsHistoryThreadsKey];
}
- (int) maxCountForBoardsHistory
{
	return [[self defaults] integerForKey : AppDefaultsHistoryBoardsKey
							 defaultValue : DEFAULT_MAX_FOR_BOARDS_HISTORY];
}
- (void) setMaxCountForBoardsHistory : (int) counts
{
	[[self defaults] setInteger : counts forKey : AppDefaultsHistoryBoardsKey];
}
- (int) maxCountForSearchHistory
{
	return [[self defaults] integerForKey : AppDefaultsHistorySearchKey
							 defaultValue : DEFAULT_MAX_FOR_SEARCH_HISTORY];
}
- (void) setMaxCountForSearchHistory : (int) counts
{
	[[self defaults] setInteger : counts forKey : AppDefaultsHistorySearchKey];
}

- (BOOL) informWhenDetectDatOchi
{
	return [[self defaults] boolForKey: AppDefaultsInformDatOchiKey defaultValue: DEFAULT_INFORM_WHEN_DAT_OCHI];
}
- (void) setInformWhenDetectDatOchi: (BOOL) shouldInform
{
	[[self defaults] setBool: shouldInform forKey: AppDefaultsInformDatOchiKey];
}

- (BOOL) oldMessageScrollingBehavior
{
	return [[self defaults] boolForKey: AppDefaultsOldMsgScrlBehvrKey defaultValue: DEFAULT_OLD_SCROLLING];
}

- (void) setOldMessageScrollingBehavior: (BOOL) flag
{
	[[self defaults] setBool: flag forKey: AppDefaultsOldMsgScrlBehvrKey];
}

- (BOOL) saveThreadDocAsBinaryPlist
{
	return [[self defaults] boolForKey : @"UseBinaryFormat" defaultValue : DEFAULT_USE_BINARY_FORMAT];
}

/*#pragma mark MeteorSweeper Addition
- (BOOL) moveFocusToViewerWhenShowThreadAtRow
{
	return [[self defaults] boolForKey: AppDefaultsMoveFocusKey defaultValue: YES];
}
- (void) setMoveFocusToViewerWhenShowThreadAtRow: (BOOL) shouldMove
{
	[[self defaults] setBool: shouldMove forKey: AppDefaultsMoveFocusKey];
}*/

- (BOOL)disablesHistorySegCtrlMenu
{
	return [[self defaults] boolForKey:@"DisablesHistoryButtonPopupMenu" defaultValue:DEFAULT_HISTORY_SEGCTRL_MENU];
}
@end

@implementation AppDefaults(ThreadViewTheme)
- (BSThreadViewTheme *) threadViewTheme
{
	return m_threadViewTheme;
}
- (void) setThreadViewTheme: (BSThreadViewTheme *) aTheme
{
//	NSLog(@"setThreadViewTheme: called");
	[aTheme retain];
	[m_threadViewTheme release];
	m_threadViewTheme = aTheme;
	UTILNotifyName(AppDefaultsThreadViewThemeDidChangeNotification);
}

- (NSString *) customThemeFilePath
{
	NSString *dirPath = [[[CMRFileManager defaultManager] supportDirectoryWithName : BSThemesDirectory] filepath];
	return [dirPath stringByAppendingPathComponent: @"CustomTheme.plist"];
}
- (NSString *) createFullPathFromThemeFileName: (NSString *) fileName
{
	NSString *dirPath = [[[CMRFileManager defaultManager] supportDirectoryWithName : BSThemesDirectory] filepath];
	return [dirPath stringByAppendingPathComponent: fileName];
}

- (NSString *) themeFileName
{
	return [[self defaults] stringForKey: AppDefaultsThemeFileNameKey]; // may be nil.
}
- (void) setThemeFileName: (NSString *) fileName
{
	NSString *filePath;
//	NSLog(@"setThemeFileName: called");
	if (fileName == nil) {
		[[self defaults] removeObjectForKey: AppDefaultsThemeFileNameKey];
		filePath = ([self usesCustomTheme]) ? [self customThemeFilePath]
											: [[NSBundle mainBundle] pathForResource: AppDefaultsDefaultThemeFileNameKey ofType: @"plist"];
	} else {
		[[self defaults] setObject: fileName forKey: AppDefaultsThemeFileNameKey];
		filePath = [self createFullPathFromThemeFileName: fileName];
	}
	BSThreadViewTheme *theme = [[BSThreadViewTheme alloc] initWithContentsOfFile: filePath];
	[self setThreadViewTheme: theme];
	[theme release];
}

- (BOOL) usesCustomTheme
{
	return [[self defaults] boolForKey: AppDefaultsUseCustomThemeKey]; // default is NO.
}
- (void) setUsesCustomTheme: (BOOL) use
{
	[[self defaults] setBool: use forKey: AppDefaultsUseCustomThemeKey];
}

- (NSArray *) installedThemes
{
	NSString *themeDir = [[[CMRFileManager defaultManager] supportDirectoryWithName: BSThemesDirectory] filepath];
	NSMutableArray *tmp = [NSMutableArray array];

	if (themeDir) {
		NSDirectoryEnumerator *tmpEnum = [[NSFileManager defaultManager] enumeratorAtPath : themeDir];
		NSString *file, *fullpath;

		while (file = [tmpEnum nextObject]) {
			if ([[file pathExtension] isEqualToString: @"plist"]) {
				fullpath = [themeDir stringByAppendingPathComponent: file];
				BSThreadViewTheme *theme = [[BSThreadViewTheme alloc] initWithContentsOfFile: fullpath];
				if (!theme) continue;

				NSString *id_ = [theme identifier];
				if ([id_ isEqualToString: kThreadViewThemeCustomThemeIdentifier]) continue;

				[tmp addObject: [NSDictionary dictionaryWithObjectsAndKeys: file, @"FileName", id_, @"Identifier", NULL]];
				[theme release];
			}
		}
	}
	return (NSArray *)tmp;
}
@end
