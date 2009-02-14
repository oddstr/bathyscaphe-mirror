// Deprecated method list
// このファイルには、BathyScaphe 1.0.x で廃止された、CocoMonar 時代の AppDefaults のメソッドの宣言が
// コメントとして書かれています。
// 単なる資料です。


/*** 掲示板ドロワー ***/
// deprecated in BathyScaphe 1.0.1.
/*
- (int) boardListState;
- (void) setBoardListState : (int) state;
- (float) boardListSizeWidth;
- (void) setBoardListSizeWidth : (float) width;
- (float) boardListSizeHeight;
- (void) setBoardListSizeHeight : (float) height;
- (NSRectEdge) boardListDrawerEdge;
- (void) setBoardListDrawerEdge : (NSRectEdge) edge;
- (NSSize) boardListContentSize;
- (void) setBoardListContentSize : (NSSize) contentSize;
- (BOOL) isBoardListOpen;
- (void) setIsBoardListOpen : (BOOL) isOpen;
*/

//- (NSColor *) browserStripedTableColor; // deprecated in BathyScpahe 1.0.1
//- (void) setBrowserStripedTableColor : (NSColor *) color; // deprecated in BathyScpahe 1.0.1

//- (BOOL) caretUsesTextColor; // deprecated in BathyScaphe 1.0.1
//- (void) setCaretUsesTextColor : (BOOL) flag; // deprecated in BathyScaphe 1.0.1

// @see CMXPopUpWindowAttributes.h
/* deprecated in BathyScaphe 1.0.1
- (BOOL) popUpWindowHasVerticalScroller;
- (BOOL) popUpWindowAutohidesScrollers;
- (void) setPopUpWindowAutohidesScrollers : (BOOL) flag;
- (void) setPopUpWindowHasVerticalScroller : (BOOL) flag;
*/
/*- (BOOL) isResPopUpSeeThrough;
- (void) setIsResPopUpSeeThrough : (BOOL) anIsResPopUpSeeThrough;*/ // deprecated in SledgeHammer and later.

//- (NSColor *) threadsListGridColor; // deprecated in BathyScaphe 1.0
//- (void) setThreadsListGridColor : (NSColor *) color; // deprecated in BathyScaphe 1.0


// statusLine
/* deprecated in BathyScaphe 1.0.2. */
/*
- (BOOL) statusLineUsesSpinningStyle;
- (void) setStatusLineUsesSpinningStyle : (BOOL) usesSpinningStyle;
- (int) statusLinePosition;
- (void) setStatusLinePosition : (int) aStatusLinePosition;
- (int) statusLineToolbarAlignment;
- (void) setStatusLineToolbarAlignment : (int) aStatusLineToolbarAlignment;
*/

/*
#define AppDefaultsBoardListSizeWidthKey		@"BoardListWidth"
#define AppDefaultsBoardListSizeHeightKey		@"BoardListHeight"
#define AppDefaultsBoardListStateKey		    @"BoardListShown"
#define AppDefaultsBoardListDrawerPreferedEdgeKey		@"BoardList PreferredEdge"
*/

//account
/* deprecated in SledgeHammer. */
//- (NSURL *) x2chRegistrationPageURL;
//- (NSURL *) be2chRegistrationPageURL;

//threadsList interCellSpacing
/* Deprecated in SledgeHammer and later. Use SGTemplateResource() instead. */
//- (NSSize) threadsListIntercellSpacing;
//- (void) setThreadsListIntercellSpacing : (NSSize) space;

//- (void) setThreadsListRowHeightNum : (NSNumber *) rowHeight;
//- (void) setThreadsListIntercellSpacingHeight : (NSNumber *) height;
//- (void) setThreadsListIntercellSpacingWidth : (NSNumber *) width;

//deprecated in SecondFlight and later.

/*
//1.0.9.6 以前のお気に入りをインポートしたかどうか 
- (BOOL) isFavoritesImported;
- (void) setIsFavoritesImported : (BOOL) TorF;
*/

// Deprecated in ShortCircuit and later.
//- (int) threadViewerMailType;
//- (void) setThreadViewerMailType : (int) aType;

// Deprecated in BathyScaphe 1.2.
//- (NSString *) ignoreTitleCharacters;
//- (void) setIgnoreTitleCharacters : (NSString *) ignoreChars;


// Proxy. Deprecated in MeteorSweeper and later.
//- (BOOL) usesProxy;
//- (void) setUsesProxy : (BOOL) anUsesProxy;
//- (BOOL) usesProxyOnlyWhenPOST;
//- (void) setUsesProxyOnlyWhenPOST : (BOOL) anUsesProxy;

//- (BOOL) usesSystemConfigProxy;
//- (void) setUsesSystemConfigProxy : (BOOL) flag;

//- (void) getProxy:(NSString**)host port:(CFIndex*)port;
//- (CFIndex) proxyPort;
//- (void) setProxyPort : (CFIndex) aProxyPort;
//- (NSString *) proxyHost;
//- (void) setProxyHost : (NSString *) aProxyURL;

// Deprecated in Starlight Breaker.
//- (CMRSearchMask) threadSearchOption;
//- (void) setThreadSearchOption : (CMRSearchMask) option;

//- (BOOL) browserSTableDrawsBackground;
//- (void) setBrowserSTableDrawsBackground : (BOOL) flag;

//- (void) setThreadViewerBackgroundColor : (NSColor *) color;
// Alwaws YES. Deprecated.
//- (BOOL) threadViewerDrawsBackground;
//- (void) setThreadViewerDrawsBackground : (BOOL) flag;

//- (void) setReplyTextColor : (NSColor *) aColor;
//- (void) setReplyFont : (NSFont *) aFont;
//- (void) setResPopUpDefaultTextColor : (NSColor *) color;
//- (void) setIsResPopUpTextDefaultColor : (BOOL) flag;

//- (void) setThreadsViewFont : (NSFont *) aFont;
//- (void) setThreadsViewColor : (NSColor *) color;

//- (void) setMessageFont : (NSFont *) font;
//- (void) setMessageColor : (NSColor *) color;

//- (void) setMessageTitleFont : (NSFont *) font;
//- (void) setMessageTitleColor : (NSColor *) color;

//- (void) setMessageNameColor : (NSColor *) color;
//- (void) setMessageAlternateFont : (NSFont *) font;

//- (void) setMessageAnchorColor : (NSColor *) color;

//- (void) setMessageHostFont : (NSFont *) aFont;
//- (void) setMessageHostColor : (NSColor *) color;

//- (void) setMessageBeProfileFont : (NSFont *) aFont;

/*
@interface AppDefaults(LibraryPath)
- (BOOL) createDirectoryAtPath : (NSString *) path;
- (BOOL) validatePathLength : (NSString *) filepath;
@end
*/


/*
@interface AppDefaults(AlertPanel)
+ (NSString *) tableForPanels;
+ (NSString *) labelForDefaultButton;
+ (NSString *) labelForAlternateButton;
- (int) runDirectoryNotFoundAlertAndTerminateWithMessage : (NSString *) msg;
- (int) runAlertPanelWithLocalizedString : (NSString *) title
								 message : (NSString *) msg;
- (int) runCriticalAlertPanelWithLocalizedString : (NSString *) title
                                          message : (NSString *) msg;
@end*/

/*- (NSFont *) threadsViewFont;
- (NSColor *) threadsViewColor;
- (NSFont *) messageFont;
- (NSColor *) messageColor;
- (NSFont *) messageTitleFont;
- (NSColor *) messageTitleColor;
- (NSColor *) messageNameColor;
- (NSFont *) messageAlternateFont;
- (NSColor *) messageAnchorColor;
- (NSFont *) messageHostFont;
- (NSColor *) messageHostColor;
- (NSFont *) messageBeProfileFont;
- (NSFont *) messageBookmarkFont;
- (NSColor *) messageBookmarkColor;*/

//- (NSColor *) resPopUpDefaultTextColor;
//- (BOOL) isResPopUpTextDefaultColor;


//- (BOOL) oldFavoritesUpdated;
//- (void) setOldFavoritesUpdated: (BOOL) flag;

//- (void) setResPopUpBackgroundColor : (NSColor *) color;

//- (void) setReplyBackgroundColor : (NSColor *) aColor;

// SledgeHammer Additions
//- (void) setResPopUpBgAlphaValue : (float) rate;
//- (float) replyBgAlphaValue;
//- (void) setReplyBgAlphaValue : (float) rate;


/* MeteorSweeper: Hidden Proxy Options */
/* Removed in Starlight Breaker. */
//- (BOOL) usesOwnProxy;
//- (void) getOwnProxy: (NSString **) host port: (CFIndex *) port;

/*
- (NSString *) spamMessageCorpusStringRepresentation;
- (void) setUpSpamMessageCorpusWithString : (NSString *) aString;
*/

/*
- (NSString *) helperAppPath;
- (void) setHelperAppPath : (NSString *) fullPath_;
- (NSString *) helperAppDisplayName;
*/

/* PrincessBride Additions */
// Deprecated in Twincam Angel.
/*- (BOOL) titleRulerViewTextUsesBlackColor;
- (void) setTitleRulerViewTextUsesBlackColor : (BOOL) usesBlackColor;*/

/* Starlight Breaker -- Theme groups */
//- (NSColor *) replyTextColor;
//- (NSFont *) replyFont;
/* End Theme groups */

//- (NSColor *) resPopUpBackgroundColor;
//- (float) resPopUpBgAlphaValue;

// Deprecated in BathyScaphe 1.6.2.
/*- (NSString *) browserSortColumnIdentifier;
- (void) setBrowserSortColumnIdentifier : (NSString *) identifier;
- (BOOL) browserSortAscending;
- (void) setBrowserSortAscending : (BOOL) isAscending;
- (int) browserStatusFilteringMask;
- (void) setBrowserStatusFilteringMask : (int) mask;*/


/* オンザフライ読み込み */
// ずっと未使用。今となっては目的、意図は不明。
//- (unsigned) onTheFlyCompositionAttributes;
//- (void) setOnTheFlyCompositionAttributes : (unsigned) value;


// Constants
//#define DEFAULT_NEW_THREADS_LIMIT			(100)
//#define DEFAULT_THREADS_VIEW_FONTSIZE		(12.0f)
//#define DEFAULT_TL_IS_IGNORE_CHARACTERS		NO
//#define DEFAULT_BROWSER_THREAD_SEARCH_TAG	0
//#define DEFAULT_BROWSER_THREAD_SOPTION		JTCaseInsensitiveSearch
//#define DEFAULT_BROWSER_VISIBLE_MESSAGE_TAG	50

//#define DEFAULT_USE_PROXY					NO // will be deprecated in the future.
//#define DEFAULT_PROXY_PORT					8080 // will be deprecated in the future.

//#define DEFAULT_RESPOPUP_IS_SEETHROUGH		NO
//#define DEFAULT_STATUS_LINE_VISIBLE			NO

//#define DEFAULT_TVIEW_DRAWS_BGCOLOR			YES
//#define DEFAULT_MESSAGE_HEAD_INDENT			40.0f

//#define DEFAULT_SHOULD_SAVE_PASSWORD		NO
//#define DEFAULT_SV_ACCESSORY_POSITION			(SGRightAccessoryViewPosition | SGTopAccessoryViewPosition)

//#define DEFAULT_STABLE_DRAWS_BGCOLOR			NO
//#define DEFAULT_THREAD_LIST_INTERCELL_SPACING	NSMakeSize(3.0f, 2.0f)
//#define APP_X2CH_REGISTRATION_PAGE_KEY		@"System - 2channel Register URL"

// be-2ch Info
//#define APP_BE2CH_REGISTRATION_PAGE_KEY		@"System - be2ch Register URL"

//#define DEFAULT_HELPER_APP			@"CMLogBuccaneer.app"
//#define DEFAULT_HISTORY_SEGCTRL_MENU		YES
