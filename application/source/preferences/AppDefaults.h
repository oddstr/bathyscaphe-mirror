/**
  * $Id: AppDefaults.h,v 1.11 2005/07/09 13:14:03 tsawada2 Exp $
  * 
  * AppDefaults.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Foundation/Foundation.h>
#import "CocoMonar_Prefix.h"
#import <AppKit/NSNibDeclarations.h>



@protocol	w2chConnect;
@class		CMRBBSSignature;

/*!
 * @define      CMRPref
 * @discussion  グローバルな初期設定オブジェクト
 */
#define CMRPref		[AppDefaults sharedInstance]



/*** Preference's Value Proxy ***/
@interface CMRPreferenceValueProxy : NSProxy
{
	@private
	id		_preferences;
	id		_userData;
	SEL		_selector;
	id		_realObject;
}
- (id) initWithPreferences : (id) aPref;
- (void) setUserData:(id)anUserData querySelector:(SEL)aSelector;
@end



@interface AppDefaults : NSObject
{
	@private
	NSMutableDictionary		*m_backgroundColorDictionary;
	NSMutableDictionary		*m_threadsListDictionary;
	NSMutableDictionary		*m_threadViewerDictionary;
	NSMutableDictionary		*_dictAppearance;
	NSMutableDictionary		*_dictFilter;
	
	
	NSMutableDictionary		*_proxyCache;
	
	// 頻繁にアクセスされる可能性のある変数
	struct {
		unsigned int mailAttachmentShown:1;
		unsigned int mailAddressShown:1;
		unsigned int enableAntialias:1;
		unsigned int reserved:29;
	} PFlags;
}

+ (id) sharedInstance;
- (NSUserDefaults *) defaults;
- (void) postLayoutSettingsUpdateNotification;
/*** Preference's Value Proxy ***/
- (id) valueProxyForSelector : (SEL) aSelector
						 key : (id ) aKey;


- (BOOL) loadDefaults;
- (BOOL) saveDefaults;



- (BOOL) isOnlineMode;
- (void) setIsOnlineMode : (BOOL) flag;
- (IBAction) toggleOnlineMode : (id) sender;

- (BOOL) isSplitViewVertical;
- (void) setIsSplitViewVertical : (BOOL) flag;

// スレッドを削除するときに警告しない
- (BOOL) quietDeletion;
- (void) setQuietDeletion : (BOOL) flag;
// 外部リンクをバックグラウンドで開く
- (BOOL) openInBg;
- (void) setOpenInBg : (BOOL) flag;

/*** 書き込み：名前欄 ***/
- (NSString *) defaultReplyName;
- (void) setDefaultReplyName : (NSString *) name;
- (NSString *) defaultReplyMailAddress;
- (void) setDefaultReplyMailAddress : (NSString *) mail;
- (NSArray *) defaultKoteHanList;
- (void) setDefaultKoteHanList : (NSArray *) array;

/* 1.0.9.6 以前のお気に入りをインポートしたかどうか */
- (BOOL) isFavoritesImported;
- (void) setIsFavoritesImported : (BOOL) TorF;

/* 最後に開いた板 */
- (CMRBBSSignature *) browserLastBoard;
- (void) setBrowserLastBoard : (CMRBBSSignature *) aSignature;

#pragma mark ThreadsList

/* ソート */
- (NSString *) browserSortColumnIdentifier;
- (void) setBrowserSortColumnIdentifier : (NSString *) identifier;
- (BOOL) browserSortAscending;
- (void) setBrowserSortAscending : (BOOL) isAscending;
- (int) browserStatusFilteringMask;
- (void) setBrowserStatusFilteringMask : (int) mask;
- (BOOL) collectByNew;
- (void) setCollectByNew : (BOOL) flag;

/* Search option */
- (CMRSearchMask) threadSearchOption;
- (void) setThreadSearchOption : (CMRSearchMask) option;
- (CMRSearchMask) contentsSearchOption;
- (void) setContentsSearchOption : (CMRSearchMask) option;


// Proxy
- (BOOL) usesProxy;
- (void) setUsesProxy : (BOOL) anUsesProxy;
- (BOOL) usesProxyOnlyWhenPOST;
- (void) setUsesProxyOnlyWhenPOST : (BOOL) anUsesProxy;

- (BOOL) usesSystemConfigProxy;
- (void) setUsesSystemConfigProxy : (BOOL) flag;

- (void) getProxy:(NSString**)host port:(CFIndex*)port;
- (CFIndex) proxyPort;
- (void) setProxyPort : (CFIndex) aProxyPort;
- (NSString *) proxyHost;
- (void) setProxyHost : (NSString *) aProxyURL;

#pragma mark History

- (int) maxCountForThreadsHistory;
- (void) setMaxCountForThreadsHistory : (int) counts;
- (int) maxCountForBoardsHistory;
- (void) setMaxCountForBoardsHistory : (int) counts;
- (int) maxCountForSearchHistory;
- (void) setMaxCountForSearchHistory : (int) counts;
@end



@interface AppDefaults(BackgroundColors)
- (BOOL) browserSTableDrawsStriped;
- (void) setBrowserSTableDrawsStriped : (BOOL) flag;
- (NSColor *) browserSTableBackgroundColor;
- (void) setBrowserSTableBackgroundColor : (NSColor *) color;
- (BOOL) browserSTableDrawsBackground;
- (void) setBrowserSTableDrawsBackground : (BOOL) flag;
- (NSColor *) boardListBackgroundColor;
- (void) setBoardListBackgroundColor : (NSColor *) color;

- (NSColor *) threadViewerBackgroundColor;
- (void) setThreadViewerBackgroundColor : (NSColor *) color;
- (BOOL) threadViewerDrawsBackground;
- (void) setThreadViewerDrawsBackground : (BOOL) flag;
- (NSColor *) resPopUpBackgroundColor;
- (void) setResPopUpBackgroundColor : (NSColor *) color;
- (BOOL) isResPopUpSeeThrough;
- (void) setIsResPopUpSeeThrough : (BOOL) anIsResPopUpSeeThrough;

- (NSColor *) replyBackgroundColor;
- (void) setReplyBackgroundColor : (NSColor *) aColor;

- (void) _loadBackgroundColors;
- (BOOL) _saveBackgroundColors;
@end



@interface AppDefaults(Filter)
/*** 迷惑レスフィルタ***/
- (BOOL) spamFilterEnabled;
- (void) setSpamFilterEnabled : (BOOL) flag;

// 本文中の語句もチェックする
- (BOOL) usesSpamMessageCorpus;
- (void) setUsesSpamMessageCorpus : (BOOL) flag;

- (NSString *) spamMessageCorpusStringRepresentation;
- (void) setUpSpamMessageCorpusWithString : (NSString *) aString;


// 迷惑レスを見つけたときの動作：
enum {
	kSpamFilterChangeTextColorBehavior = 1,
	kSpamFilterLocalAbonedBehavior,
	kSpamFilterInvisibleAbonedBehavior
};

- (int) spamFilterBehavior;
- (void) setSpamFilterBehavior : (int) mask;

- (void) resetSpamFilter;

- (void) _loadFilter;
- (BOOL) _saveFilter;
@end



@interface AppDefaults(FontAndColor)
- (NSColor *) replyTextColor;
- (void) setReplyTextColor : (NSColor *) aColor;
- (NSFont *) replyFont;
- (void) setReplyFont : (NSFont *) aFont;

/*** ポップアップ ***/
// デフォルトの色
- (NSColor *) resPopUpDefaultTextColor;
- (void) setResPopUpDefaultTextColor : (NSColor *) color;
- (BOOL) isResPopUpTextDefaultColor;
- (void) setIsResPopUpTextDefaultColor : (BOOL) flag;

- (BOOL) popUpWindowVerticalScrollerIsSmall;
- (void) setPopUpWindowVerticalScrollerIsSmall : (BOOL) flag;


- (NSColor *) threadsListColor;
- (void) setThreadsListColor : (NSColor *) color;
- (NSFont *) threadsListFont;
- (void) setThreadsListFont : (NSFont *) aFont;
- (NSColor *) threadsListNewThreadColor;
- (void) setThreadsListNewThreadColor : (NSColor *) color;
- (NSFont *) threadsListNewThreadFont;
- (void) setThreadsListNewThreadFont : (NSFont *) aFont;

- (NSFont *) threadsViewFont;
- (void) setThreadsViewFont : (NSFont *) aFont;
- (NSColor *) threadsViewColor;
- (void) setThreadsViewColor : (NSColor *) color;

- (NSColor *) messageColor;
- (void) setMessageColor : (NSColor *) color;

- (NSFont *) messageFont;
- (void) setMessageFont : (NSFont *) font;

- (NSColor *) messageTitleColor;
- (void) setMessageTitleColor : (NSColor *) color;

- (NSFont *) messageTitleFont;
- (void) setMessageTitleFont : (NSFont *) font;

- (NSColor *) messageNameColor;
- (void) setMessageNameColor : (NSColor *) color;

- (NSFont *) messageAlternateFont;
- (void) setMessageAlternateFont : (NSFont *) font;

- (NSColor *) messageAnchorColor;
- (void) setMessageAnchorColor : (NSColor *) color;
- (NSColor *) messageFilteredColor;
- (void) setMessageFilteredColor : (NSColor *) color;
- (NSColor *) textEnhancedColor;
- (void) setTextEnhancedColor : (NSColor *) color;

- (NSFont *) messageHostFont;
- (void) setMessageHostFont : (NSFont *) aFont;

- (NSColor *) messageHostColor;
- (void) setMessageHostColor : (NSColor *) color;
- (NSFont *) messageBeProfileFont;
- (void) setMessageBeProfileFont : (NSFont *) aFont;

/* boardList font */
- (NSFont *) boardListFont;
- (void) setBoardListFont : (NSFont *) font;
- (NSColor *) boardListTextColor;
- (void) setBoardListTextColor : (NSColor *) color;


/* more options */
- (BOOL) hasMessageAnchorUnderline;
- (void) setHasMessageAnchorUnderline : (BOOL) flag;

- (BOOL) shouldThreadAntialias;
- (void) setShouldThreadAntialias : (BOOL) flag;

- (BOOL) threadsListDrawsGrid;
- (void) setThreadsListDrawsGrid : (BOOL) flag;

/* Row height, cell spacing */
- (float) messageHeadIndent;
- (void) setMessageHeadIndent : (float) anIndent;

- (float) threadsListRowHeight;
- (void) setThreadsListRowHeight : (float) rowHeight;
- (void) fixRowHeightToFontSize;

- (NSSize) threadsListIntercellSpacing;
- (void) setThreadsListIntercellSpacing : (NSSize) space;

- (void) setThreadsListRowHeightNum : (NSNumber *) rowHeight;
- (void) setThreadsListIntercellSpacingHeight : (NSNumber *) height;
- (void) setThreadsListIntercellSpacingWidth : (NSNumber *) width;

- (float) boardListRowHeight;
- (void) setBoardListRowHeight : (float) rowHeight;
- (void) fixBoardListRowHeightToFontSize;

- (void) _loadFontAndColor;
- (BOOL) _saveFontAndColor;
@end



@interface AppDefaults(ThreadsListSettings)
- (int) threadsListAutoscrollMask;
- (void) setThreadsListAutoscrollMask : (int) mask;
- (NSString *) ignoreTitleCharacters;
- (void) setIgnoreTitleCharacters : (NSString *) ignoreChars;

- (BOOL) useIncrementalSearch;
- (void) setUseIncrementalSearch : (BOOL) TorF;

- (void) _loadThreadsListSettings;
- (BOOL) _saveThreadsListSettings;
@end



@interface AppDefaults(ThreadViewerSettings)
/* スレッドをダウンロードしたときはすべて表示する */
- (BOOL) showsAllMessagesWhenDownloaded;
- (void) setShowsAllMessagesWhenDownloaded : (BOOL) flag;

/* オンザフライ読み込み */
- (unsigned) onTheFlyCompositionAttributes;
- (void) setOnTheFlyCompositionAttributes : (unsigned) value;

/* 「ウインドウの位置と領域を記憶」 */
- (NSString *) windowDefaultFrameString;
- (void) setWindowDefaultFrameString : (NSString *) aString;
- (NSString *) replyWindowDefaultFrameString;
- (void) setReplyWindowDefaultFrameString : (NSString *) aString;

- (int) threadViewerLinkType;
- (void) setThreadViewerLinkType : (int) aType;
- (int) threadViewerMailType;
- (void) setThreadViewerMailType : (int) aType;

- (BOOL) mailAttachmentShown;
- (void) setMailAttachmentShown : (BOOL) flag;
- (BOOL) mailAddressShown;
- (void) setMailAddressShown : (BOOL) flag;

- (int) openInBrowserType;
- (void) setOpenInBrowserType : (int) aType;

- (void) _loadThreadViewerSettings;
- (BOOL) _saveThreadViewerSettings;
@end



@interface AppDefaults(Account)
- (NSURL *) x2chAuthenticationRequestURL;
- (NSURL *) x2chRegistrationPageURL;
- (NSURL *) be2chRegistrationPageURL;
- (BOOL) shouldLoginIfNeeded;
- (void) setShouldLoginIfNeeded : (BOOL) flag;
- (BOOL) shouldLoginBe2chAnyTime;
- (void) setShouldLoginBe2chAnyTime : (BOOL) flag;

- (BOOL) hasAccountInKeychain;
- (void) setHasAccountInKeychain : (BOOL) usesKeychain;
- (NSString *) applicationUserAgent;
- (NSString *) x2chUserAccount;
- (void) setX2chUserAccount : (NSString *) account;
- (NSString *) be2chAccountMailAddress;
- (void) setBe2chAccountMailAddress : (NSString *) address;
- (NSString *) be2chAccountCode;
- (void) setBe2chAccountCode : (NSString *) code;
- (NSString *) password;
- (void) loadAccountSettings;
@end



@interface AppDefaults(ChangeAccount)
- (BOOL) changeAccount : (NSString *) newAccount
			  password : (NSString *) newPassword
		  usesKeychain : (BOOL      ) usesKeychain;
- (BOOL) deleteAccount;
@end



@interface AppDefaults(LibraryPath)
- (BOOL) createDirectoryAtPath : (NSString *) path;
- (BOOL) validatePathLength : (NSString *) filepath;
@end



@interface AppDefaults(BundleSupport)
- (NSBundle *) moduleWithName : (NSString *) bundleName
					   ofType : (NSString *) type
				  inDirectory : (NSString *) bundlePath;
- (id) _boardListEditor;
- (id) sharedBoardListEditor;
- (id) _preferencesPane;
- (id) sharedPreferencesPane;
- (id<w2chConnect>) w2chConnectWithURL : (NSURL        *) anURL
                            properties : (NSDictionary *) properties;

- (NSString *) helperAppPath;
- (void) setHelperAppPath : (NSString *) fullPath_;
- (NSString *) helperAppDisplayName;
@end



@interface AppDefaults(AlertPanel)
+ (NSString *) tableForPanels;
+ (NSString *) labelForDefaultButton;
+ (NSString *) labelForAlternateButton;
- (int) runDirectoryNotFoundAlertAndTerminateWithMessage : (NSString *) msg;
- (int) runAlertPanelWithLocalizedString : (NSString *) title
								 message : (NSString *) msg;
- (int) runCriticalAlertPanelWithLocalizedString : (NSString *) title
                                          message : (NSString *) msg;
@end

#pragma mark Constants

extern NSString *const AppDefaultsWillSaveNotification;
