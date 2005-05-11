//: CMRTaskItemController.h
/**
  * $Id: CMRTaskItemController.h,v 1.1.1.1 2005/05/11 17:51:07 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <SGFoundation/SGFoundation.h>
#import <Cocoa/Cocoa.h>

@protocol	CMRTask;
@class		NSView;



@interface CMRTaskItemController : SGBaseObject
{
	IBOutlet NSView					*_contentView;
	IBOutlet NSTextField			*_titleField;
	IBOutlet NSTextField			*_messageField;
	IBOutlet NSProgressIndicator	*_indicator;
	IBOutlet NSButton				*_stopButton;
	
	id<CMRTask>						_task;
	NSDate							*_finishedDate;
}
- (id) initWithTask : (id<CMRTask>) aTask;

- (IBAction) stop : (id) sender;
- (id<CMRTask>) task;
- (NSView *) contentView;
- (NSString *) title;
- (void) setTitle : (NSString *) aTitle;
- (NSString *) message;
- (void) setMessage : (NSString *) aMessage;
@end
