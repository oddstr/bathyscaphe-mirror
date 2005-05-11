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
 * @discussion ステータス行のコントローラー
 */
#import <Cocoa/Cocoa.h>
#import "CMRHistoryManager.h"


/*!
 * @enum StatusLine States
 * @discussion ステータス行に表示されているビューの種類
 * @constant CMRStatusLineNone 何も表示されていない
 * @constant CMRStatusLineInProgress プログレス・バー
 * @constant CMRStatusLineToolbar ツール・バーの表示
 */
enum {
	CMRStatusLineNone = 0,
	CMRStatusLineInProgress,
	CMRStatusLineToolbar,
	CMRStatusLineUnknown
};
/*!
 * @enum StatusLine Position
 * @discussion ステータス行の表示位置
 * @constant CMRStatusLineAtTop ウィンドウ上部
 * @constant CMRStatusLineAtBottom ウィンドウ底部
 */
enum {
	CMRStatusLineAtTop = 0,
	CMRStatusLineAtBottom,
};
/*!
 * @enum Toolbar Items Alignment
 * @discussion ステータス行に表示されているツールバーの配置
 * @constant CMRStatusLineToolbarLeftAlignment 左寄せ
 * @constant CMRStatusLineToolbarRightAlignment 右寄せ
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

