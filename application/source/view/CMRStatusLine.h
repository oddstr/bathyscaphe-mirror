/**
  * $Id: CMRStatusLine.h,v 1.3 2005/09/28 14:49:34 tsawada2 Exp $
  * 
  * CMRStatusLine.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Cocoa/Cocoa.h>

/*!
 * @enum StatusLine States
 * @discussion ステータス行の状態
 * @constant CMRStatusLineNone 何も表示されていない
 * @constant CMRStatusLineInProgress プログレスバーがくるくる回転中
 */
enum {
	CMRStatusLineNone = 0,
	CMRStatusLineInProgress,
	CMRStatusLineUnknown
};


@interface CMRStatusLine : NSObject
{
	NSWindow						*_window;
	NSString						*_identifier;
	id								_delegate;
	
	IBOutlet NSView					*_statusLineView;
	IBOutlet NSTextField			*_statusTextField;
	//IBOutlet NSTextField			*_browserInfoTextField;
	IBOutlet NSProgressIndicator	*_progressIndicator;
	//IBOutlet NSButton				*_stopButton;
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

- (void) setInfoText : (id) aText;
//- (void) setBrowserInfoText : (id) aText; // Deprecated in LeafTicket and later:
// Action
- (IBAction) cancel : (id) sender;
- (IBAction) toggleStatusLineShown : (id) sender;

// User defaults
- (NSString *) userDefaultsKeyWithKey : (NSString *) key;
- (NSString *) statusLineShownUserDefaultsKey;

// NSUserDefaults / NSMutableDictionary ...
- (id) preferencesObject;
@end