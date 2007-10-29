/**
  * $Id: AppDefaults.h,v 1.53 2007/10/29 05:54:46 tsawada2 Exp $
  * 
  * AppDefaults.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Foundation/Foundation.h>
#import "CocoMonar_Prefix.h"
#import <AppKit/NSNibDeclarations.h>

#import "BSImagePreviewerInterface.h"

@protocol w2chConnect, w2chAuthenticationStatus;
@class BSThreadViewTheme;
/*!
 * @define      CMRPref
 * @discussion  グローバルな初期設定オブジェクト
 */
#define CMRPref		[AppDefaults sharedInstance]

typedef enum _BSAutoSyncIntervalType {
	BSAutoSyncByWeek	= 1,
	BSAutoSyncBy2weeks	= 2,
	BSAutoSyncByMonth	= 3,
	BSAutoSyncByEveryStartUp = 11,
	BSAutoSyncEveryDay	= 12, // available in ReinforceII and later.
} BSAutoSyncIntervalType;

@interface AppDefaults : NSObject
{
	@private
	NSMutableDictionary		*m_backgroundColorDictionary;
	NSMutableDictionary		*m_threadsListDictionary;
	NSMutableDictionary		*m_threadViewerDictionary;
	NSMutableDictionary		*m_imagePreviewerDictionary;
	NSMutableDictionary		*_dictAppearance;
	NSMutableDictionary		*_dictFilter;
	NSMutableDictionary		*m_soundsDictionary;
	NSMutableDictionary		*m_boardWarriorDictionary;
	BSThreadViewTheme		*m_threadViewTheme;
	
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

- (BOOL) loadDefaults;
- (BOOL) saveDefaults;

// バイナリ形式でログを保存
- (BOOL) saveThreadDocAsBinaryPlist;

- (BOOL)disablesHistorySegCtrlMenu; // 暫定

- (BOOL) isOnlineMode;
- (void) setIsOnlineMode : (BOOL) flag;
//- (IBAction) toggleOnlineMode : (id) sender;

- (BOOL) isSplitViewVertical;
- (void) setIsSplitViewVertical : (BOOL) flag;

// スレッドを削除するときに警告しない
- (BOOL) quietDeletion;
- (void) setQuietDeletion : (BOOL) flag;
// 外部リンクをバックグラウンドで開く
- (BOOL) openInBg;
- (void) setOpenInBg : (BOOL) flag;

/* Reply Name & Mail */
- (NSString *) defaultReplyName;
- (void) setDefaultReplyName : (NSString *) name;
- (NSString *) defaultReplyMailAddress;
- (void) setDefaultReplyMailAddress : (NSString *) mail;
- (NSArray *) defaultKoteHanList;
- (void) setDefaultKoteHanList : (NSArray *) anArray;

/* Last Shown Board */
- (NSString *) browserLastBoard;
- (void) setBrowserLastBoard : (NSString *) boardName;

/* CometBlaster Additions */
- (BOOL) informWhenDetectDatOchi;
- (void) setInformWhenDetectDatOchi: (BOOL) shouldInform;

/* MeteorSweeper Additions */
//- (BOOL) moveFocusToViewerWhenShowThreadAtRow;
//- (void) setMoveFocusToViewerWhenShowThreadAtRow: (BOOL) shouldMove;

/* ReinforceII Hidden Option */
- (BOOL) oldMessageScrollingBehavior;
- (void) setOldMessageScrollingBehavior: (BOOL) flag;

#pragma mark ThreadsList Sorting
/* Sort */
- (NSString *) browserSortColumnIdentifier;
- (void) setBrowserSortColumnIdentifier : (NSString *) identifier;
- (BOOL) browserSortAscending;
- (void) setBrowserSortAscending : (BOOL) isAscending;
- (int) browserStatusFilteringMask;
- (void) setBrowserStatusFilteringMask : (int) mask;
- (BOOL) collectByNew;
- (void) setCollectByNew : (BOOL) flag;

#pragma mark Contents Search
/* Search option */
- (CMRSearchMask) contentsSearchOption;
- (void) setContentsSearchOption : (CMRSearchMask) option;

/* Starlight Breaker Additions */
- (BOOL) findPanelExpanded;
- (void) setFindPanelExpanded: (BOOL) isExpanded;
- (NSArray *) contentsSearchTargetArray;
- (void) setContentsSearchTargetArray: (NSArray *) array;

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
- (NSColor *) boardListBackgroundColor;
- (void) setBoardListBackgroundColor : (NSColor *) color;
- (NSColor *)boardListNonActiveBgColor;

- (NSColor *) threadViewerBackgroundColor;
- (NSColor *) replyBackgroundColor;

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

- (NSMutableArray *)spamMessageCorpus;
- (void)setSpamMessageCorpus:(NSMutableArray *)mutableArray;

- (BOOL)oldNGWordsImported;
- (void)setOldNGWordsImported:(BOOL)imported;

// 迷惑レスを見つけたときの動作：
- (int) spamFilterBehavior;
- (void) setSpamFilterBehavior : (int) mask;

- (void) resetSpamFilter;
- (void)setSpamFilterNeedsSaveToFiles:(BOOL)flag;

// AAD(Ascii Art Detector). Available in MeteorSweeper and later.
- (BOOL) asciiArtDetectorEnabled;
- (void) setAsciiArtDetectorEnabled: (BOOL) flag;

- (void) _loadFilter;
- (BOOL) _saveFilter;
@end



@interface AppDefaults(FontAndColor)
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
/* Available in Twincam Angel. */
- (NSFont *)threadsListDatOchiThreadFont;
- (void)setThreadsListDatOchiThreadFont:(NSFont *)aFont;
- (NSColor *)threadsListDatOchiThreadColor;
- (void)setThreadsListDatOchiThreadColor:(NSColor *)color;

- (NSColor *) messageFilteredColor;
- (void) setMessageFilteredColor : (NSColor *) color;
- (NSColor *) textEnhancedColor;
- (void) setTextEnhancedColor : (NSColor *) color;

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

/* SledgeHammer Addition */
- (float) msgIdxSpacingBefore;
- (void) setMsgIdxSpacingBefore : (float) aValue;
- (float) msgIdxSpacingAfter;
- (void) setMsgIdxSpacingAfter : (float) aValue;

- (float) threadsListRowHeight;
- (void) setThreadsListRowHeight : (float) rowHeight;
- (void) fixRowHeightToFontSize;

- (float) boardListRowHeight;
- (void) setBoardListRowHeight : (float) rowHeight;
- (void) fixBoardListRowHeightToFontSize;

- (NSDictionary *) boardListTextAttributes; // Available in Starlight Breaker.

- (void) _loadFontAndColor;
- (BOOL) _saveFontAndColor;
@end

@interface AppDefaults(ThreadsListSettings)
- (int) threadsListAutoscrollMask;
- (void) setThreadsListAutoscrollMask : (int) mask;

- (BOOL) useIncrementalSearch;
- (void) setUseIncrementalSearch : (BOOL) TorF;

/* ShortCircuit Additions */
- (id) threadsListTableColumnState;
- (void) setThreadsListTableColumnState : (id) aColumnState;

/* InnocentStarter Additions */
- (BOOL) autoReloadListWhenWake;
- (void) setAutoReloadListWhenWake : (BOOL) doReload;

/* RainbowJerk Additions */
- (NSDate *) lastHEADCheckedDate;
- (void) setLastHEADCheckedDate : (NSDate *) date;
- (BOOL) canHEADCheck;

/* GrafEisen Additions */
- (NSTimeInterval) HEADCheckTimeInterval;
- (void) setHEADCheckTimeInterval : (NSTimeInterval) interval;
- (NSDate *) nextHEADCheckAvailableDate;

/* Twincam Angel Additions */
- (BSThreadsListViewModeType)threadsListViewMode;
- (void)setThreadsListViewMode:(BSThreadsListViewModeType)type;

- (void) _loadThreadsListSettings;
- (BOOL) _saveThreadsListSettings;
@end

@interface AppDefaults(ThreadViewTheme)
- (BSThreadViewTheme *) threadViewTheme;
- (void) setThreadViewTheme: (BSThreadViewTheme *) aTheme;

- (NSString *) customThemeFilePath;
- (NSString *) createFullPathFromThemeFileName: (NSString *) fileName;

- (NSString *) themeFileName;
- (void) setThemeFileName: (NSString *) fileName;
- (BOOL) usesCustomTheme;
- (void) setUsesCustomTheme: (BOOL) use;

- (NSArray *) installedThemes;
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

- (BOOL) mailAttachmentShown;
- (void) setMailAttachmentShown : (BOOL) flag;
- (BOOL) mailAddressShown;
- (void) setMailAddressShown : (BOOL) flag;

- (int) openInBrowserType;
- (void) setOpenInBrowserType : (int) aType;

/* SledgeHammer Additions */
- (BOOL) showsPoofAnimationOnInvisibleAbone;
- (void) setShowsPoofAnimationOnInvisibleAbone : (BOOL) showsPoof;

/* ShortCircuit Additions */
- (unsigned int) firstVisibleCount;
- (void) setFirstVisibleCount : (unsigned int) aValue;
- (unsigned int) lastVisibleCount;
- (void) setLastVisibleCount : (unsigned int) aValue;

/* SecondFlight Additions */
- (BOOL) previewLinkWithNoModifierKey;
- (void) setPreviewLinkWithNoModifierKey : (BOOL) previewDirectly;

/* InnocentStarter Additions */
- (float) mouseDownTrackingTime;
- (void) setMouseDownTrackingTime : (float) aValue;

/* Vita Additions */
- (BOOL) scrollToLastUpdated;
- (void) setScrollToLastUpdated : (BOOL) flag;

/* Twincam Angel Additions */
- (NSString *)linkDownloaderDestination;
- (void)setLinkDownloaderDestination:(NSString *)path;
- (NSMutableArray *)linkDownloaderDictArray;
- (void)setLinkDownloaderDictArray:(NSMutableArray *)array;
- (NSArray *)linkDownloaderExtensionTypes;
- (NSArray *)linkDownloaderAutoopenTypes;

- (void) _loadThreadViewerSettings;
- (BOOL) _saveThreadViewerSettings;
@end



@interface AppDefaults(Account)
- (NSURL *) x2chAuthenticationRequestURL;

- (BOOL) shouldLoginIfNeeded;
- (void) setShouldLoginIfNeeded : (BOOL) flag;
- (BOOL) shouldLoginBe2chAnyTime;
- (void) setShouldLoginBe2chAnyTime : (BOOL) flag;

- (BOOL) hasAccountInKeychain;
- (void) setHasAccountInKeychain : (BOOL) usesKeychain;

- (BOOL) availableBe2chAccount;

- (NSString *) x2chUserAccount;
- (void) setX2chUserAccount : (NSString *) account;
- (NSString *) be2chAccountMailAddress;
- (void) setBe2chAccountMailAddress : (NSString *) address;
- (NSString *) be2chAccountCode;
- (void) setBe2chAccountCode : (NSString *) code;
- (NSString *) password;
- (void) loadAccountSettings;

- (BOOL) changeAccount : (NSString *) newAccount
			  password : (NSString *) newPassword
		  usesKeychain : (BOOL      ) usesKeychain;
- (BOOL) deleteAccount;
@end


@interface AppDefaults(BundleSupport)
- (NSBundle *) moduleWithName : (NSString *) bundleName
					   ofType : (NSString *) type
				  inDirectory : (NSString *) bundlePath;

- (id) _imagePreviewer;
- (id<BSImagePreviewerProtocol>) sharedImagePreviewer;
- (id) _preferencesPane;
- (id) sharedPreferencesPane;
- (id<w2chConnect>) w2chConnectWithURL : (NSURL        *) anURL
                            properties : (NSDictionary *) properties;

// Available in Twincam Angel.
- (id<w2chAuthenticationStatus>)shared2chAuthenticator;

- (void) _loadImagePreviewerSettings;
- (BOOL) _saveImagePreviewerSettings;
@end

/* Vita Additions */
@interface AppDefaults(Sounds)
- (NSString *) HEADCheckNewArrivedSound;
- (void) setHEADCheckNewArrivedSound : (NSString *) soundName;
- (NSString *) HEADCheckNoUpdateSound;
- (void) setHEADCheckNoUpdateSound : (NSString *) soundName;
- (NSString *) replyDidFinishSound;
- (void) setReplyDidFinishSound : (NSString *) soundName;

- (void) _loadSoundsSettings;
- (BOOL) _saveSoundsSettings;
@end

/* MeteorSweeper Additions */
@interface AppDefaults(BoardWarriorSupport)
- (void) letBoardWarriorStartSyncing: (id) sender;

- (NSURL *) BBSMenuURL;
- (void) setBBSMenuURL: (NSURL *) anURL;

- (BOOL) autoSyncBoardList;
- (void) setAutoSyncBoardList: (BOOL) autoSync;

- (BSAutoSyncIntervalType) autoSyncIntervalTag;
- (void) setAutoSyncIntervalTag: (BSAutoSyncIntervalType) aType;

- (NSTimeInterval) timeIntervalForAutoSyncPrefs;

- (NSDate *) lastSyncDate;
- (void) setLastSyncDate: (NSDate *) finishedDate;

- (void) _loadBWSettings;
- (BOOL) _saveBWSettings;
@end

#pragma mark Constants

extern NSString *const AppDefaultsWillSaveNotification;
