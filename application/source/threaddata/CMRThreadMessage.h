//: CMRThreadMessage.h
/**
  * $Id: CMRThreadMessage.h,v 1.1.1.1.4.2 2006/02/27 17:31:50 masakih Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <SGFoundation/SGFoundation.h>

@interface CMRThreadMessage : NSObject<NSCopying, CMRPropertyListCoding>
{
	@private
	unsigned		_index;		/* 0-base */
	NSString		*_name;
	NSString		*_mail;
	
	id				_date;
	NSString		*_datePrefix;
	NSString		*_dateRepresentation; // may be nil in old log
	
	NSArray			*_beProfile;
	NSString		*_messageSource;

	NSString		*_IDString;
	NSString		*_hostString;
	
	/* Application Difined Attributes*/
	CMRThreadMessageAttributes *_messageAttributes;
}
/* 0-base */
- (unsigned) index;
- (void) setIndex : (unsigned) anIndex;

- (NSString *) name;
- (void) setName : (NSString *) aName;
- (NSString *) mail;
- (void) setMail : (NSString *) aMail;
- (id) date;
- (void) setDate : (id) aDate;

// Humm...
- (NSString *) datePrefix;
- (void) setDatePrefix : (NSString *) aPrefix;

- (NSString *) dateRepresentation;
- (void) setDateRepresentation : (NSString *) aRep;

// Plain Text
- (NSString *) cachedMessage;

// HTML Source
- (NSString *) messageSource;
- (void) setMessageSource : (NSString *) aMessageSource;


// Extra Headers
- (NSString *) IDString;
- (NSString *) host;
- (void) setIDString : (NSString *) anIDString;
- (void) setHost : (NSString *) aHost;
- (NSArray *) beProfile;
- (void) setBeProfile : (NSArray *) aBeProfile;

@end



@interface CMRThreadMessage(MessageAttributes)

- (CMRThreadMessageAttributes *) messageAttributes;
- (void) setMessageAttributes : (CMRThreadMessageAttributes *) attrs;

- (UInt32) status;
- (UInt32) flags;
- (void) setFlags : (UInt32) v;

// User defined property: 6 bit
- (unsigned) property;
- (void) setProperty : (unsigned) aProperty;

// NO == isInvisibleAboned  && NO == isTemporaryInvisible
- (BOOL) isVisible;

// あぼーん
- (BOOL) isAboned;
- (void) setAboned : (BOOL) flag;

// ローカルあぼーん
- (BOOL) isLocalAboned;
- (void) setLocalAboned : (BOOL) flag;

// 透明あぼーん
- (BOOL) isInvisibleAboned;
- (void) setInvisibleAboned : (BOOL) flag;

// AA
- (BOOL) isAsciiArt;
- (void) setAsciiArt : (BOOL) flag;

// ブックマーク
// Finder like label, 3bit unsigned integer value.
- (BOOL) hasBookmark;
// set bookmark 1 if none.
- (void) setHasBookmark : (BOOL) aBookmark;

- (unsigned) bookmark;
- (void) setBookmark : (unsigned) aBookmark;


// このレスは壊れています
- (BOOL) isInvalid;
- (void) setInvalid : (BOOL) flag;

// 迷惑レス
- (BOOL) isSpam;
- (void) setSpam : (BOOL) flag;

// 
// temporary attributes
//
- (void) clearTemporaryAttributes;

// The NONE temporary attributes changes can result in notification posting:
- (BOOL) postsAttributeChangedNotifications;
- (void) setPostsAttributeChangedNotifications : (BOOL) flag;
// Visible Range
- (BOOL) isTemporaryInvisible;
- (void) setTemporaryInvisible : (BOOL) flag;
@end



@interface CMRThreadMessage(Private)
- (void) setMessageAttributeFlag : (UInt32) flag
							  on : (BOOL  ) isSet;
- (void) postDidChangeAttributeNotification;
@end


// Notification
extern NSString *const CMRThreadMessageDidChangeAttributeNotification;


// age / sage
extern NSString *const CMRThreadMessage_AGE_String;
extern NSString *const CMRThreadMessage_SAGE_String;
