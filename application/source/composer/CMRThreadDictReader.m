/**
  * $Id: CMRThreadDictReader.m,v 1.1.1.1 2005/05/11 17:51:04 tsawada2 Exp $
  * 
  * CMRThreadDictReader.m
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadDictReader.h"
#import "CMRThreadMessage.h"
#import "CMRThreadVisibleRange.h"
#import "CocoMonar_Prefix.h"
#import "CMRMessageComposer.h"



@implementation CMRThreadDictReader
+ (Class) resourceClass
{
	return [NSDictionary class];
}

- (NSArray *) messageDictArray
{
	NSArray		*ary;
	
	ary = [[self fileContents] objectForKey : ThreadPlistContentsKey];
	if (nil == ary) return [NSArray empty];
	
	return ary;
}
- (void) dealloc
{
	[_attributes release];
	[super dealloc];
}

// override
- (CMRThreadVisibleRange *) visibleRange;
{
	CMRThreadVisibleRange		*range_;
	
	range_ = [CMRThreadVisibleRange objectWithPropertyListRepresentation : 
				[[self threadAttributes] objectForKey:CMRThreadVisibleRangeKey]];
	
	return range_ ? range_ : [CMRThreadVisibleRange defaultVisibleRange];
}
- (unsigned int) numberOfMessages
{
	NSNumber	*n;
	
	n = [[self threadAttributes] objectForKey : CMRThreadLastLoadedNumberKey];
	UTILAssertNotNil(n);
	
	return [n unsignedIntValue];
}
- (NSDictionary *) threadAttributes
{
	if (nil == _attributes && [self fileContents] != nil) {
		id		v;
		
		_attributes = [[NSMutableDictionary alloc] initWithCapacity : 16];
		[_attributes addEntriesFromDictionary : [self fileContents]];
		[_attributes removeObjectForKey : ThreadPlistContentsKey];
		
		v = [NSNumber numberWithUnsignedInt : [[self messageDictArray] count]];
		[_attributes setObject:v forKey:CMRThreadLastLoadedNumberKey];
		
		/* check */
		v = [_attributes objectForKey : ThreadPlistBoardNameKey];
		if (nil == v) goto INVALID_LOG_FILE;
		v = [_attributes objectForKey : ThreadPlistIdentifierKey];
		if (nil == v) goto INVALID_LOG_FILE;
		
		goto END_ATTRIBUTES;
		/* Log file was invalid */
INVALID_LOG_FILE:
		[NSException raise : NSGenericException
		format :
		@"*** REPORT ***\n\n"
		@"Log file was incompleted.\n"
		@"Please edit manually:\n"
		@"(1) open file by your editor (TextEdit, Property List Editor, etc)\n"
		@"(2) edit [%@] value --> board name\n"
		@"(3) edit [%@] value --> dat number\n\n"
		@"Thanks!\n",
		ThreadPlistBoardNameKey,
		ThreadPlistIdentifierKey];
	}
END_ATTRIBUTES:
	if (nil == _attributes)
		return [NSDictionary empty];
	
	return _attributes;
}


- (BOOL) composeNextMessageWithComposer : (id<CMRMessageComposer>) composer
{
	NSArray				*ary = [self messageDictArray]; 
	unsigned			idx  = [self nextMessageIndex];
	NSDictionary		*messageDict_;
	CMRThreadMessage	*message_;
	id					rep;
	
	if(idx >= [ary count]) return NO;
	
	messageDict_ = [ary objectAtIndex : idx];
	message_ = [[CMRThreadMessage alloc] init];
	
#define OBJECT_KEY(key)		[messageDict_ objectForKey : (key)]
	[message_ setIndex : idx];
	[message_ setName : OBJECT_KEY(ThreadPlistContentsNameKey)];
	[message_ setMail : OBJECT_KEY(ThreadPlistContentsMailKey)];
	[message_ setDate : OBJECT_KEY(ThreadPlistContentsDateKey)];
	[message_ setDatePrefix : OBJECT_KEY(ThreadPlistContentsDatePrefixKey)];
	[message_ setIDString : OBJECT_KEY(ThreadPlistContentsIDKey)];
	[message_ setBeProfile : OBJECT_KEY(ThreadPlistContentsBeProfileKey)];
	[message_ setHost : OBJECT_KEY(CMRThreadContentsHostKey)];
	[message_ setMessageSource : OBJECT_KEY(ThreadPlistContentsMessageKey)];
	
	rep = OBJECT_KEY(CMRThreadContentsStatusKey);
	rep = [CMRThreadMessageAttributes objectWithPropertyListRepresentation : rep];
	[message_ setMessageAttributes : rep];
	
#undef OBJECT_KEY

	[composer composeThreadMessage : message_];
	[message_ release];
	
	[self incrementNextMessageIndex];
	return YES;
}
@end
