//
//  CMRThreadVisibleRange.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/09/23.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRThreadVisibleRange.h"

static NSString *const CMRThreadFirstVisibleLengthKey	= @"First Visible Length";
static NSString *const CMRThreadLastVisibleLengthKey	= @"Last Visible Length";


//static UInt32 pack_UInt32Rep(unsigned high, unsigned low);
//static void unpack_UInt32Rep(UInt32 v, unsigned *high, unsigned *low);


@implementation CMRThreadVisibleRange
+ (id)visibleRangeWithFirstVisibleLength:(unsigned)aFirstVisibleLength
					   lastVisibleLength:(unsigned)aLastVisibleLength
{
	return [[[self alloc] initWithFirstVisibleLength:aFirstVisibleLength
								   lastVisibleLength:aLastVisibleLength] autorelease];
}

- (id)initWithFirstVisibleLength:(unsigned)aFirstVisibleLength
			   lastVisibleLength:(unsigned)aLastVisibleLength
{
	if (self = [self init]) {
		[self setFirstVisibleLength:aFirstVisibleLength];
		[self setLastVisibleLength:aLastVisibleLength];
	}
	return self;
}

#pragma mark CMRPropertyListCoding
+ (id)objectWithPropertyListRepresentation:(id)rep
{
	if (!rep) return nil;
	
	return [[[self alloc] initWithPropertyListRepresentation:rep] autorelease];
}

- (id)initWithPropertyListRepresentation:(id)rep
{
	if (self = [self init]) {
		if (![self initializeFromPropertyListRepresentation:rep]) {
			[self autorelease];
			return nil;
		}
	}
	return self;
}

- (id)propertyListRepresentation
{
	return [self dictionaryRepresentation];
}

- (BOOL)initializeFromPropertyListRepresentation:(id)rep
{
/*	if ([rep isKindOfClass:[NSString class]]) {
		return [self initializeFromStringRepresentation:rep];
	} else if ([rep isKindOfClass:[NSNumber class]]) {
		return [self initializeFromUInt32Representation:[rep unsignedLongValue]];
	} else */if ([rep isKindOfClass:[NSDictionary class]]) {
		return [self initializeFromDictionaryRepresentation:rep];
	}
	return NO;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSDictionary		*dict_;
	
	dict_ = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithUnsignedInt:[self firstVisibleLength]],
				CMRThreadFirstVisibleLengthKey,
				[NSNumber numberWithUnsignedInt:[self lastVisibleLength]],
				CMRThreadLastVisibleLengthKey,
				NULL];

	return dict_;
}

- (BOOL)initializeFromDictionaryRepresentation:(NSDictionary *)rep
{
	unsigned		firstVisibleLength_;
	unsigned		lastVisibleLength_;
	
	if (!rep) return NO;
	
	firstVisibleLength_ = [rep unsignedIntForKey:CMRThreadFirstVisibleLengthKey];
	lastVisibleLength_ = [rep unsignedIntForKey:CMRThreadLastVisibleLengthKey];
	
	[self setFirstVisibleLength:firstVisibleLength_];
	[self setLastVisibleLength:lastVisibleLength_];
	
	return YES;
}

#pragma mark Accessors
- (BOOL)isShownAll
{
	return (CMRThreadShowAll == [self firstVisibleLength] ||
			CMRThreadShowAll == [self lastVisibleLength]);
}

- (BOOL)isEmpty
{
	return (0 == [self firstVisibleLength] && 0 == [self lastVisibleLength]);
}

- (unsigned)firstVisibleLength
{
	return _firstVisibleLength;
}

- (void) setFirstVisibleLength : (unsigned) aFirstVisibleLength
{
	_firstVisibleLength = aFirstVisibleLength;
}

- (unsigned)lastVisibleLength
{
	return _lastVisibleLength;
}

- (void) setLastVisibleLength : (unsigned) aLastVisibleLength
{
	_lastVisibleLength = aLastVisibleLength;
}

- (unsigned)visibleLength
{
	if ([self isShownAll]) return CMRThreadShowAll;
	
	return [self firstVisibleLength] + [self lastVisibleLength];
}

#pragma mark NSObject
- (BOOL)isEqual:(id)other
{
	BOOL	isEqual_;
	
	if (self == other) return YES;
	if (!other || ![other isKindOfClass:[self class]]) return NO;

	isEqual_ = ([self firstVisibleLength] == [other firstVisibleLength]);
	isEqual_ = isEqual_ && ([self lastVisibleLength] == [other lastVisibleLength]);
	
	return isEqual_;
}

- (NSString *)description
{
	return [NSString stringWithFormat: 
						@"(%@) {%u, %u} <%p>",
						NSStringFromClass([self class]),
						[self firstVisibleLength],
						[self lastVisibleLength],
						self];
}

#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)aZone
{
	id		tmp;

	tmp = [[[self class] allocWithZone:aZone] initWithFirstVisibleLength:[self firstVisibleLength]
													   lastVisibleLength:[self lastVisibleLength]];

	return tmp;
}
@end


/*
@implementation CMRThreadVisibleRange(Deprecated)
+ (CMRThreadVisibleRange *)defaultVisibleRange
{
    NSLog(@"Warning: +[CMRThreadVisibleRange defaultVisibleRange] has been deprecated.");
    return nil;
}

+ (void)setDefaultVisibleRange:(CMRThreadVisibleRange *)newVRange
{
    NSLog(@"Warning: +[CMRThreadVisibleRange setDefaultVisibleRange:] has been deprecated.");
}

- (BOOL)initializeFromUInt32Representation:(UInt32)n
{
	unpack_UInt32Rep(n, &_firstVisibleLength, &_lastVisibleLength);

	return YES;
}

- (id)initWithUInt32Representation:(UInt32)uint32Value
{
	if (self = [super init]) {
		[self initializeFromUInt32Representation:uint32Value];
		
	}
	return self;
}

+ (id)visibleRangeWithUInt32Representation:(UInt32)uint32Value
{
	return [[[self alloc] initWithUInt32Representation:uint32Value] autorelease];
}

- (UInt32)UInt32Representation
{
	return pack_UInt32Rep(_firstVisibleLength, _lastVisibleLength);
}

- (NSString *)stringRepresentation
{
	return NSStringFromRange(NSMakeRange([self firstVisibleLength], [self lastVisibleLength]));
}

- (BOOL)initializeFromStringRepresentation:(NSString *)s
{
	NSRange		r;

	if (!s) return NO;

	r = NSRangeFromString(s);
	_firstVisibleLength = r.location;
	_lastVisibleLength = r.length;
	return YES;
}
@end


#define BIT16MASK		0xFFFF
static UInt32 pack_UInt32Rep(unsigned high, unsigned low)
{
	return ((~BIT16MASK & (high << 16)) | (BIT16MASK & low));
}

static void unpack_UInt32Rep(UInt32 v, unsigned *high, unsigned *low)
{
	*low = (v & BIT16MASK);
	*high = ((v >> 16) & BIT16MASK);
	
	if (BIT16MASK == *low)
		*low = NSNotFound;
	if (BIT16MASK == *high)
		*high = NSNotFound;
		
	return;
}*/
