/*
 * $Id: CMRReplyMessenger_p.h,v 1.13 2007/12/24 14:29:09 tsawada2 Exp $
 * BathyScaphe
 *
 * Copyright 2005-2006 BathyScaphe Project. All rights reserved.
 *
 */

#import "CMRReplyMessenger.h"
#import "CocoMonar_Prefix.h"

#import "AppDefaults.h"
#import "BoardManager.h"
#import "CMRReplyController.h"
#import "CMRReplyDocumentFileManager.h"

#import "CMRTaskManager.h"
#import "w2chConnect.h"
#import "CMRServerClock.h"

#import "Cookie.h"
#import "CookieManager.h"


#define    MESSENGER_REFERER_FORMAT		@"http://%@/%@/%@"
#define    MESSENGER_REFERER_INDEX_HTML	@"index.html"
//#define    MESSENGER_SHITARABA_REFERER	@"www.shitaraba.com/bbs"

#define MESSENGER_TABLE_NAME					@"Messenger"
#define MESSENGER_SEND_MESSAGE					@"Send Message to %@..."
#define MESSENGER_END_POST						@"EndPost"
#define MESSENGER_ERROR_POST					@"ERROR Send Message"
#define REPLY_MESSENGER_WINDOW_TITLE_FORMAT		@"Window Title"
#define REPLY_MESSENGER_SUBMIT					@"submit"

#define kToolTipForNeededLogin		@"BeLoginOnNeededToolTip"
#define kToolTipForTrivialLoginOff	@"BeLoginOffTrivialToolTip"
#define kToolTipForCantLoginOn		@"BeLoginOffCantLoginToolTip"
#define kToolTipForLoginOn			@"BeLoginOnToolTip"
#define kToolTipForLoginOff			@"BeLoginOffToolTip"

#define kLabelForLoginOn			@"Be Login On"
#define kLabelForLoginOff			@"Be Login Off"

#define kImageForLoginOn			@"beEnabled"
#define kImageForLoginOff			@"beDisabled"

@interface CMRReplyMessenger(Private)
- (void) sendMessageWithHanaMogeraForms : (BOOL) withForms; // Available in CometBlaster and later.

- (void) synchronizeDocumentContentsWithWindowControllers;
+ (NSURL *) targetURLWithBoardURL : (NSURL *) boardURL;
+ (NSString *) formItemBBSWithBoardURL : (NSURL *) boardURL;
+ (NSString *) formItemDirectoryWithBoardURL : (NSURL *) boardURL;

// added in CometBlaster and later
- (NSDictionary *) additionalForms;
- (void) setAdditionalForms : (NSDictionary *) anAdditionalForms;
@end



@interface CMRReplyMessenger(SendMeesage)
// Deprecated in CometBlaster and later. Use formDictionary:name:mail:hanamogera: instead.
/*- (NSDictionary *) formDictionary : (NSString *) message
                             name : (NSString *) name
                             mail : (NSString *) mail;*/

// Available in CometBlaster and later.
- (NSDictionary *) formDictionary : (NSString *) replyMessage
                             name : (NSString *) name
                             mail : (NSString *) mail
					   hanamogera : (BOOL) addForms;

// Available in CometBlaster and later.
- (void) sendMessageWithContents : (NSString *) replyMessage
							name : (NSString *) name
							mail : (NSString *) mail
					  hanamogera : (BOOL ) addForms;

// Deprecated in CometBlaster and later. Use sendMessageWithContents:name:mail:hanamogera: instead.
/*- (void) sendMessageWithContents : (NSString *) message
                            name : (NSString *) name
                            mail : (NSString *) mail;*/

- (NSString *) refererParameter;
- (void) receiveCookiesWithResponse:(NSHTTPURLResponse *)response;
@end


@interface CMRReplyMessenger(PrivateAccessor)
- (CMRReplyController *)replyControllerRespondsTo:(SEL)aSelector;
- (void)setValueConsideringNilValue:(id)value forPlistKey:(NSString *)key;
- (NSMutableDictionary *)mutableInfoDictionary;
- (NSDictionary *)infoDictionary;
- (NSString *)threadTitle;

- (NSString *)formItemBBS;
- (NSString *)formItemKey;
- (NSString *)formItemDirectory; // require for Jbbs_shita

- (NSString *)replyMessage;
- (void)setReplyMessage:(NSString *)aMessage;
- (void)setName:(NSString *)aName;
- (void)setModifiedDate:(NSDate *)aModifiedDate;
- (void)setIsEndPost:(BOOL)flag;
- (BOOL)shouldSendBeCookie;
- (void)setShouldSendBeCookie:(BOOL)flag;
@end
