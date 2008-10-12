//
// AppDefaults-ThreadsViewer.m
// BathyScaphe
//
// Updated by Tsutomu Sawada on 08/09/28.
// Copyright 2005-2008 BathyScaphe Project. All rights reserved.
// encoding="UTF-8"
//

#import "AppDefaults_p.h"

#import "CMRThreadVisibleRange.h"
#import "BSLinkDownloadManager.h"
#import "BSBeSAAPAnchorComposer.h"

#define kPrefThreadViewerWindowFrameKey		@"Default Window Frame"
#define kPrefReplyWindowFrameKey			@"Default Reply Window Frame"
#define kPrefThreadViewerSettingsKey		@"Preferences - ThreadViewerSettings"
#define kPrefThreadViewerLinkTypeKey		@"Message Link Setting"
#define kPrefMailAddressShownKey			@"mail Address Shown"
#define kPrefMailAttachmentShownKey			@"Mail Icon Shown"
#define kPrefOpenInBrowserTypeKey			@"Open In Browser Setting"
#define kPrefShowsAllWhenDownloadedKey		@"ShowsAllWhenDownloaded"
#define kPrefShowsPoofAnimationKey			@"ShowsPoofOnInvisibleAbone"
#define kPrefPreviewLinkDirectlyKey			@"InvertPreviewerLinks"

static NSString *const kPrefFirstVisibleKey	= @"FirstVisible";
static NSString *const kPrefLastVisibleKey	= @"LastVisible";
static NSString *const kPrefTrackingTimeKey = @"Mousedown Tracking Time";

static NSString *const kPrefScroll2LUKey = @"ScrollToLastUpdatedHeader";

static NSString *const kPrefLinkDownloaderDestKey = @"LinkDownloaderDestination";
static NSString *const kPrefLinkDownloaderCommentKey = @"LinkDownloaderAttachURLToComment";

static NSString *const kTVAutoReloadWhenWakeKey = @"Reload When Wake (Viewer)";
static NSString *const kTVDefaultVisibleRangeKey = @"VisibleRange";
static NSString *const kPrefSAAPIconShownKey = @"SAAP Icon Shown";

@implementation AppDefaults(ThreadViewerSettings)
- (NSMutableDictionary *)threadViewerDefaultsDictionary
{
	if (!m_threadViewerDictionary) {
		NSDictionary	*dict_;
		
		dict_ = [[self defaults] dictionaryForKey:kPrefThreadViewerSettingsKey];
		m_threadViewerDictionary = [dict_ mutableCopy];
	}
	
	if (!m_threadViewerDictionary) {
		m_threadViewerDictionary = [[NSMutableDictionary alloc] init];
	}
	return m_threadViewerDictionary;
}

/* スレッドをダウンロードしたときはすべて表示する */
- (BOOL)showsAllMessagesWhenDownloaded
{
	return [[self threadViewerDefaultsDictionary] boolForKey:kPrefShowsAllWhenDownloadedKey defaultValue:DEFAULT_TV_SHOWS_ALL_WHEN_DOWNLOADED];
}

- (void)setShowsAllMessagesWhenDownloaded:(BOOL)flag
{
	[[self threadViewerDefaultsDictionary] setBool:flag forKey:kPrefShowsAllWhenDownloadedKey];
}

/* 「ウインドウの位置と領域を記憶」 */
- (NSString *)windowDefaultFrameString
{
	return [[self threadViewerDefaultsDictionary] stringForKey:kPrefThreadViewerWindowFrameKey];
}

- (void)setWindowDefaultFrameString:(NSString *)aString
{
	if (!aString) {
		[[self threadViewerDefaultsDictionary] removeObjectForKey:kPrefThreadViewerWindowFrameKey];
	} else {
		[[self threadViewerDefaultsDictionary] setObject:aString forKey:kPrefThreadViewerWindowFrameKey];
	}
}

- (NSString *)replyWindowDefaultFrameString
{
	return [[self threadViewerDefaultsDictionary] stringForKey:kPrefReplyWindowFrameKey];
}

- (void)setReplyWindowDefaultFrameString:(NSString *)aString
{
	if (!aString) {
		[[self threadViewerDefaultsDictionary] removeObjectForKey:kPrefReplyWindowFrameKey];
	} else {
		[[self threadViewerDefaultsDictionary] setObject:aString forKey:kPrefReplyWindowFrameKey];
	}
}

- (int)threadViewerLinkType
{
	return [[self threadViewerDefaultsDictionary] integerForKey:kPrefThreadViewerLinkTypeKey defaultValue:DEFAULT_THREAD_VIEWER_LINK_TYPE];
}

- (void)setThreadViewerLinkType:(int)aType
{
	[[self threadViewerDefaultsDictionary] setInteger:aType forKey:kPrefThreadViewerLinkTypeKey];
}

// メールアドレス
- (BOOL)mailAttachmentShown
{
	return (PFlags.mailAttachmentShown != 0);
}

- (void)setMailAttachmentShown:(BOOL)flag
{
	[[self threadViewerDefaultsDictionary] setBool:flag forKey:kPrefMailAttachmentShownKey];
	
	PFlags.mailAttachmentShown = flag ? 1 : 0;
}

- (BOOL)mailAddressShown
{
	return (PFlags.mailAddressShown != 0);
}

- (void)setMailAddressShown:(BOOL)flag
{
	[[self threadViewerDefaultsDictionary] setBool:flag forKey:kPrefMailAddressShownKey];
	
	PFlags.mailAddressShown = flag ? 1 : 0;
}

- (int)openInBrowserType
{
	return [[self threadViewerDefaultsDictionary] integerForKey:kPrefOpenInBrowserTypeKey defaultValue:DEFAULT_OPEN_IN_BROWSER_TYPE];
}

- (void)setOpenInBrowserType:(int)aType
{
	[[self threadViewerDefaultsDictionary] setInteger:aType forKey:kPrefOpenInBrowserTypeKey];
}

- (BOOL)showsPoofAnimationOnInvisibleAbone
{
	// Terminal などから変更しやすいように、このエントリはトップレベルに作る
	return [[self defaults] boolForKey:kPrefShowsPoofAnimationKey defaultValue:DEFAULT_SHOWS_POOF_ON_ABONE];
}

- (void)setShowsPoofAnimationOnInvisibleAbone:(BOOL)showsPoof
{
	[[self defaults] setBool:showsPoof forKey:kPrefShowsPoofAnimationKey];
}

- (CMRThreadVisibleRange *)defaultVisibleRange
{
	if (!m_defaultVisibleRange) {
		m_defaultVisibleRange = [[CMRThreadVisibleRange alloc] initWithFirstVisibleLength:DEFAULT_TV_FIRST_VISIBLE
																		lastVisibleLength:DEFAULT_TV_LAST_VISIBLE];
	}
	return m_defaultVisibleRange;
}

- (unsigned int)firstVisibleCount
{
	return [m_defaultVisibleRange firstVisibleLength];
}

- (void)setFirstVisibleCount:(unsigned int)aValue
{
	[m_defaultVisibleRange setFirstVisibleLength:aValue];
}

- (unsigned int)lastVisibleCount
{
	return [m_defaultVisibleRange lastVisibleLength];
}

- (void)setLastVisibleCount:(unsigned int)aValue
{
	[m_defaultVisibleRange setLastVisibleLength:aValue];
}

- (BOOL)previewLinkWithNoModifierKey
{
	return [[self defaults] boolForKey:kPrefPreviewLinkDirectlyKey defaultValue:DEFAULT_TV_PREVIEW_WITH_NO_MODIFIER];
}

- (void)setPreviewLinkWithNoModifierKey:(BOOL)previewDirectly
{
	[[self defaults] setBool:previewDirectly forKey:kPrefPreviewLinkDirectlyKey];
}

- (float)mouseDownTrackingTime
{
	return [[self threadViewerDefaultsDictionary] floatForKey:kPrefTrackingTimeKey defaultValue:DEFAULT_TV_MOUSEDOWN_TIME];
}

- (void)setMouseDownTrackingTime:(float)aValue
{
	[[self threadViewerDefaultsDictionary] setFloat:aValue forKey:kPrefTrackingTimeKey];
}

- (BOOL)scrollToLastUpdated
{
	return [[self threadViewerDefaultsDictionary] boolForKey:kPrefScroll2LUKey defaultValue:DEFAULT_TV_SCROLL_TO_NEW];
}

- (void)setScrollToLastUpdated:(BOOL)flag
{
	[[self threadViewerDefaultsDictionary] setBool:flag forKey:kPrefScroll2LUKey];
}

#pragma mark Link Downloader
- (NSString *)linkDownloaderDestination
{
	BOOL	isDir;
	NSString *path = [[self threadViewerDefaultsDictionary] stringForKey:kPrefLinkDownloaderDestKey];
	if (path && [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir) {
		return path;
	} else {
		return [[CMRFileManager defaultManager] userDomainDownloadsFolderPath];
	}
}

- (void)setLinkDownloaderDestination:(NSString *)path
{
	[[self threadViewerDefaultsDictionary] setObject:path forKey:kPrefLinkDownloaderDestKey];
}

- (NSMutableArray *)linkDownloaderDictArray
{
	return [[BSLinkDownloadManager defaultManager] downloadableTypes];
}

- (void)setLinkDownloaderDictArray:(NSMutableArray *)array
{
	[[BSLinkDownloadManager defaultManager] setDownloadableTypes:array];
}

- (NSArray *)linkDownloaderExtensionTypes
{
	return [[self linkDownloaderDictArray] valueForKey:@"extension"];
}

- (NSArray *)linkDownloaderAutoopenTypes
{
	return [[self linkDownloaderDictArray] valueForKey:@"autoopen"];
}

- (BOOL)linkDownloaderAttachURLToComment
{
	return [[self threadViewerDefaultsDictionary] boolForKey:kPrefLinkDownloaderCommentKey defaultValue:DEFAULT_LINK_DOWNLOADER_ATTACH_COMMENT];
}

- (void)setLinkDownloaderAttachURLToComment:(BOOL)flag
{
	[[self threadViewerDefaultsDictionary] setBool:flag forKey:kPrefLinkDownloaderCommentKey];
}

#pragma mark SilverGull Additions
- (BOOL)autoReloadViewerWhenWake
{
	return [[self threadViewerDefaultsDictionary] boolForKey:kTVAutoReloadWhenWakeKey defaultValue:DEFAULT_TV_AUTORELOAD_WHEN_WAKE];
}

- (void)setAutoReloadViewerWhenWake:(BOOL)flag
{
	[[self threadViewerDefaultsDictionary] setBool:flag forKey:kTVAutoReloadWhenWakeKey];
}

#pragma mark Tenori Tiger Additions
- (BOOL)showsSAAPIcon
{
	return [[self threadViewerDefaultsDictionary] boolForKey:kPrefSAAPIconShownKey defaultValue:DEFAULT_TV_SAAP_ICON_SHOWN];
}

- (void)setShowsSAAPIcon:(BOOL)flag
{
	[[self threadViewerDefaultsDictionary] setBool:flag forKey:kPrefSAAPIconShownKey];
	[BSBeSAAPAnchorComposer setShowsSAAPIcon:flag];
}

#pragma mark -
- (void)_loadThreadViewerSettings
{
	NSMutableDictionary *dict_ = [self threadViewerDefaultsDictionary];
	BOOL	flag_;
	
	flag_ = [dict_ boolForKey:kPrefMailAttachmentShownKey defaultValue:kPreferencesDefault_MailAttachmentShown];
	[self setMailAttachmentShown:flag_];
	flag_ = [dict_ boolForKey:kPrefMailAddressShownKey defaultValue:kPreferencesDefault_MailAddressShown];
	[self setMailAddressShown:flag_];

	id plist = [dict_ objectForKey:kTVDefaultVisibleRangeKey];
	if (plist) {
		CMRThreadVisibleRange *tmp = [[CMRThreadVisibleRange alloc] initWithPropertyListRepresentation:plist];
		if (tmp) {
			m_defaultVisibleRange = tmp;
			// Clean-up deprecated keys if needed
			[dict_ removeObjectsForKeys:[NSArray arrayWithObjects:kPrefFirstVisibleKey, kPrefLastVisibleKey, nil]];
		}
	} else {
		unsigned int first = [dict_ unsignedIntForKey:kPrefFirstVisibleKey defaultValue:DEFAULT_TV_FIRST_VISIBLE];
		unsigned int last = [dict_ unsignedIntForKey:kPrefLastVisibleKey defaultValue:DEFAULT_TV_LAST_VISIBLE];
		m_defaultVisibleRange = [[CMRThreadVisibleRange alloc] initWithFirstVisibleLength:first lastVisibleLength:last];
	}
}

- (BOOL)_saveThreadViewerSettings
{
	NSMutableDictionary			*dict_;
	dict_ = [self threadViewerDefaultsDictionary];
	UTILAssertNotNil(dict_);

	id plistRep = [m_defaultVisibleRange propertyListRepresentation];
	if (plistRep) {
		[dict_ setObject:plistRep forKey:kTVDefaultVisibleRangeKey];
	}

	[[self defaults] setObject:dict_ forKey:kPrefThreadViewerSettingsKey];

	[[BSLinkDownloadManager defaultManager] writeToFileNow];
	return YES;
}
@end
