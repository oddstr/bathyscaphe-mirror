//
//  CMRMessageSample.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/12/03.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "CMRMessageSample.h"

#import "CocoMonar_Prefix.h"
#import "CMRThreadMessage.h"
#import "CMRThreadSignature.h"

#define kMessageKey			@"Message"
#define kThreadIDKey		@"Thread"
#define kFlagsKey			@"Flags"
#define kMatchedCount		@"MatchedCount"

@implementation CMRMessageSample
+ (id) sampleWithMessage : (CMRThreadMessage   *) aMessage
			  withThread : (CMRThreadSignature *) aThreadIdentifier
{
	return [[[self alloc] initWithMessage:aMessage withThread:aThreadIdentifier] autorelease];
}
- (id) initWithMessage : (CMRThreadMessage   *) aMessage
			withThread : (CMRThreadSignature *) aThreadIdentifier
{
	if (self = [super init]) {
		[self setMessage : aMessage];
		[self setThreadIdentifier : aThreadIdentifier];
	}
	return self;
}

- (void) dealloc
{
	[_message release];
	[_threadIdentifier release];
	[super dealloc];
}

- (BOOL) isEqual : (id) anObject
{
	CMRThreadMessage	*m1, *m2;
	
	if (nil == anObject) return NO;
	if (self == anObject) return YES;
	
	if (NO == [anObject isKindOfClass : [self class]])
		return NO;
	if (NO == [[self threadIdentifier] isEqual : [anObject threadIdentifier]])
		return NO;
	
	m1 = [self message];
	m2 = [(CMRMessageSample*)anObject message];
	
	if (m1 == m2) return YES;
	if (NO == [[m1 name] isEqualToString : [m2 name]]) return NO;
	if (NO == [[m1 IDString] isEqualToString : [m2 IDString]]) return NO;
	if (NO == [[m1 messageSource] isEqualToString : [m2 messageSource]]) return NO;
	
	
	return YES;
}

- (UInt32) flags
{
	return _flags;
}
- (void) setFlags : (UInt32) aFlags
{
	_flags = aFlags;
}
- (UInt32) matchedCount
{
	return _matchedCount;
}
- (void) setMatchedCount : (UInt32) aMatchedCount
{
	_matchedCount = aMatchedCount;
}
- (void) incrementMatchedCount
{
	_matchedCount++;
}

- (CMRThreadMessage *) message
{
	return _message;
}
- (CMRThreadSignature *) threadIdentifier
{
	return _threadIdentifier;
}
- (void) setMessage : (CMRThreadMessage *) aMessage
{
	id		tmp;
	
	tmp = _message;
	_message = [aMessage retain];
	[tmp release];
}
- (void) setThreadIdentifier : (CMRThreadSignature *) aThreadIdentifier
{
	id		tmp;
	
	tmp = _threadIdentifier;
	_threadIdentifier = [aThreadIdentifier retain];
	[tmp release];
}

#pragma mark  CMRPropertyListCoding

- (BOOL) initializeWithPropertyListRepresentation : (id) rep
{
	id		v;
	
	if (NO == [rep isKindOfClass : [NSDictionary class]]) {
		return NO;
	}
	[self setMessage :
		[CMRThreadMessage objectWithPropertyListRepresentation :
			[rep objectForKey : kMessageKey]]];
	[self setThreadIdentifier :
		[CMRThreadSignature objectWithPropertyListRepresentation :
			[rep objectForKey : kThreadIDKey]]];
	
	v = [rep numberForKey : kFlagsKey];
	if (v != nil) [self setFlags : [v unsignedIntValue]];
	v = [rep numberForKey : kMatchedCount];
	if (v != nil) [self setMatchedCount : [v unsignedIntValue]];
	
	return YES;
}
- (id) initWithPropertyListRepresentation : (id) rep
{
	if (self = [self init]) {
		if (NO == [self initializeWithPropertyListRepresentation:rep]) {
			[self release];
			return nil;
		}
	}
	return self;
}
+ (id) objectWithPropertyListRepresentation : (id) rep
{
	return [[[self alloc] initWithPropertyListRepresentation : rep] autorelease];
}
- (id) propertyListRepresentation
{
	NSMutableDictionary		*rep;
	
	rep = [NSMutableDictionary dictionary];
	[rep setNoneNil : [[self message] propertyListRepresentation]
			 forKey : kMessageKey];
	[rep setNoneNil : [[self threadIdentifier] propertyListRepresentation]
			 forKey : kThreadIDKey];
	[rep setUnsignedInt : [self flags]
			 	 forKey : kFlagsKey];
	[rep setUnsignedInt : [self matchedCount]
			 	 forKey : kMatchedCount];
	
	return rep;
}
@end
