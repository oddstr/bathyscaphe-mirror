//
//  CMRMessageSample.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/12/03.
//  Copyright 2006-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRMessageSample.h"

#import "CocoMonar_Prefix.h"
#import "CMRThreadMessage.h"
#import "CMRThreadSignature.h"

#define kMessageKey			@"Message"
#define kThreadIDKey		@"Thread"
#define kFlagsKey			@"Flags"
#define kMatchedCount		@"MatchedCount"
#define kDateKey			@"SampledDate" // Available in BathyScaphe 1.6.2 and later.

@implementation CMRMessageSample
+ (id)sampleWithMessage:(CMRThreadMessage *)aMessage withThread:(CMRThreadSignature *)aThreadIdentifier
{
	return [[[self alloc] initWithMessage:aMessage withThread:aThreadIdentifier] autorelease];
}

- (id)initWithMessage:(CMRThreadMessage *)aMessage withThread:(CMRThreadSignature *)aThreadIdentifier
{
	if (self = [super init]) {
		[self setMessage:aMessage];
		[self setThreadIdentifier:aThreadIdentifier];
		[self setSampledDate:[NSDate date]];
	}
	return self;
}

- (void)dealloc
{
	[self setSampledDate:nil];
	[self setThreadIdentifier:nil];
	[self setMessage:nil];
	[super dealloc];
}

- (NSString *)description
{
	return [[self sampledDate] description];
}

- (BOOL)isEqual:(id)anObject
{
	CMRThreadMessage	*m1, *m2;
	
	if (!anObject) return NO;
	if (self == anObject) return YES;
	
	if (![anObject isKindOfClass:[self class]]) return NO;
	if (![[self threadIdentifier] isEqual:[anObject threadIdentifier]]) return NO;
	
	m1 = [self message];
	m2 = [(CMRMessageSample*)anObject message];
	
	if (m1 == m2) return YES;
	if (![[m1 name] isEqualToString:[m2 name]]) return NO;
	if (![[m1 IDString] isEqualToString:[m2 IDString]]) return NO;
	if (![[m1 messageSource] isEqualToString:[m2 messageSource]]) return NO;	
	
	return YES;
}

- (unsigned)hash
{
	CMRThreadMessage	*msg = [self message];
	unsigned hash1, hash2, hash3;

	hash1 = [[msg name] hash];
	hash2 = [[msg IDString] hash];
	hash3 = [[msg messageSource] hash];
	
	return ([[self threadIdentifier] hash] ^ hash1 ^ hash2 ^ hash3);
}

#pragma mark Accessors
- (UInt32)flags
{
	return _flags;
}

- (void)setFlags:(UInt32)aFlags
{
	_flags = aFlags;
}

- (UInt32)matchedCount
{
	return _matchedCount;
}

- (void)setMatchedCount:(UInt32)aMatchedCount
{
	_matchedCount = aMatchedCount;
}

- (void)incrementMatchedCount
{
	_matchedCount++;
}

- (CMRThreadMessage *)message
{
	return _message;
}

- (void)setMessage:(CMRThreadMessage *)aMessage
{
	[aMessage retain];
	[_message release];
	_message = aMessage;
}

- (CMRThreadSignature *)threadIdentifier
{
	return _threadIdentifier;
}

- (void)setThreadIdentifier:(CMRThreadSignature *)aThreadIdentifier
{
	[aThreadIdentifier retain];
	[_threadIdentifier release];
	_threadIdentifier = aThreadIdentifier;
}

- (NSDate *)sampledDate
{
	return _sampledDate;
}

- (void)setSampledDate:(NSDate *)date
{
	[date retain];
	[_sampledDate release];
	_sampledDate = date;
}

#pragma mark CMRPropertyListCoding
- (BOOL)initializeWithPropertyListRepresentation:(id)rep
{
	id	v;
	
	if (![rep isKindOfClass:[NSDictionary class]]) {
		return NO;
	}

	[self setMessage:[CMRThreadMessage objectWithPropertyListRepresentation:[rep objectForKey:kMessageKey]]];
	[self setThreadIdentifier:[CMRThreadSignature objectWithPropertyListRepresentation:[rep objectForKey:kThreadIDKey]]];
	
	v = [rep numberForKey:kFlagsKey];
	if (v) [self setFlags:[v unsignedIntValue]];
	v = [rep numberForKey:kMatchedCount];
	if (v) [self setMatchedCount:[v unsignedIntValue]];

	// tsawada2 2008-06-09:dateのない古いプロパティリストレプリゼンテーションにはどう対応するか？
	v = [rep objectForKey:kDateKey];
	if (v && [v isKindOfClass:[NSDate class]]) {
		[self setSampledDate:v];
	} else {
		[self setSampledDate:[NSDate date]];
	}
	return YES;
}

- (id)initWithPropertyListRepresentation:(id)rep
{
	if (self = [super init]) {
		if (![self initializeWithPropertyListRepresentation:rep]) {
			[self release];
			return nil;
		}
	}
	return self;
}

+ (id)objectWithPropertyListRepresentation:(id)rep
{
	return [[[self alloc] initWithPropertyListRepresentation:rep] autorelease];
}

- (id)propertyListRepresentation
{
	NSMutableDictionary		*rep;
	
	rep = [NSMutableDictionary dictionary];
	[rep setNoneNil:[[self message] propertyListRepresentation] forKey:kMessageKey];
	[rep setNoneNil:[[self threadIdentifier] propertyListRepresentation] forKey:kThreadIDKey];
	[rep setUnsignedInt:[self flags] forKey:kFlagsKey];
	[rep setUnsignedInt:[self matchedCount] forKey:kMatchedCount];
	[rep setNoneNil:[self sampledDate] forKey:kDateKey];
	
	return rep;
}
@end
