/**
  * $Id: CMRThreadUserStatus.m,v 1.1.1.1.4.1 2006/01/29 12:58:10 masakih Exp $
  * 
  * CMRThreadUserStatus.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadUserStatus.h"
#import "UTILKit.h"



@implementation CMRThreadUserStatus
+ (id) statusWithUInt32Value : (UInt32) flags
{
	return [[[self alloc] initWithUInt32Value : flags] autorelease];
}
- (id) initWithUInt32Value : (UInt32) flags
{
	if(self = [super init]){
		[self setFlags : flags];
	}
	return self;
}

- (UInt32) flags
{
	return _flags;
}
- (void) setFlags : (UInt32) aFlags
{
	_flags = aFlags;
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
				initWithUInt32Value : [self flags]];
	
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
	version_ = (flags_ & TUS_VERSION_MASK);
	
	UTILRequireCondition(
		(version_ == TUS_VERSION_1_0_MAGIC), 
		ErrRepresentation);
	
	flags_ &= TUS_FL_NOT_TEMP_MASK;
	return [self statusWithUInt32Value : flags_];
	
ErrRepresentation:
	return nil;
}
- (id) propertyListRepresentation;
{
	UInt32		flags_ = [self flags];
	
	flags_ |= TUS_VERSION_1_0_MAGIC;
	return [NSNumber numberWithUnsignedInt : flags_];
}

// AA 
- (BOOL) isAAThread
{
	return (([self flags] & TUS_ASCII_ART_FLAG) > 0);
}
- (void) setAAThread : (BOOL) setOn
{
	_flags = setOn ? (_flags|TUS_ASCII_ART_FLAG) : (_flags&~TUS_ASCII_ART_FLAG);
}
- (BOOL) isDatOchiThread
{
	return (([self flags] & TUS_DAT_OCHI_FLAG) > 0);
}
- (void) setDatOchiThread : (BOOL) setOn
{
	_flags = setOn ? (_flags|TUS_DAT_OCHI_FLAG) : (_flags&~TUS_DAT_OCHI_FLAG);
}- (BOOL) isMarkedThread
{
	return (([self flags] & TUS_MARKED_FLAG) > 0);
}
- (void) setMarkedThread : (BOOL) setOn
{
	_flags = setOn ? (_flags|TUS_MARKED_FLAG) : (_flags&~TUS_MARKED_FLAG);
}
@end
