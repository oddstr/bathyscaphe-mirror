//
//  BSNGExpression.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/08/09.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSNGExpression.h"
#import <OgreKit/OgreKit.h>

static NSString *const kExpressionKey = @"Expression";
static NSString *const kTargetMaskKey = @"TargetMask";
static NSString *const kIsRegularExpressionKey = @"RegularExpression";
static NSString *const kOGRegExpInstanceKey = @"OGRegularExpressionInstanceArchive";

NSString *const BSNGExpressionErrorDomain = @"BSNGExpressionErrorDomain";

@implementation BSNGExpression
- (id)init
{
	return [self initWithExpression:nil targetMask:(BSNGExpressionAtName|BSNGExpressionAtMail|BSNGExpressionAtMessage) regularExpression:NO];
}

- (OGRegularExpression *)createOGRegExpInstance
{
	if (![self expression] || ![self validAsRegularExpression]) return nil;

	OGRegularExpression *regExp = [[OGRegularExpression alloc] initWithString:[self expression]];
	return [regExp autorelease];
}

- (id)initWithExpression:(NSString *)string targetMask:(unsigned int)mask regularExpression:(BOOL)isRE
{
	if (self = [super init]) {
		[self setTargetMask:mask];
		[self setIsRegularExpression:isRE];
		[self setExpression:string];
	}
	return self;
}

- (void)dealloc
{
	[self setOGRegExpInstance:nil];
	[self setExpression:nil];
	[super dealloc];
}

#pragma mark Accessors
- (NSString *)expression
{
	return m_NGExpression;
}

- (void)setExpression:(NSString *)string
{
	[string retain];
	[m_NGExpression release];
	m_NGExpression = string;

	[self setOGRegExpInstance:nil];
}

- (unsigned int)targetMask
{
	return m_NGTargetMask;
}

- (void)setTargetMask:(unsigned int)mask
{
	m_NGTargetMask = mask;
}

- (BOOL)isLogicalANDForMask:(unsigned int)mask
{
	return ([self targetMask] & mask);
}

- (void)setBool:(BOOL)boolValue forMask:(unsigned int)mask
{
	unsigned int baseMask = [self targetMask];
	if (boolValue) {
		baseMask |= mask;
	} else {
		baseMask ^= mask;
	}
	[self setTargetMask:baseMask];
}

- (BOOL)checksName
{
	return [self isLogicalANDForMask:BSNGExpressionAtName];
}

- (void)setChecksName:(BOOL)check
{
	[self setBool:check forMask:BSNGExpressionAtName];
}

- (BOOL)checksMail
{
	return ([self targetMask] & BSNGExpressionAtMail);
}

- (void)setChecksMail:(BOOL)check
{
	[self setBool:check forMask:BSNGExpressionAtMail];
}

- (BOOL)checksMessage
{
	return ([self targetMask] & BSNGExpressionAtMessage);
}

- (void)setChecksMessage:(BOOL)check
{
	[self setBool:check forMask:BSNGExpressionAtMessage];
}

- (BOOL)isRegularExpression
{
	return m_isRegularExpression;
}

- (void)setIsRegularExpression:(BOOL)isRE
{
	m_isRegularExpression = isRE;
	if (!isRE) [self setOGRegExpInstance:nil];
}

- (BOOL)validateIsRegularExpression:(id *)ioValue error:(NSError **)outError
{
	if ([*ioValue boolValue]) {
		if (![self expression] || [self validAsRegularExpression]) {
			return YES;
		} else {
			NSString *errorString = NSLocalizedString(@"BSNGExpression setIsRegularExpression Error", @"");
			NSDictionary *userInfoDict = [NSDictionary dictionaryWithObject:errorString forKey:NSLocalizedDescriptionKey];
			NSError *error = [[[NSError alloc] initWithDomain:BSNGExpressionErrorDomain code:-1 userInfo:userInfoDict] autorelease];
			*outError = error;
			return NO;
		}
	} else {
		return YES;
	}
}

- (BOOL)validAsRegularExpression
{
	return [OGRegularExpression isValidExpressionString:[self expression]];
}

- (OGRegularExpression *)OGRegExpInstance
{
	if (!m_OGRegExpInstance && [self isRegularExpression]) {
		m_OGRegExpInstance = [[self createOGRegExpInstance] retain];
	}
	return m_OGRegExpInstance;
}

- (void)setOGRegExpInstance:(OGRegularExpression *)instance
{
	[instance retain];
	[m_OGRegExpInstance release];
	m_OGRegExpInstance = instance;
}

#pragma mark NSObject
- (unsigned)hash
{
	return [[self expression] hash];
}

- (BOOL)isEqual:(id)anObject
{
	if (![anObject isKindOfClass: [self class]]) return NO;
	return [[self expression] isEqual:[anObject expression]];
}

#pragma mark CMRPropertyListCoding
+ (id)objectWithPropertyListRepresentation:(id)rep
{
    if (!rep || ![rep isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

	id instance;
	NSData *archivedData;
	instance = [[[self class] alloc] init];
	[instance setExpression:[rep stringForKey:kExpressionKey]];
	[instance setTargetMask:[rep unsignedIntForKey:kTargetMaskKey]];
	[instance setIsRegularExpression:[rep boolForKey:kIsRegularExpressionKey]];
	if (archivedData = [rep objectForKey:kOGRegExpInstanceKey]) {
		[instance setOGRegExpInstance:[NSKeyedUnarchiver unarchiveObjectWithData:archivedData]];
	}
	return [instance autorelease];
}

- (id)propertyListRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	OGRegularExpression	*regExp;
	[dict setNoneNil:[self expression] forKey:kExpressionKey];
	[dict setNoneNil:[NSNumber numberWithUnsignedInt:[self targetMask]] forKey:kTargetMaskKey];
	[dict setNoneNil:[NSNumber numberWithBool:[self isRegularExpression]] forKey:kIsRegularExpressionKey];
	if (regExp = [self OGRegExpInstance]) {
		[dict setObject:[NSKeyedArchiver archivedDataWithRootObject:regExp] forKey:kOGRegExpInstanceKey];
	}
	return (NSDictionary *)dict;
}
@end
