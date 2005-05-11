/**
  * $Id: CMRStatusLine.h,v 1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * CMRStatusLine.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
/*!
 * @header     CMRStatusLine
 * @discussion �X�e�[�^�X�s�̃R���g���[���[
 */
#import <Cocoa/Cocoa.h>
#import "CMRHistoryManager.h"


/*!
 * @enum StatusLine States
 * @discussion �X�e�[�^�X�s�ɕ\������Ă���r���[�̎��
 * @constant CMRStatusLineNone �����\������Ă��Ȃ�
 * @constant CMRStatusLineInProgress �v���O���X�E�o�[
 * @constant CMRStatusLineToolbar �c�[���E�o�[�̕\��
 */
enum {
	CMRStatusLineNone = 0,
	CMRStatusLineInProgress,
	CMRStatusLineToolbar,
	CMRStatusLineUnknown
};
/*!
 * @enum StatusLine Position
 * @discussion �X�e�[�^�X�s�̕\���ʒu
 * @constant CMRStatusLineAtTop �E�B���h�E�㕔
 * @constant CMRStatusLineAtBottom �E�B���h�E�ꕔ
 */
enum {
	CMRStatusLineAtTop = 0,
	CMRStatusLineAtBottom,
};
/*!
 * @enum Toolbar Items Alignment
 * @discussion �X�e�[�^�X�s�ɕ\������Ă���c�[���o�[�̔z�u
 * @constant CMRStatusLineToolbarLeftAlignment ����
 * @constant CMRStatusLineToolbarRightAlignment �E��
 */
enum {
	CMRStatusLineToolbarLeftAlignment = 0,
	CMRStatusLineToolbarRightAlignment,
};



@interface CMRStatusLine : NSObject
{
	NSWindow						*_window;
	NSString						*_identifier;
	id								_delegate;
	struct {
		unsigned int	delegateRespondsForward:1;
		unsigned int	delegateRespondsBackward:1;
		unsigned int	delegateRespondsShouldForward:1;
		unsigned int	delegateRespondsShouldBackward:1;
		unsigned int	reserved:28;
	} _Flags;
	
	IBOutlet NSView					*_statusLineView;
	
	// Progress Indicator...
	IBOutlet NSView					*_indicatorView;
	IBOutlet NSTextField			*_statusTextField;
	IBOutlet NSProgressIndicator	*_progressIndicator;
	IBOutlet NSButton				*_stopButton;
	
	// toolbar
//	IBOutlet NSButton				*_bookmarksButton;
	IBOutlet NSView					*_toolbarView;
	IBOutlet NSTextField			*_infoTextField;
	IBOutlet NSPopUpButton			*_boardHistoryPopUp;
	IBOutlet NSPopUpButton			*_threadHistoryPopUp;
	IBOutlet NSMatrix				*_forwardBackMatrix;
	IBOutlet NSMatrix				*_toolbarItemMatrix;
}
- (id) initWithIdentifier : (NSString *) identifier;

- (int) state;
- (NSString *) identifier;

- (id) delegate;
- (void) setDelegate : (id) aDelegate;

- (NSWindow *) window;
- (void) setWindow : (NSWindow *) aWindow
		   visible : (BOOL) shown;
- (void) setWindow : (NSWindow *) aWindow;

- (BOOL) isVisible;
- (void) setVisible : (BOOL) shown
            animate : (BOOL) isAnimate;
- (int) toolbarAlignment;
- (void) updateStatusLinePosition;

- (void) setInfoText : (id) aText;

// Action
- (IBAction) cancel : (id) sender;
- (IBAction) toggleStatusLineShown : (id) sender;
@end



@interface CMRStatusLine(History)<CMRHistoryClient>
// History PopUp
- (void) updateForwardBackButtons;

- (void) synchronizeHistoryTitleAndSelectedItem;
- (void) synchronizeHistoryItemsWithManager;

- (BOOL ) boardHistoryEnabled;
- (BOOL ) threadHistoryEnabled;

- (void) setBoardHistoryEnabled : (BOOL) flag;
- (void) setThreadHistoryEnabled : (BOOL) flag;

- (IBAction) historyForward : (id) sender;
- (IBAction) historyBackward : (id) sender;
@end



@interface NSObject(CMRStatusLineDelegate)
- (BOOL) statusLinePerformForward : (CMRStatusLine *) aStatusLine;
- (BOOL) statusLinePerformBackward : (CMRStatusLine *) aStatusLine;
- (BOOL) statusLineShouldPerformForward : (CMRStatusLine *) aStatusLine;
- (BOOL) statusLineShouldPerformBackward : (CMRStatusLine *) aStatusLine;
@end

