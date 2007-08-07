/**
  * $Id: AppDefaults-ThreadViewer.m,v 1.9 2007/08/07 14:07:44 tsawada2 Exp $
  * 
  * AppDefaults-ThreadViewer.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "AppDefaults_p.h"

#import "CMRThreadVisibleRange.h"
#import "BSLinkDownloadManager.h"

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

@implementation AppDefaults(ThreadViewerSettings)
- (NSMutableDictionary *) threadViewerDefaultsDictionary
{
	if (nil == m_threadViewerDictionary) {
		NSDictionary	*dict_;
		
		dict_ = [[self defaults] dictionaryForKey : kPrefThreadViewerSettingsKey];
		m_threadViewerDictionary = [dict_ mutableCopy];
	}
	
	if (nil == m_threadViewerDictionary)
		m_threadViewerDictionary = [[NSMutableDictionary alloc] init];
	
	return m_threadViewerDictionary;
}

/* スレッドをダウンロードしたときはすべて表示する */
- (BOOL) showsAllMessagesWhenDownloaded
{
	return [[self threadViewerDefaultsDictionary] 
				boolForKey:kPrefShowsAllWhenDownloadedKey]; 
}
- (void) setShowsAllMessagesWhenDownloaded : (BOOL) flag
{
	[[self threadViewerDefaultsDictionary]
		setBool:flag forKey:kPrefShowsAllWhenDownloadedKey];
}

/* オンザフライ読み込み */
- (unsigned) onTheFlyCompositionAttributes
{
	return 0;
}
- (void) setOnTheFlyCompositionAttributes : (unsigned) value
{
}


/* 「ウインドウの位置と領域を記憶」 */
- (NSString *) windowDefaultFrameString
{
	return [[self threadViewerDefaultsDictionary]
				  stringForKey : kPrefThreadViewerWindowFrameKey];
}
- (void) setWindowDefaultFrameString : (NSString *) aString
{
	if (nil == aString) {
		[[self threadViewerDefaultsDictionary] 
			removeObjectForKey : kPrefThreadViewerWindowFrameKey];
	} else {
		[[self threadViewerDefaultsDictionary]
					  setObject :aString
					  forKey : kPrefThreadViewerWindowFrameKey];
	}
}
- (NSString *) replyWindowDefaultFrameString
{
	return [[self threadViewerDefaultsDictionary]
				  stringForKey : kPrefReplyWindowFrameKey];
}
- (void) setReplyWindowDefaultFrameString : (NSString *) aString
{
	if (nil == aString) {
		[[self threadViewerDefaultsDictionary] 
			removeObjectForKey : kPrefReplyWindowFrameKey];
	} else {
		[[self threadViewerDefaultsDictionary]
					  setObject :aString
					  forKey : kPrefReplyWindowFrameKey];
	}
}

- (int) threadViewerLinkType
{
	return [[self threadViewerDefaultsDictionary]
				  integerForKey : kPrefThreadViewerLinkTypeKey
				   defaultValue : DEFAULT_THREAD_VIEWER_LINK_TYPE];
}
- (void) setThreadViewerLinkType : (int) aType
{
	[[self threadViewerDefaultsDictionary]
			setInteger : aType
				forKey : kPrefThreadViewerLinkTypeKey];
}

// メールアドレス
- (BOOL) mailAttachmentShown
{
	return (PFlags.mailAttachmentShown != 0);
}
- (void) setMailAttachmentShown : (BOOL) flag
{
	[[self threadViewerDefaultsDictionary]
			   setBool : flag
				forKey : kPrefMailAttachmentShownKey];
	
	PFlags.mailAttachmentShown = flag ? 1 : 0;
}
- (BOOL) mailAddressShown
{
	return (PFlags.mailAddressShown != 0);
}
- (void) setMailAddressShown : (BOOL) flag
{
	[[self threadViewerDefaultsDictionary]
			   setBool : flag
				forKey : kPrefMailAddressShownKey];
	
	PFlags.mailAddressShown = flag ? 1 : 0;
}

- (int) openInBrowserType
{
	return [[self threadViewerDefaultsDictionary]
				  integerForKey : kPrefOpenInBrowserTypeKey
				   defaultValue : DEFAULT_OPEN_IN_BROWSER_TYPE];
}
- (void) setOpenInBrowserType : (int) aType
{
	[[self threadViewerDefaultsDictionary]
			setInteger : aType
				forKey : kPrefOpenInBrowserTypeKey];
}

#pragma mark SledgeHammer Additions
- (BOOL) showsPoofAnimationOnInvisibleAbone
{
	// Terminal などから変更しやすいように、このエントリはトップレベルに作る
	return [[self defaults] boolForKey : kPrefShowsPoofAnimationKey
						  defaultValue : DEFAULT_SHOWS_POOF_ON_ABONE];
}

- (void) setShowsPoofAnimationOnInvisibleAbone : (BOOL) showsPoof;
{
	[[self defaults] setBool : showsPoof
					  forKey : kPrefShowsPoofAnimationKey];
}

#pragma mark ShortCircuit Additions
- (void) _resetDefaultVisibleRange
{
	[CMRThreadVisibleRange setDefaultVisibleRange :
				[CMRThreadVisibleRange visibleRangeWithFirstVisibleLength : [self firstVisibleCount]
														lastVisibleLength : [self lastVisibleCount]]];
}

- (unsigned int) firstVisibleCount
{
	return [[self threadViewerDefaultsDictionary] unsignedIntForKey : kPrefFirstVisibleKey
													   defaultValue : DEFAULT_TV_FIRST_VISIBLE];
}

- (void) setFirstVisibleCount : (unsigned int) aValue
{
	[[self threadViewerDefaultsDictionary] setUnsignedInt : aValue
												   forKey : kPrefFirstVisibleKey];
	[self _resetDefaultVisibleRange];
}

- (unsigned int) lastVisibleCount
{
	return [[self threadViewerDefaultsDictionary] unsignedIntForKey : kPrefLastVisibleKey
													   defaultValue : DEFAULT_TV_LAST_VISIBLE];
}
- (void) setLastVisibleCount : (unsigned int) aValue;
{
	[[self threadViewerDefaultsDictionary] setUnsignedInt : aValue
												   forKey : kPrefLastVisibleKey];
	[self _resetDefaultVisibleRange];
}

#pragma mark SecondFlight Additions
- (BOOL) previewLinkWithNoModifierKey
{
	return [[self defaults] boolForKey : kPrefPreviewLinkDirectlyKey
						  defaultValue : DEFAULT_TV_PREVIEW_WITH_NO_MODIFIER];
}

- (void) setPreviewLinkWithNoModifierKey : (BOOL) previewDirectly
{
	[[self defaults] setBool : previewDirectly
					  forKey : kPrefPreviewLinkDirectlyKey];
}

#pragma mark InnocentStarter Additions
- (float) mouseDownTrackingTime
{
	return [[self threadViewerDefaultsDictionary] floatForKey : kPrefTrackingTimeKey
												 defaultValue : DEFAULT_TV_MOUSEDOWN_TIME];
}
- (void) setMouseDownTrackingTime : (float) aValue
{
	[[self threadViewerDefaultsDictionary] setFloat : aValue forKey : kPrefTrackingTimeKey];
}

#pragma mark Vita Additions
- (BOOL) scrollToLastUpdated
{
	return [[self threadViewerDefaultsDictionary] boolForKey : kPrefScroll2LUKey
												defaultValue : DEFAULT_TV_SCROLL_TO_NEW];
}
- (void) setScrollToLastUpdated : (BOOL) flag
{
	[[self threadViewerDefaultsDictionary] setBool : flag forKey : kPrefScroll2LUKey];
}

#pragma mark Twincam Angel Additions
- (NSString *)linkDownloaderDestination
{
	BOOL	isDir;
	NSString *path = [[self threadViewerDefaultsDictionary] stringForKey:kPrefLinkDownloaderDestKey];
	if (path && [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir) {
		return path;
	} else {
		return [[CMRFileManager defaultManager] userDomainDesktopFolderPath];
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

#pragma mark -
- (void) _loadThreadViewerSettings
{
	BOOL	flag_;
	
	flag_ = [[self threadViewerDefaultsDictionary]
				     boolForKey : kPrefMailAttachmentShownKey
				   defaultValue : kPreferencesDefault_MailAttachmentShown];
	[self setMailAttachmentShown : flag_];
	flag_ = [[self threadViewerDefaultsDictionary]
				     boolForKey : kPrefMailAddressShownKey
				   defaultValue : kPreferencesDefault_MailAddressShown];
	[self setMailAddressShown : flag_];

}
- (BOOL) _saveThreadViewerSettings
{
	NSDictionary			*dict_;
	
	dict_ = [self threadViewerDefaultsDictionary];
	
	UTILAssertNotNil(dict_);
	[[self defaults] setObject : dict_
						forKey : kPrefThreadViewerSettingsKey];
	[[BSLinkDownloadManager defaultManager] writeToFileNow];
	return YES;
}
@end
