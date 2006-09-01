/**
  * $Id: CMRStatusLine.h,v 1.4.2.1 2006/09/01 13:46:54 masakih Exp $
  * 
  * CMRStatusLine.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Cocoa/Cocoa.h>

@protocol CMRTask;

@interface CMRStatusLine : NSObject
{
	//NSWindow						*_window;
	NSString						*_identifier;
	id								_delegate;
	
	IBOutlet NSView					*_statusLineView;
	IBOutlet NSTextField			*_statusTextField;
	IBOutlet NSProgressIndicator	*_progressIndicator;
}

- (id) initWithIdentifier : (NSString *) identifier;

- (NSString *) identifier;
- (void) setIdentifier : (NSString *) anIdentifier;

- (id) delegate;
- (void) setDelegate : (id) aDelegate;
/*
- (NSWindow *) window;
- (void) setWindow : (NSWindow *) aWindow
		   visible : (BOOL) shown;
- (void) setWindow : (NSWindow *) aWindow;

- (BOOL) isVisible;
- (void) setVisible : (BOOL) shown
            animate : (BOOL) isAnimate;
*/
- (void) setInfoText : (id) aText;

// Action
- (IBAction) cancel : (id) sender;
//- (IBAction) toggleStatusLineShown : (id) sender;

// User defaults
//- (NSString *) userDefaultsKeyWithKey : (NSString *) key;
//- (NSString *) statusLineShownUserDefaultsKey;

// NSUserDefaults / NSMutableDictionary ...
//- (id) preferencesObject;

- (NSView *) statusLineView;
- (NSTextField *) statusTextField;
- (NSProgressIndicator *) progressIndicator;

- (void) setupUIComponents;
- (void) updateStatusLineWithTask : (id<CMRTask>) aTask;
@end

@interface NSObject(CMRStatusLineDelegateAddition)
- (void) statusLineDidShowTheirViews: (CMRStatusLine *) statusLine;
- (void) statusLineDidHideTheirViews: (CMRStatusLine *) statusLine;
@end