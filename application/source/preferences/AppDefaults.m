/**
  * $Id: AppDefaults.m,v 1.12.2.1 2006/06/08 18:33:08 tsawada2 Exp $
  * 
  * AppDefaults.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "AppDefaults_p.h"
#import "CMRMainMenuManager.h"
#import "BoardList.h"
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

#define AppDefaultsIsFavImportedKey			@"Old Favorites Imported"

#define AppDefaultsOpenInBgKey				@"OpenLinkInBg"
#define AppDefaultsQuietDeletionKey			@"QuietDeletion"

#define	AppDefaultsInformDatOchiKey			@"InformWhenDatOchi"

// History
#define AppDefaultsHistoryThreadsKey		@"ThreadHistoryItemLimit"
#define AppDefaultsHistoryBoardsKey			@"BoardHistoryItemLimit"
#define AppDefaultsHistorySearchKey			@"RecentSearchItemLimit"

// Proxy
#define AppDefaultsUsesProxyKey				@"UsesProxy"
#define AppDefaultsUsesSystemConfigProxy	@"UsesSystemConfigProxy"
#define AppDefaultsProxyURLKey				@"ProxyURL"
#define AppDefaultsProxyPortKey				@"ProxyPort"

static id _singletonAppDefaultsLock;

#pragma mark -

@implementation AppDefaults
+ (void) initialize
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
}
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
	NSArray	*kote_;
	
    kote_ = [[self defaults] stringArrayForKey : AppDefaultsDefaultKoteHanListKey];
	return kote_;
}
- (void) setDefaultKoteHanList : (NSArray *) array
{
	if (nil == array) {
		[[self defaults] removeObjectForKey : AppDefaultsDefaultKoteHanListKey];
		return;
	}
	[[self defaults] setObject : array
						forKey : AppDefaultsDefaultKoteHanListKey];
}

/*#pragma mark -

- (BOOL) isFavoritesImported
{
	return [[self defaults] 
				boolForKey : AppDefaultsIsFavImportedKey
			  defaultValue : DEFAULT_FAVORITES_IMPORTED];
}

- (void) setIsFavoritesImported : (BOOL) TorF
{
	[[self defaults] setBool : TorF
					  forKey : AppDefaultsIsFavImportedKey];
}*/
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

#pragma mark -

// Proxy
- (BOOL) usesSystemConfigProxy
{
	return [[self defaults] boolForKey : AppDefaultsUsesSystemConfigProxy
						  defaultValue : NO];
}
- (void) setUsesSystemConfigProxy : (BOOL) flag
{
	[[self defaults] setBool:flag forKey:AppDefaultsUsesSystemConfigProxy];
}


enum {
	kDisableProxy = 0,
	kEnableProxy = 1,
	kEnableProxyOnlyWhenPOST = 2,
	kEnableProxyReserved = 4
};

- (int) usesProxyStatus
{
	return [[self defaults] integerForKey : AppDefaultsUsesProxyKey];
}
- (void) setUsesProxyStatus : (int) status
{
	[[self defaults] setInteger:status forKey:AppDefaultsUsesProxyKey];
}
- (BOOL) usesProxyWithStatus : (int) flag
{
	int		s;
	s = [self usesProxyStatus];
	return (s & flag);
}
- (void) setUsesProxyStatus : (int) flag
					 flagOn : (BOOL) flagOn
{
	int		s;
	
	s = [self usesProxyStatus];
	[self setUsesProxyStatus : (flagOn ? s | flag : s & ~flag)];
}
- (BOOL) usesProxy { return [self usesProxyWithStatus : kEnableProxy]; }
- (void) setUsesProxy : (BOOL) flag { [self setUsesProxyStatus:kEnableProxy flagOn:flag]; }
- (BOOL) usesProxyOnlyWhenPOST { return [self usesProxyWithStatus : kEnableProxyOnlyWhenPOST]; }
- (void) setUsesProxyOnlyWhenPOST : (BOOL) flag { [self setUsesProxyStatus:kEnableProxyOnlyWhenPOST flagOn:flag]; }


/*
Function
----------------------------------------
SCDynamicStoreCopyProxies

Constants
----------------------------------------
kSCPropNetProxiesHTTPEnable
kSCPropNetProxiesHTTPProxy
kSCPropNetProxiesHTTPPort

*/
static struct {
	CFDictionaryRef (*copyProxies)(void *);
	CFStringRef	proxyKey;
	CFStringRef	portKey;
} localSCProxyInfo = { NULL, NULL, false};

static CFURLRef CopySystemConfigurationURL(void)
{
	return CFURLCreateWithFileSystemPath(NULL, 
		CFSTR("/System/Library/Frameworks/SystemConfiguration.framework"),
		kCFURLPOSIXPathStyle,
		true);
}
static Boolean localSCProxyInfoInit(void)
{
	static Boolean		isFirst  = true;
	static CFBundleRef	scBundle = NULL;
	
	Boolean				ret       = false;
	CFURLRef			bundleURL = NULL;
	CFStringRef			*sym;
	CFDictionaryRef		(*fnCopyProxies)(void *);
	
	if (false == isFirst) {
		return localSCProxyInfo.copyProxies != NULL;
	}
	isFirst = false;
	
	bundleURL = CopySystemConfigurationURL();
	UTILRequireCondition(bundleURL, ErrLocalSCProxyInfoInit);
	
	if (NULL == bundleURL) return 2;
	scBundle = CFBundleCreate(NULL, bundleURL);
	UTILDebugRequire1(scBundle, ErrLocalSCProxyInfoInit,
		@"Can't create bundle for %@",
		[(NSURL*)bundleURL description]);
	if (false == CFBundleLoadExecutable(scBundle)) {
		NSLog(@"***WARNING*** Can't load executable code from %@",
			[(NSURL*)bundleURL description]);
		CFRelease(scBundle);
		scBundle = NULL;
		goto ErrLocalSCProxyInfoInit;
	}
	
	sym = (CFStringRef*)CFBundleGetDataPointerForName(scBundle,
					CFSTR("kSCPropNetProxiesHTTPProxy"));
	UTILRequireCondition(sym, ErrLocalSCProxyInfoInit);
	UTILDebugWrite1(@"  load symbol %@", (NSString*)*sym);
	localSCProxyInfo.proxyKey = *sym;
	
	sym = (CFStringRef*)CFBundleGetDataPointerForName(scBundle,
					CFSTR("kSCPropNetProxiesHTTPPort"));
	UTILRequireCondition(sym, ErrLocalSCProxyInfoInit);
	UTILDebugWrite1(@"  load symbol %@", (NSString*)*sym);
	localSCProxyInfo.portKey = *sym;
	
	fnCopyProxies = CFBundleGetFunctionPointerForName(scBundle,
						CFSTR("SCDynamicStoreCopyProxies"));
	UTILRequireCondition(fnCopyProxies, ErrLocalSCProxyInfoInit);
	UTILDebugWrite1(@"  load Function %@", @"SCDynamicStoreCopyProxies");
	localSCProxyInfo.copyProxies = fnCopyProxies;
	
	ret = true;
ErrLocalSCProxyInfoInit:
	if (bundleURL != NULL) CFRelease(bundleURL);
	return ret;
}

static Boolean GetHTTPProxySetting(NSString **host, CFIndex *port)
{
	Boolean			ret = false;
	NSDictionary	*proxyDict;
	NSString		*hostStr;
	NSNumber		*portNum;
	
	if (host != NULL) *host = nil;
	if (port != NULL) *port = 0;
	
	if (false == localSCProxyInfoInit()) {
		return false;
	}
	NSCAssert(
		localSCProxyInfo.copyProxies &&
		localSCProxyInfo.proxyKey &&
		localSCProxyInfo.portKey,
		@"localSCProxyInfo was not initialized.");
		
	
	proxyDict = (NSDictionary*)localSCProxyInfo.copyProxies(NULL);
	UTILDebugRequire(proxyDict && [proxyDict isKindOfClass : [NSDictionary class]],
		ErrGetHTTPProxySetting,
		@"SCDynamicStoreCopyProxies() returns NULL");
	[proxyDict autorelease];
	
	hostStr = [proxyDict objectForKey : (NSString*)localSCProxyInfo.proxyKey];
	UTILDebugRequire1(hostStr && [hostStr isKindOfClass : [NSString class]],
		ErrGetHTTPProxySetting,
		@"No Entry: %@", localSCProxyInfo.proxyKey);
	
	portNum = [proxyDict objectForKey : (NSString*)localSCProxyInfo.portKey];
	UTILDebugRequire1(portNum && [portNum isKindOfClass : [NSNumber class]],
		ErrGetHTTPProxySetting,
		@"No Entry: %@", localSCProxyInfo.portKey);
	
	if (host != NULL) *host = hostStr;
	if (port != NULL) *port = [portNum intValue];
	
	
	ret = true;
ErrGetHTTPProxySetting:
	return ret;
}
- (void) getProxy:(NSString**)host port:(CFIndex*)port
{
	if ([self usesSystemConfigProxy]) {
		if (GetHTTPProxySetting(host, port))
			return;
		
		// IGNORE if SystemConfiguration.framework was not supported
	}
	if (host != NULL)
		*host = [[self defaults] stringForKey : AppDefaultsProxyURLKey];
	
	if (port != NULL) {
		*port = [[self defaults] integerForKey : AppDefaultsProxyPortKey
								  defaultValue : 8080];
	}
}

- (CFIndex) proxyPort
{
	CFIndex		port;
	
	[self getProxy:NULL port:&port];
	return port;
}
- (void) setProxyPort : (CFIndex) aProxyPort
{
	[[self defaults] setInteger:aProxyPort forKey:AppDefaultsProxyPortKey];
}
- (NSString *) proxyHost
{
	NSString		*host;
	
	[self getProxy:&host port:NULL];
	return host;
}
- (void) setProxyHost : (NSString *) aHost
{
	if (nil == aHost)
		[[self defaults] removeObjectForKey:AppDefaultsProxyURLKey];
	else
		[[self defaults] setObject:aHost forKey:AppDefaultsProxyURLKey];
}

#pragma mark -

// History
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
