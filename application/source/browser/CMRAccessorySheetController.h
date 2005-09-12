/**
  * $Id: CMRAccessorySheetController.h,v 1.2 2005/09/12 08:02:20 tsawada2 Exp $
  * 
  * CMRAccessorySheetController.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>

#import "CocoMonar_Prefix.h"
#import "BoardManager.h"


@interface CMRAccessorySheetController : NSWindowController
{
	IBOutlet NSView			*m_originalContentView;
	IBOutlet NSView			*m_contentView;
	IBOutlet NSButton		*m_closeButton;
}
- (id) initWithContentSize : (NSSize	  ) cSize
			  resizingMask : (unsigned int) autoresizingMask;

- (NSView	*) originalContentView;
- (NSButton *) closeButton;
- (NSView	*) contentView;
- (void) setContentView : (NSView *) aView;
- (void) setContentSize : (NSSize) cSize;
- (void) beginSheetModalForWindow : (NSWindow *) docWindow
					modalDelegate : (id        ) modalDelegate
					  contentView : (NSView   *) contentView
					  contextInfo : (id		   ) info;

- (void) setupContentView;
- (void) setupCloseButton;
- (void) setupWindow;
- (void) setupUIComponents;

- (IBAction) close : (id) sender;
@end

@interface CMRAccessorySheetController(Private)
- (void) sheetDidEnd : (NSWindow *) sheet
		  returnCode : (int       ) returnCode
		 contextInfo : (void     *) contextInfo;
@end

@interface NSObject(CMRAccessorySheetControllerModalDelegate)
- (void) controller : (CMRAccessorySheetController *) aController
		sheetDidEnd : (NSWindow					 *) sheet
		contentView : (NSView					 *) contentView
		contextInfo : (id						  ) info;
@end
