//: CMRThreadVisibleRange.m
/**
  * $Id: CMRThreadVisibleRange.m,v 1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "CMRThreadVisibleRange.h"


//////////////////////////////////////////////////////////////////////
////////////////////// [ 定数やマクロ置換 ] //////////////////////////
//////////////////////////////////////////////////////////////////////
static NSString *const CMRThreadFirstVisibleLengthKey	= @"First Visible Length";
static NSString *const CMRThreadLastVisibleLengthKey	= @"Last Visible Length";


static UInt32 pack_UInt32Rep(unsigned high, unsigned low);
static void unpack_UInt32Rep(UInt32 v, unsigned *high, unsigned *low);

// 現在のデフォルト
static id kDefaultVisibleRangeInstance_ = nil;
static const unsigned CMRThreadDefaultFirstVisibleNumber = 1;
static const unsigned CMRThreadDefaultLastVisibleNumber  = 50;


@interface CMRThreadVisibleRange(Private)
- (void) setFirstVisibleLength : (unsigned) aFirstVisibleLength;
- (void) setLastVisibleLength : (unsigned) aLastVisibleLength;
@end



@implementation CMRThreadVisibleRange
+ (CMRThreadVisibleRange *) defaultVisibleRange
{
    if (nil == kDefaultVisibleRangeInstance_) {
        NSNumber *n;
        unsigned first;
        unsigned last;
        
        n = SGTemplateResource(@"Thread - FirstVisible");
        if (NO == [n respondsToSelector : @selector(unsignedIntValue)]) 
        { first = CMRThreadDefaultFirstVisibleNumber; }
        else
        { first = [n unsignedIntValue]; }
        
        n = SGTemplateResource(@"Thread - LastVisible");
        if (NO == [n respondsToSelector : @selector(unsignedIntValue)]) 
        { last = CMRThreadDefaultLastVisibleNumber; }
        else
        { last = [n unsignedIntValue]; }
        
        if (first < 0) first = CMRThreadShowAll;
        if (last < 0) last = CMRThreadShowAll;
        
        [self setDefaultVisibleRange : 
             [[self class] visibleRangeWithFirstVisibleLength : first
                        lastVisibleLength : last]];
    }
    return [[kDefaultVisibleRangeInstance_ copy] autorelease];
}
+ (void) setDefaultVisibleRange : (CMRThreadVisibleRange *) newVRange
{
	kDefaultVisibleRangeInstance_ = [newVRange copy];
}


+ (id) visibleRangeWithFirstVisibleLength : (unsigned) aFirstVisibleLength
						lastVisibleLength : (unsigned) aLastVisibleLength
{
	return [[[self alloc] initWithFirstVisibleLength : aFirstVisibleLength
					lastVisibleLength : aLastVisibleLength] autorelease];
}
- (id) initWithFirstVisibleLength : (unsigned) aFirstVisibleLength
				lastVisibleLength : (unsigned) aLastVisibleLength
{
	if (self = [self init]) {
		[self setFirstVisibleLength : aFirstVisibleLength];
		[self setLastVisibleLength : aLastVisibleLength];
	}
	return self;
}

+ (id) visibleRangeWithUInt32Representation : (UInt32) uint32Value
{
	return [[[self alloc] initWithUInt32Representation : uint32Value] autorelease];
}

- (id) initWithUInt32Representation : (UInt32) uint32Value
{
	if (self = [super init]) {
		[self initializeFromUInt32Representation : uint32Value];
		
	}
	return self;
}
+ (id) objectWithPropertyListRepresentation : (id) rep
{
	if (nil == rep)
		return nil;
	
	return [[[self alloc] initWithPropertyListRepresentation : rep] autorelease];
}
- (id) initWithPropertyListRepresentation : (id) rep
{
	if (self = [self init]) {
		if (NO == [self initializeFromPropertyListRepresentation : rep]) {
			[self autorelease];
			return nil;
		}
	}
	return self;
}
- (id) propertyListRepresentation { return [self dictionaryRepresentation]; }
- (BOOL) initializeFromPropertyListRepresentation : (id) rep
{
	if ([rep isKindOfClass : [NSString class]]) {
		return [self initializeFromStringRepresentation : rep];
	} else if ([rep isKindOfClass : [NSNumber class]]) {
		return [self initializeFromUInt32Representation : 
					[rep unsignedLongValue]];
	} else if ([rep isKindOfClass : [NSDictionary class]]) {
		return [self initializeFromDictionaryRepresentation : rep];
	}
	return NO;
}

- (NSDictionary *) dictionaryRepresentation
{
	NSDictionary		*dict_;
	
	dict_ = [NSDictionary dictionaryWithObjectsAndKeys : 
				[NSNumber numberWithUnsignedInt : [self firstVisibleLength]],
				CMRThreadFirstVisibleLengthKey,
				[NSNumber numberWithUnsignedInt : [self lastVisibleLength]],
				CMRThreadLastVisibleLengthKey,
				nil];
	
	return dict_;
}
- (UInt32) UInt32Representation
{
	return pack_UInt32Rep(_firstVisibleLength, _lastVisibleLength);
}

- (NSString *) stringRepresentation
{
	return NSStringFromRange(
			NSMakeRange([self firstVisibleLength], [self lastVisibleLength]));
}

- (BOOL) initializeFromStringRepresentation : (NSString *) s
{
	NSRange		r;
	
	if (nil == s) return NO;
	
	r = NSRangeFromString(s);
	_firstVisibleLength = r.location;
	_lastVisibleLength = r.length;
	return YES;
}
- (BOOL) initializeFromUInt32Representation : (UInt32) n
{
	unpack_UInt32Rep(
		n,
		&_firstVisibleLength,
		&_lastVisibleLength);
	
	return YES;
}
- (BOOL) initializeFromDictionaryRepresentation : (NSDictionary *) rep
{
	unsigned		firstVisibleLength_;
	unsigned		lastVisibleLength_;
	
	if (nil == rep) return NO;
	
	firstVisibleLength_ = [rep unsignedIntForKey : CMRThreadFirstVisibleLengthKey];
	lastVisibleLength_ = [rep unsignedIntForKey : CMRThreadLastVisibleLengthKey];
	
	[self setFirstVisibleLength : firstVisibleLength_];
	[self setLastVisibleLength : lastVisibleLength_];
	
	return YES;
}

- (BOOL) isShownAll
{
	return (CMRThreadShowAll == [self firstVisibleLength] ||
		CMRThreadShowAll == [self lastVisibleLength]);
}
- (BOOL) isEmpty
{
	return (0 == [self firstVisibleLength] && 0 == [self lastVisibleLength]);
}

/* Accessor for _firstVisibleLength */
- (unsigned) firstVisibleLength
{
	return _firstVisibleLength;
}
/* Accessor for _lastVisibleLength */
- (unsigned) lastVisibleLength
{
	return _lastVisibleLength;
}
- (unsigned) visibleLength
{
	if ([self isShownAll])
		return CMRThreadShowAll;
	
	return [self firstVisibleLength] + [self lastVisibleLength];
}

// NSObject
- (BOOL) isEqual : (id) other
{
	BOOL	isEqual_;
	
	if (self == other) return YES;
	if (nil == other || NO == [other isKindOfClass : [self class]])
		return NO;
	
	isEqual_ = ([self firstVisibleLength] == [other firstVisibleLength]);
	isEqual_ = isEqual_ && ([self lastVisibleLength] == [other lastVisibleLength]);
	
	return isEqual_;
}

- (NSString *) description
{
	return [NSString stringWithFormat : 
						@"(%@) {%u, %u} <%p>",
						NSStringFromClass([self class]),
						[self firstVisibleLength],
						[self lastVisibleLength],
						self];
}

// NSCopying
- (id) copyWithZone : (NSZone *) aZone
{
	id		tmp;
	
	tmp = [[[self class] allocWithZone : aZone] 
			initWithFirstVisibleLength : [self firstVisibleLength]
			lastVisibleLength : [self lastVisibleLength]];
	
	return tmp;
}
@end



@implementation CMRThreadVisibleRange(Private)
- (void) setFirstVisibleLength : (unsigned) aFirstVisibleLength
{
	_firstVisibleLength = aFirstVisibleLength;
}
- (void) setLastVisibleLength : (unsigned) aLastVisibleLength
{
	_lastVisibleLength = aLastVisibleLength;
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
}
