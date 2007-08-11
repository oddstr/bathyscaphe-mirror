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

@implementation BSNGExpression
- (id) init
{
	return [self initWithExpression:nil targetMask:(BSNGExpressionAtName|BSNGExpressionAtMail|BSNGExpressionAtMessage) regularExpression:NO];
}

- (id)initWithExpression:(NSString *)string targetMask:(unsigned int)mask regularExpression:(BOOL)isRE
{
	if (self = [super init]) {
		[self setExpression:string];
		[self setTargetMask:mask];
		[self setIsRegularExpression:isRE];
	}
	return self;
}

- (void)dealloc
{
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
}

- (BOOL)validAsRegularExpression
{
	return [OGRegularExpression isValidExpressionString:[self expression]];
}

#pragma mark CMRPropertyListCoding
+ (id)objectWithPropertyListRepresentation:(id)rep
{
    if (!rep || ![rep isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

	id instance;
	instance = [[[self class] alloc] init];
	[instance setExpression:[rep stringForKey:@"Expression"]];
	[instance setTargetMask:[rep unsignedIntForKey:@"TargetMask"]];
	[instance setIsRegularExpression:[rep boolForKey:@"RegularExpression"]];
	return [instance autorelease];
}

- (id)propertyListRepresentation
{
	if (![self expression]) return nil;
	return [NSDictionary dictionaryWithObjectsAndKeys:[self expression], @"Expression",
													  [NSNumber numberWithUnsignedInt:[self targetMask]], @"TargetMask",
													  [NSNumber numberWithBool:[self isRegularExpression]], @"RegularExpression", NULL];
}
@end
