//
//  CMRReplyMessenger.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/12/24.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>
#import "CMRTask.h"

@interface CMRReplyMessenger : NSDocument<CMRTask>
{
	@private
	NSTextStorage			*_textStorage;
	NSMutableDictionary		*_attributes;
	BOOL					_isEndPost;
	BOOL					_isInProgress;
	BOOL					_shouldSendBeCookie;
	NSDictionary			*_additionalForms; // added in CometBlaster and later.
}

- (void)replaceInfoDictionary:(NSDictionary *)newDict;
- (void)setUpBeLoginSetting;

+ (NSString *)stringByQuoted:(NSString *)string;

- (void)append:(NSString *)string quote:(BOOL)quote replyTo:(unsigned int)anIndex;
- (void)updateReplyMessage;

- (NSTextStorage *)textStorage;
- (NSDictionary *)textAttributes;

- (id)threadIdentifier;
- (NSString *)datIdentifier;
- (NSURL *)boardURL;
- (NSURL *)targetURL;
- (NSString *)boardName;

- (NSString *)name;
- (void)setName:(NSString *)aName;
- (NSString *)mail;
- (void)setMail:(NSString *)aMail;
- (NSDate *)modifiedDate;
- (NSRect)windowFrame;
- (void)setWindowFrame:(NSRect)aWindowFrame;
- (BOOL)isEndPost;
@end


@interface CMRReplyMessenger(Action)
- (IBAction)sendMessage:(id)sender;
- (IBAction)toggleBeLogin:(id)sender;
- (IBAction)revealInFinder:(id)sender; // Available in Twincam Angel and later.
- (IBAction)showLocalRules:(id)sender; // Available in SilverGull and later.
- (IBAction)openBBSInBrowser:(id)sender; // Available in SilverGull and later.
@end


@interface CMRReplyMessenger(ScriptingSupport)
- (void)setTextStorage:(id)text;
- (NSString *)targetURLAsString;
@end


extern NSString *const CMRReplyMessengerDidFinishPostingNotification;
