/**
  * $Id: AppDefaults-ThreadViewer.m,v 1.1 2005/05/11 17:51:06 tsawada2 Exp $
  * 
  * AppDefaults-ThreadViewer.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "AppDefaults_p.h"



#define kPrefThreadViewerWindowFrameKey		@"Default Window Frame"
#define kPrefReplyWindowFrameKey			@"Default Reply Window Frame"
#define kPrefThreadViewerSettingsKey		@"Preferences - ThreadViewerSettings"
#define kPrefThreadViewerLinkTypeKey		@"Message Link Setting"
#define kPrefThreadViewerMailtoLinkTypeKey	@"Mailto Link Setting"
#define kPrefMailAddressShownKey			@"mail Address Shown"
#define kPrefMailAttachmentShownKey			@"Mail Icon Shown"
#define kPrefOpenInBrowserTypeKey			@"Open In Browser Setting"
#define kPrefShowsAllWhenDownloadedKey		@"ShowsAllWhenDownloaded"



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

//メールアドレスの処理方法
- (int) threadViewerMailType
{
	//メール欄を表示しているときはメールソフトを起動。
	//表示していなければポップアップ
	return [self mailAddressShown] ? ThreadViewerOpenBrowserLinkType
								   : ThreadViewerResPopUpLinkType;
}
- (void) setThreadViewerMailType : (int) aType
{

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
	return YES;
}
@end
