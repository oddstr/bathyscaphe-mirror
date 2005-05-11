/**
  * $Id: AppDefaults.h,v 1.1 2005/05/11 17:51:06 tsawada2 Exp $
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
 * @define      CMXPref
 * @discussion  �O���[�o���ȏ����ݒ�I�u�W�F�N�g
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
	
	// �p�ɂɃA�N�Z�X�����\���̂���ϐ�
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



- (BOOL) isSupportedAppKitVersion10_2;

- (BOOL) isOnlineMode;
- (void) setIsOnlineMode : (BOOL) flag;
- (IBAction) toggleOnlineMode : (id) sender;

- (BOOL) isSplitViewVertical;
- (void) setIsSplitViewVertical : (BOOL) flag;

// �X���b�h���폜����Ƃ��Ɍx�����Ȃ�
- (BOOL) quietDeletion;

// �O�������N���o�b�N�O���E���h�ŊJ��
- (BOOL) openInBg;

/*** �f���h�����[ ***/
- (int) boardListState;
- (void) setBoardListState : (int) state;
- (float) boardListSizeWidth;
- (void) setBoardListSizeWidth : (float) width;
- (float) boardListSizeHeight;
- (void) setBoardListSizeHeight : (float) height;
- (NSRectEdge) boardListDrawerEdge;
- (void) setBoardListDrawerEdge : (NSRectEdge) edge;
- (void) setBrowserStatusFilteringMask : (int) mask;
- (NSSize) boardListContentSize;
- (void) setBoardListContentSize : (NSSize) contentSize;
- (BOOL) isBoardListOpen;
- (void) setIsBoardListOpen : (BOOL) isOpen;

/*** �������݁F���O�� ***/
- (NSString *) defaultReplyName;
- (void) setDefaultReplyName : (NSString *) name;
- (NSString *) defaultReplyMailAddress;
- (void) setDefaultReplyMailAddress : (NSString *) mail;
- (NSArray *) defaultKoteHanList;
- (void) setDefaultKoteHanList : (NSArray *) array;

/* 1.0.9.6 �ȑO�̂��C�ɓ�����C���|�[�g�������ǂ��� */
- (BOOL) isFavoritesImported;
- (void) setIsFavoritesImported : (BOOL) TorF;

/* �Ō�ɊJ������ */
- (CMRBBSSignature *) browserLastBoard;
- (void) setBrowserLastBoard : (CMRBBSSignature *) aSignature;

/*** �X���b�h�ꗗ ***/
/* �\�[�g */
- (NSString *) browserSortColumnIdentifier;
- (void) setBrowserSortColumnIdentifier : (NSString *) identifier;
- (BOOL) browserSortAscending;
- (void) setBrowserSortAscending : (BOOL) isAscending;
- (int) browserStatusFilteringMask;
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
@end



@interface AppDefaults(BackgroundColors)
- (NSColor *) browserStripedTableColor;
- (void) setBrowserStripedTableColor : (NSColor *) color;
- (BOOL) browserSTableDrawsStriped;
- (void) setBrowserSTableDrawsStriped : (BOOL) flag;
- (NSColor *) browserSTableBackgroundColor;
- (void) setBrowserSTableBackgroundColor : (NSColor *) color;
- (BOOL) browserSTableDrawsBackground;
- (void) setBrowserSTableDrawsBackground : (BOOL) flag;
- (NSColor *) threadViewerBackgroundColor;
- (void) setThreadViewerBackgroundColor : (NSColor *) color;
- (BOOL) threadViewerDrawsBackground;
- (void) setThreadViewerDrawsBackground : (BOOL) flag;
- (NSColor *) resPopUpBackgroundColor;
- (void) setResPopUpBackgroundColor : (NSColor *) color;
- (BOOL) isResPopUpSeeThrough;
- (void) setIsResPopUpSeeThrough : (BOOL) anIsResPopUpSeeThrough;

- (void) _loadBackgroundColors;
- (BOOL) _saveBackgroundColors;
@end



@interface AppDefaults(Filter)
/*** ���f���X�t�B���^***/
- (BOOL) spamFilterEnabled;
- (void) setSpamFilterEnabled : (BOOL) flag;

// �{�����̌����`�F�b�N����
- (BOOL) usesSpamMessageCorpus;
- (void) setUsesSpamMessageCorpus : (BOOL) flag;

- (NSString *) spamMessageCorpusStringRepresentation;
- (void) setUpSpamMessageCorpusWithString : (NSString *) aString;


// ���f���X���������Ƃ��̓���F
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
- (NSColor *) replyBackgroundColor;
- (void) setReplyBackgroundColor : (NSColor *) aColor;
- (NSFont *) replyFont;
- (void) setReplyFont : (NSFont *) aFont;
- (BOOL) caretUsesTextColor;
- (void) setCaretUsesTextColor : (BOOL) flag;

/*** �|�b�v�A�b�v ***/
// �f�t�H���g�̐F
- (NSColor *) resPopUpDefaultTextColor;
- (void) setResPopUpDefaultTextColor : (NSColor *) color;
- (BOOL) isResPopUpTextDefaultColor;
- (void) setIsResPopUpTextDefaultColor : (BOOL) flag;

// @see CMXPopUpWindowAttributes.h
- (BOOL) popUpWindowHasVerticalScroller;
- (BOOL) popUpWindowAutohidesScrollers;
- (BOOL) popUpWindowVerticalScrollerIsSmall;
- (void) setPopUpWindowAutohidesScrollers : (BOOL) flag;
- (void) setPopUpWindowHasVerticalScroller : (BOOL) flag;
- (void) setPopUpWindowVerticalScrollerIsSmall : (BOOL) flag;


- (float) threadsListRowHeight;
- (void) setThreadsListRowHeight : (float) rowHeight;
- (void) fixRowHeightToFontSize;

- (NSSize) threadsListIntercellSpacing;
- (void) setThreadsListIntercellSpacing : (NSSize) space;

- (void) setThreadsListRowHeightNum : (NSNumber *) rowHeight;
- (void) setThreadsListIntercellSpacingHeight : (NSNumber *) height;
- (void) setThreadsListIntercellSpacingWidth : (NSNumber *) width;

- (BOOL) threadsListDrawsGrid;
- (void) setThreadsListDrawsGrid : (BOOL) flag;
- (NSColor *) threadsListGridColor;
- (void) setThreadsListGridColor : (NSColor *) color;

// �e�L�X�g�̋����F
- (NSColor *) textEnhancedColor;
- (void) setTextEnhancedColor : (NSColor *) color;

- (NSColor *) threadsListColor;
- (void) setThreadsListColor : (NSColor *) color;
- (NSFont *) threadsListFont;
- (void) setThreadsListFont : (NSFont *) aFont;
- (NSColor *) threadsListNewThreadColor;
- (void) setThreadsListNewThreadColor : (NSColor *) color;
- (NSFont *) threadsListNewThreadFont;
- (void) setThreadsListNewThreadFont : (NSFont *) aFont;

- (BOOL) shouldThreadAntialias;
- (void) setShouldThreadAntialias : (BOOL) flag;

- (NSFont *) threadsViewFont;
- (void) setThreadsViewFont : (NSFont *) aFont;
- (NSColor *) threadsViewColor;
- (void) setThreadsViewColor : (NSColor *) color;
/* Accessor for _messageHeadIndent */
- (float) messageHeadIndent;
- (void) setMessageHeadIndent : (float) anIndent;
/* Accessor for _messageColor */
- (NSColor *) messageColor;
- (void) setMessageColor : (NSColor *) color;
/* Accessor for _messageFont */
- (NSFont *) messageFont;
- (void) setMessageFont : (NSFont *) font;
/* Accessor for _messageTitleColor */
- (NSColor *) messageTitleColor;
- (void) setMessageTitleColor : (NSColor *) color;
/* Accessor for _messageTitleFont */
- (NSFont *) messageTitleFont;
- (void) setMessageTitleFont : (NSFont *) font;
/* Accessor for _messageNameColor */
- (NSColor *) messageNameColor;
- (void) setMessageNameColor : (NSColor *) color;

	
/* �`�`�F�t�H���g */
- (NSFont *) messageAlternateFont;
- (void) setMessageAlternateFont : (NSFont *) font;

- (NSColor *) messageAnchorColor;
- (void) setMessageAnchorColor : (NSColor *) color;

- (NSColor *) messageFilteredColor;
- (void) setMessageFilteredColor : (NSColor *) color;

- (BOOL) hasMessageAnchorUnderline;
- (void) setHasMessageAnchorUnderline : (BOOL) flag;
- (void) _loadFontAndColor;
- (BOOL) _saveFontAndColor;
@end



@interface AppDefaults(ThreadsListSettings)
- (int) threadsListAutoscrollMask;
- (void) setThreadsListAutoscrollMask : (int) mask;
- (NSString *) ignoreTitleCharacters;
- (void) setIgnoreTitleCharacters : (NSString *) ignoreChars;

// statusLine
- (BOOL) canUseSpinningStyle;
- (BOOL) statusLineUsesSpinningStyle;
- (void) setStatusLineUsesSpinningStyle : (BOOL) usesSpinningStyle;
- (int) statusLinePosition;
- (void) setStatusLinePosition : (int) aStatusLinePosition;
- (int) statusLineToolbarAlignment;
- (void) setStatusLineToolbarAlignment : (int) aStatusLineToolbarAlignment;


- (void) _loadThreadsListSettings;
- (BOOL) _saveThreadsListSettings;
@end



@interface AppDefaults(ThreadViewerSettings)
/* �X���b�h���_�E�����[�h�����Ƃ��͂��ׂĕ\������ */
- (BOOL) showsAllMessagesWhenDownloaded;
- (void) setShowsAllMessagesWhenDownloaded : (BOOL) flag;

;

/* �I���U�t���C�ǂݍ��� */
- (unsigned) onTheFlyCompositionAttributes;
- (void) setOnTheFlyCompositionAttributes : (unsigned) value;

/* �u�E�C���h�E�̈ʒu�Ɨ̈���L���v */
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



//////////////////////////////////////////////////////////////////////
////////////////////// [ �萔��}�N���u�� ] //////////////////////////
//////////////////////////////////////////////////////////////////////
extern NSString *const AppDefaultsWillSaveNotification;
