/**
  * $Id: CMRAccessorySheetController.h,v 1.1.1.1 2005/05/11 17:51:03 tsawada2 Exp $
  * 
  * CMRAccessorySheetController.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>



@interface CMRAccessorySheetController : NSWindowController
{
	IBOutlet NSView			*m_originalContentView;
	IBOutlet NSView			*m_contentView;
	IBOutlet NSButton		*m_closeButton;
}
- (id) initWithContentSize : (NSSize	  ) cSize
			  resizingMask : (unsigned int) autoresizingMask;
@end



@interface CMRAccessorySheetController(Content)
- (NSView *) contentView;
- (void) setContentView : (NSView *) aView;
- (void) setContentSize : (NSSize) cSize;
- (void) beginSheetModalForWindow : (NSWindow *) docWindow
					modalDelegate : (id        ) modalDelegate
					  contentView : (NSView   *) contentView
					  contextInfo : (id		   ) info;
@end



@interface CMRAccessorySheetController(Action)
- (IBAction) close : (id) sender;
@end



@interface NSObject(CMRAccessorySheetControllerModalDelegate)
- (void) controller : (CMRAccessorySheetController *) aController
		sheetDidEnd : (NSWindow					 *) sheet
		contentView : (NSView					 *) contentView
		contextInfo : (id						  ) info;

- (void) boardListSheetDidEnd : (NSWindow *) sheet 
				  contentView : (NSView *) contentView;
@end
