/**
  * $Id: AppDefaults.m,v 1.16 2007/01/07 17:04:23 masakih Exp $
  * 
  * AppDefaults.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "AppDefaults_p.h"
#import "CMRMainMenuManager.h"
#import <AppKit/NSFont.h>


NSString *const AppDefaultsWillSaveNotification = @"AppDefaultsWillSaveNotification";


#define AppDefaultsDefaultReplyNameKey		    @"Reply Name"
#define AppDefaultsDefaultKoteHanListKey	    @"ReplyNameList"
#define AppDefaultsDefaultReplyMailKey		    @"Reply Mail"
#define AppDefaultsIsOnlineModeKey		        @"Online Mode ON"
#define AppDefaultsThreadSearchOptionKey		@"Thread Search Option"
#define AppDefaultsContentsSearchOptionKey		@"Contents Search Option"

#define AppDefaultsBrowserSplitViewIsVerticalKey		@"Browser SplitView isVertical"
#define AppDefaultsBrowserLastBoardKey					@"LastBoard"
#define AppDefaultsBrowserSortColumnIdentifierKey		@"ThreadSortKey"
#define AppDefaultsListCollectByNewKey					@"CollectByNewKey"
#define AppDefaultsBrowserSortAscendingKey				@"ThreadSortAscending"
#define AppDefaultsBrowserStatusFilteringMaskKey		@"StatusFilteringMask"

#define AppDefaultsIsFavImportedKey			@"Old Favorites Updated"
#define AppDefaultsOldMsgScrlBehvrKey		@"OldScrollingBehavior"

#define AppDefaultsOpenInBgKey				@"OpenLinkInBg"
#define AppDefaultsQuietDeletionKey			@"QuietDeletion"

#define	AppDefaultsInformDatOchiKey			@"InformWhenDatOchi"
#define AppDefaultsMoveFocusKey				@"MoveFocusToViewerWhenShowThreadAtRow"

// History
#define AppDefaultsHistoryThreadsKey		@"ThreadHistoryItemLimit"
#define AppDefaultsHistoryBoardsKey			@"BoardHistoryItemLimit"
#define AppDefaultsHistorySearchKey			@"RecentSearchItemLimit"

// Proxy
//#define AppDefaultsUsesProxyKey				@"UsesProxy"
//#define AppDefaultsUsesSystemConfigProxy	@"UsesSystemConfigProxy"
#define AppDefaultsProxyURLKey				@"ProxyURL"
#define AppDefaultsProxyPortKey				@"ProxyPort"

//static id _singletonAppDefaultsLock;

#pragma mark -

@implementation AppDefaults
/*+ (void) initialize
{
	static BOOL nomore_ = NO;
	if (nomore_) return;
	nomore_ = YES;
	_singletonAppDefaultsLock = [[NSLock alloc] init];
}

+ (id) sharedInstance
{
	static id instance_;
	
	if (nil == instance_) {
		[_singletonAppDefaultsLock lock];
		if (nil == instance_) {
			instance_ = [[[self class] alloc] init];
		}
		[_singletonAppDefaultsLock unlock];
	}
	return instance_;
}*/
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
	[_proxyCache release];
	[m_soundsDictionary release];
	[m_boardWarriorDictionary release];
	
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


- (BOOL) loadDefaults
{
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

/*** Preference's Value Proxy ***/
- (id) valueProxyForSelector : (SEL) aSelector
						 key : (id ) aKey
{
	id	proxy;
	
	if (nil == aKey || NULL == aSelector) 
		return nil;
	
	if (nil == _proxyCache) 
		_proxyCache = [[NSMutableDictionary alloc] init];
	
	proxy = [_proxyCache objectForKey : aKey];
	if (nil == proxy) {
		proxy = [[CMRPreferenceValueProxy alloc] initWithPreferences : self];
		[proxy setUserData:aKey querySelector:aSelector];
		
		[_proxyCache setObject:proxy forKey:aKey];
	}
	return proxy;
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

#pragma mark -

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
	[[CMRMainMenuManager defaultManager] synchronizeIsOnlineModeMenuItemState];
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

#pragma mark -

/* Search option */
- (CMRSearchMask) threadSearchOption
{
	return [[self defaults] integerForKey : AppDefaultsThreadSearchOptionKey
						defaultValue : CMRSearchOptionCaseInsensitive];
}
- (void) setThreadSearchOption : (CMRSearchMask) option
{
	[[self defaults] setInteger : option
						 forKey : AppDefaultsThreadSearchOptionKey];
}
- (CMRSearchMask) contentsSearchOption
{
	return [[self defaults] integerForKey : AppDefaultsContentsSearchOptionKey
						defaultValue : CMRSearchOptionCaseInsensitive];
}
- (void) setContentsSearchOption : (CMRSearchMask) option
{
	[[self defaults] setInteger : option
						 forKey : AppDefaultsContentsSearchOptionKey];
}

#pragma mark -

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

#pragma mark -

- (BOOL) oldFavoritesUpdated
{
	return [[self defaults] 
				boolForKey : AppDefaultsIsFavImportedKey
			  defaultValue : NO];
}

- (void) setOldFavoritesUpdated: (BOOL) flag
{
	[[self defaults] setBool : flag
					  forKey : AppDefaultsIsFavImportedKey];
}

- (BOOL) oldMessageScrollingBehavior
{
	return [[self defaults] boolForKey: AppDefaultsOldMsgScrlBehvrKey defaultValue: NO];
}

- (void) setOldMessageScrollingBehavior: (BOOL) flag
{
	[[self defaults] setBool: flag forKey: AppDefaultsOldMsgScrlBehvrKey];
}
/*#pragma mark DANGER
- (BOOL) saveThreadListAsBinaryPlist
{
	return [[self defaults] boolForKey : @"Use_Binary_Format_For_List" defaultValue : NO];
}
- (BOOL) saveThreadDocAsBinaryPlist
{
	return [[self defaults] boolForKey : @"Use_Binary_Format_For_Doc" defaultValue : NO];
}*/

#pragma mark -

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

#pragma mark Proxy
- (BOOL) usesOwnProxy
{
	return [[self defaults] boolForKey: @"UsesBSsOwnProxySettings" defaultValue: NO];
}

- (void) getOwnProxy: (NSString **)host port:(CFIndex *)port
{
	if (host != NULL)
		*host = [[self defaults] stringForKey: AppDefaultsProxyURLKey];
	
	if (port != NULL) {
		*port = [[self defaults] integerForKey: AppDefaultsProxyPortKey
								  defaultValue: 8080];
	}
}

#pragma mark History
- (int) maxCountForThreadsHistory
{
	return [[self defaults] integerForKey : AppDefaultsHistoryThreadsKey
							 defaultValue : 20];
}
- (void) setMaxCountForThreadsHistory : (int) counts
{
	[[self defaults] setInteger : counts forKey : AppDefaultsHistoryThreadsKey];
}
- (int) maxCountForBoardsHistory
{
	return [[self defaults] integerForKey : AppDefaultsHistoryBoardsKey
							 defaultValue : 10];
}
- (void) setMaxCountForBoardsHistory : (int) counts
{
	[[self defaults] setInteger : counts forKey : AppDefaultsHistoryBoardsKey];
}
- (int) maxCountForSearchHistory
{
	return [[self defaults] integerForKey : AppDefaultsHistorySearchKey
							 defaultValue : 10];
}
- (void) setMaxCountForSearchHistory : (int) counts
{
	[[self defaults] setInteger : counts forKey : AppDefaultsHistorySearchKey];
}
#pragma mark CometBlaster Addition
- (BOOL) informWhenDetectDatOchi
{
	return [[self defaults] boolForKey: AppDefaultsInformDatOchiKey defaultValue: YES];
}
- (void) setInformWhenDetectDatOchi: (BOOL) shouldInform
{
	[[self defaults] setBool: shouldInform forKey: AppDefaultsInformDatOchiKey];
}
#pragma mark MeteorSweeper Addition
- (BOOL) moveFocusToViewerWhenShowThreadAtRow
{
	return [[self defaults] boolForKey: AppDefaultsMoveFocusKey defaultValue: YES];
}
- (void) setMoveFocusToViewerWhenShowThreadAtRow: (BOOL) shouldMove
{
	[[self defaults] setBool: shouldMove forKey: AppDefaultsMoveFocusKey];
}
@end

#pragma mark -

@implementation CMRPreferenceValueProxy
- (id) initWithPreferences : (id) aPref
{
	NSNotificationCenter *nc;
	
	_preferences = aPref;
	nc = [NSNotificationCenter defaultCenter];
	
	[nc addObserver : self
		   selector : @selector(appDefaultsLayoutSettingsUpdated:)
			   name : AppDefaultsLayoutSettingsUpdatedNotification
			 object : _preferences];
	
	return self;
}
- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_preferences = nil;
	
	[_userData release];
	[_realObject release];
	[super dealloc];
}
- (void) appDefaultsLayoutSettingsUpdated : (NSNotification *) theNotification
{
	UTILAssertNotificationObject(
		theNotification,
		_preferences);
	UTILAssertNotificationName(
		theNotification,
		AppDefaultsLayoutSettingsUpdatedNotification);
	
	[_realObject autorelease];
	_realObject = nil;
	
}
- (void) setUserData:(id)anUserData querySelector:(SEL)aSelector
{
	UTILAssertNotNilArgument(anUserData, @"UserData");
	UTILAssertNotNilArgument(aSelector, @"querySelector");
	UTILAssertNotNil(_preferences);
	
	[_userData autorelease];
	_userData = [anUserData retain];
	_selector = aSelector;
}
- (id) realObject
{
	if (nil == _realObject) {
		id		tmp = _realObject;
		
		_realObject = [_preferences performSelector:_selector withObject:_userData];
		[_realObject retain];
		[tmp release];
	}
		
	return _realObject;
}
- self { return [self realObject]; }
- (Class) class { return [[self realObject] class]; }

/* needs for NSFont!! */

- (CGFontRef) _backingCGSFont
{
	return [[self realObject] _backingCGSFont];
}
- (ATSUFontID) _atsFontID
{
	return [[self realObject] _atsFontID];
}

- (NSMethodSignature *) methodSignatureForSelector : (SEL) aSelector
{
    return [[self realObject] methodSignatureForSelector:aSelector];
}
- (void) forwardInvocation : (NSInvocation *) anInvocation
{
	[anInvocation setTarget:[self realObject]];
	[anInvocation invoke];
	return;
}
@end
