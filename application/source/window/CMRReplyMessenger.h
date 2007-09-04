/**
  * $Id: CMRReplyMessenger.h,v 1.10 2007/09/04 07:45:43 tsawada2 Exp $
  * 
  * CMRReplyMessenger.h
  *
  * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Cocoa/Cocoa.h>
#import "CMRTask.h"



@interface CMRReplyMessenger : NSDocument
{
	@private
	NSTextStorage			*_textStorage;
	NSMutableDictionary		*_attributes;
	BOOL					_isEndPost;
	BOOL					_isInProgress;
	BOOL					_shouldSendBeCookie;
	NSDictionary			*_additionalForms; // added in CometBlaster and later.
}
- (NSTextStorage *) textStorage;
- (void) setMessageContents : (NSString *) aContents
					replyTo : (unsigned  ) anIndex;

+ (NSString *) stringByQuoted : (NSString *) string;
/* 
	string  contents will be added
	quote   quote this string
	anIndex add anchor to index (no anchor if NSNotFound)
 */
- (void) append : (NSString *) string
		  quote : (BOOL      ) quote
		replyTo : (unsigned  ) anIndex;


- (NSDictionary *) textAttributes;
- (NSDictionary *) infoDictionary;

- (BOOL) isEndPost;
- (void) setIsEndPost : (BOOL) anIsEndPost;

- (void) setWindowFrame : (NSRect) aWindowFrame;
- (void) setModifiedDate : (NSDate *) aModifiedDate;
- (void) setMail : (NSString *) aMail;
- (void) setName : (NSString *) aName;
- (void) setReplyMessage : (NSString *) aMessage;

// available in PrincessBride and later
- (BOOL) shouldSendBeCookie;
- (void) setShouldSendBeCookie : (BOOL) sendBeCookie;
@end



@interface CMRReplyMessenger(Attributes)
- (NSURL *) boardURL;
- (NSURL *) targetURL;

- (NSString *) boardName;
- (NSString *) formItemTitle;
- (NSString *) threadIdentifier;

- (void) synchronizeDocumentContentsWithWindowControllers;
- (void) synchronizeWindowControllersFromDocument;

/* message contents in attributes dictionary (not textStorage) */
- (NSString *) replyMessage;
- (NSString *) name;
- (NSString *) mail;
- (NSDate *) modifiedDate;
- (NSRect) windowFrame;
@end

@interface CMRReplyMessenger(ScriptingSupport)
- (void) setTextStorage : (id) text;
- (NSString *) targetURLAsString;
@end

@interface CMRReplyMessenger(Action)
- (IBAction) sendMessage : (id) sender;
- (IBAction) sendMessage : (id) sender withHanaMogeraForms : (BOOL) withForms; // Available in CometBlaster and later.

// Available in Twincam Angel.
- (IBAction)revealInFinder:(id)sender;
@end


/* Task */
@interface CMRReplyMessenger(CMRTaskImplementation)<CMRTask>
@end


/* Notifications */
extern NSString *const CMRReplyMessengerDidFinishPostingNotification;
