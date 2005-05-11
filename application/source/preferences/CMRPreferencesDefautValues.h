/**
  * $Id: CMRPreferencesDefautValues.h,v 1.1 2005/05/11 17:51:07 tsawada2 Exp $
  * 
  * CMRPreferencesDefautValues.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */


// オンラインモード
#define kPreferencesDefault_OnlineMode				YES

// メールアドレス
#define kPreferencesDefault_MailAttachmentShown		YES
#define kPreferencesDefault_MailAddressShown		YES

#define DEFAULT_TLSEL_HOLDING_MASK			CMRAutoscrollNone
#define DEFAULT_IS_BROWSER_VERTICAL			NO
#define DEFAULT_NEW_THREADS_LIMIT			(100)
#define DEFAULT_THREADS_LIST_FONTSIZE		(13.0f)
#define DEFAULT_THREADS_VIEW_FONTSIZE		(12.0f)
#define DEFAULT_TL_IS_IGNORE_CHARACTERS		NO
#define DEFAULT_BROWSER_THREAD_SEARCH_TAG	0
#define DEFAULT_BROWSER_THREAD_SOPTION		JTCaseInsensitiveSearch
#define DEFAULT_BROWSER_VISIBLE_MESSAGE_TAG	50
#define DEFAULT_BROWSER_SORT_ASCENDING		YES
#define DEFAULT_BROWSER_STATUS_FILTERINGMAS	0

#define DEFAULT_RESPOPUP_IS_SEETHROUGH		NO
#define DEFAULT_STATUS_LINE_VISIBLE			YES
#define DEFAULT_BOARDLIST_WIDTH			150.0f
#define DEFAULT_BOARDLIST_HEIGHT			300.0f
#define DEFAULT_BOARDLIST_STATE			NSDrawerOpenState
#define DEFAULT_STABLE_DRAWS_STRIPED			YES
#define DEFAULT_STABLE_DRAWS_BGCOLOR			NO
#define DEFAULT_TVIEW_DRAWS_BGCOLOR			YES
#define DEFAULT_MESSAGE_HEAD_INDENT			40.0f
#define DEFAULT_MESSAGE_ANCHOR_HAS_UNDERLINE			YES

#define DEFAULT_SHOULD_THREAD_ANTIALIAS			YES
#define DEFAULT_IS_RESPOPUP_TEXT_COLOR			NO
#define DEFAULT_THREAD_VIEWER_LINK_TYPE			ThreadViewerResPopUpLinkType
#define DEFAULT_TV_MAILTO_LINK_TYPE			ThreadViewerResPopUpLinkType
#define DEFAULT_SHOULD_SAVE_PASSWORD		NO
#define DEFAULT_SV_ACCESSORY_POSITION			(SGRightAccessoryViewPosition | SGTopAccessoryViewPosition)

#define DEFAULT_OPEN_IN_BROWSER_TYPE			0

//:AppDefaults-ThreadsList.m
#define DEFAULT_IGNORING_TITLE_CHARACTERS			@"\t "
#define DEFAULT_USES_SPINNINGSTYLE					NO

// NSMaxYEdge にしておくことで、「自動」扱いになるようにしてある（ウインドウの上側から開くことは無い）
#define DEFAULT_BOARDLIST_PREFEREDEDGE				NSMaxYEdge

#define DEFAULT_FAVORITES_IMPORTED				NO

#define DEFAULT_PARAGRAPH_INDENT				40.0f

#define DEFAULT_THREAD_LIST_ROW_HEIGHT			16.0f
#define DEFAULT_THREAD_LIST_INTERCELL_SPACING	NSMakeSize(3.0f, 2.0f)
#define DEFAULT_THREAD_LIST_DRAWSGRID			YES

// 2ch ID & Pass
#define APP_X2CH_AUTHENTICATION_REQUEST_KEY	@"System - 2channel Auth URL"
#define APP_X2CH_REGISTRATION_PAGE_KEY		@"System - 2channel Register URL"

// be-2ch Info
#define APP_BE2CH_REGISTRATION_PAGE_KEY		@"System - be2ch Register URL"

