//: CMRThreadMessageAttributes.m
/**
  * $Id: CMRThreadMessageAttributes.m,v 1.2 2006/02/02 13:00:47 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "CMRThreadMessageAttributes.h"
#import "UTILKit.h"


@implementation CMRThreadMessageAttributes
+ (id) attributesWithStatus : (UInt32) status
{
	return [[[self alloc] initWithStatus : status] autorelease];
}
- (id) initWithStatus : (UInt32) status
{
	if(self = [super init]){
		[self setStatus : status];
	}
	return self;
}

// NSObject
- (BOOL) isEqual : (id) other
{
	if (other == self) return YES;
	if (nil == other || NO == [other isKindOfClass : [self class]])
		return NO;
	
	return ([self flags] == [other flags]);
}
- (id) copyWithZone : (NSZone *) aZone
{
	id		tmp;
	
	tmp = [[[self class] allocWithZone : aZone]
				initWithStatus : [self status]];
	[tmp setFlags : [self flags]];
	
	return tmp;
}

// CMRPropertyListCoding
+ (id) objectWithPropertyListRepresentation : (id) rep;
{
	UInt32		version_;
	UInt32		flags_;
	
	UTILRequireCondition(
		(rep != nil && [rep respondsToSelector : @selector(unsignedIntValue)]),
		ErrRepresentation);
	
	flags_ = [rep unsignedIntValue];
	
	version_ = (flags_ & MA_VERSION_MASK);
	if (0 == version_) {
		// 旧バージョンかもしれない
		if (flags_ & MA_VERSION_1_0_MAGIC) {
/*
			NSLog(
				@"***REPORT***\n"
				@"MessageAttributes format was version 1.0, so convert it.");
*/
			flags_ &= (~MA_VERSION_1_0_MAGIC);
			flags_ &= MA_VERSION_1_1_MAGIC;
		}
	}
	
	UTILRequireCondition(
		((flags_ & MA_VERSION_1_1_MAGIC) > 0), 
		ErrRepresentation);
	
	flags_ &= MA_FL_NOT_TEMP_MASK;
	return [self attributesWithStatus : (unsigned int)flags_];
	
ErrRepresentation:
	return nil;
}
- (id) propertyListRepresentation;
{
	UInt32		flags_ = [self status];
	
	// [self status] がすでに一時フラグを除去している
	flags_ |= MA_VERSION_1_1_MAGIC;
	return [NSNumber numberWithUnsignedInt : flags_];
}

- (void) addAttributes : (CMRThreadMessageAttributes *) anAttrs
{
	UInt32		flags_ = _flags;
	
	if(nil == anAttrs)
		return;
	
	flags_ |= [anAttrs flags];
	_flags = flags_;
}

//////////////////////////////////////////////////////////////////////
////////////////////////// [ _flags ] ////////////////////////////////
//////////////////////////////////////////////////////////////////////
- (UInt32) status
{
	return (_flags & MA_FL_NOT_TEMP_MASK);
}
- (UInt32) flags
{
	return _flags;
}

- (BOOL) isVisible
{
	return (NO == [self isInvisibleAboned] && NO == [self isTemporaryInvisible]);
}
// あぼーん
- (BOOL) isAboned
{
	return [self flagAt:ABONED_FLAG];
}
// ローカルあぼーん
- (BOOL) isLocalAboned
{
	return [self flagAt:LOCAL_ABONED_FLAG];
}
// 透明あぼーん
- (BOOL) isInvisibleAboned
{
	return [self flagAt:INVISIBLE_ABONED_FLAG];
}
// AA
- (BOOL) isAsciiArt
{
	return [self flagAt:ASCII_ART_FLAG];
}
// ブックマーク
// Finder like label, 3bit unsigned integer value.
- (unsigned) bookmark
{
	return BOOKMARK2INT([self flags]);
}

// このレスは壊れています
- (BOOL) isInvalid
{
	return [self flagAt:INVALID_FLAG];
}

// 迷惑レス
- (BOOL) isSpam
{
	return [self flagAt:SPAM_FLAG];
}



// Visible Range
- (BOOL) isTemporaryInvisible
{
	return [self flagAt:TEMP_INVISIBLE_FLAG];
}
//@end



//@implementation CMRThreadMessageAttributes(Private)
- (void) setFlags : (UInt32) flags;
{
	_flags = flags;
}
- (BOOL) flagAt : (UInt32) flag
{
	return ((_flags & flag) > 0);
}
- (void) setFlag : (UInt32) flag
			  on : (BOOL  ) isSet
{
	_flags = isSet ? (_flags | flag) : (_flags & ~flag);
}

- (void) setStatus : (UInt32) aStatus
{
	UInt32 status_ = aStatus;
	
	status_ = (status_ & MA_FL_NOT_TEMP_MASK);
	_flags = (_flags | status_);
}
@end
