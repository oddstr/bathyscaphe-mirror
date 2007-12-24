//
//  BSReplyTextTemplate.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/12/20.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSReplyTextTemplate.h"
#import "CocoMonar_Prefix.h"

static NSString *const kTemplatePlistDisplayNameKey = @"DisplayName";
static NSString *const kTemplatePlistShortcutKey = @"Shortcut";
static NSString *const kTemplatePlistTemplateKey = @"Content";

@implementation BSReplyTextTemplate
- (id)init
{
	if (self = [super init]) {
		[self setDisplayName:@"Untitled"];
		// 他はとりあえず後で…
	}
	return self;
}

- (void)dealloc
{
	[self setDisplayName:nil];
	[self setShortcutKeyword:nil];
	[self setTemplate:nil];
	[super dealloc];
}

#pragma mark Accessors
- (NSString *)displayName
{
	return m_displayName;
}

- (void)setDisplayName:(NSString *)aString
{
	[aString retain];
	[m_displayName release];
	m_displayName = aString;
}

- (NSString *)shortcutKeyword;
{
	return m_shortcutKeyword;
}

- (void)setShortcutKeyword:(NSString *)aString
{
	[aString retain];
	[m_shortcutKeyword release];
	m_shortcutKeyword = aString;
}

- (NSString *)template
{
	return m_template;
}

- (void)setTemplate:(NSString *)aString
{
	[aString retain];
	[m_template release];
	m_template = aString;
}

- (NSString *)templateDescription
{
	return nil;
}

#pragma mark NSCoding Protocol
- (id)initWithCoder:(NSCoder *)decoder
{
	if (self = [super init]) {
		[self setDisplayName:[decoder decodeObjectForKey:kTemplatePlistDisplayNameKey]];
		[self setShortcutKeyword:[decoder decodeObjectForKey:kTemplatePlistShortcutKey]];
		[self setTemplate:[decoder decodeObjectForKey:kTemplatePlistTemplateKey]];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:[self template] forKey:kTemplatePlistTemplateKey];
	[encoder encodeObject:[self shortcutKeyword] forKey:kTemplatePlistShortcutKey];
	[encoder encodeObject:[self displayName] forKey:kTemplatePlistDisplayNameKey];
}

#pragma mark CMRPropertyListCoding Protocol
+ (id)objectWithPropertyListRepresentation:(id)rep
{
    if (!rep || ![rep isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

	id instance;
	instance = [[[self class] alloc] init];
	[instance setDisplayName:[rep stringForKey:kTemplatePlistDisplayNameKey]];
	[instance setShortcutKeyword:[rep stringForKey:kTemplatePlistShortcutKey]];
	[instance setTemplate:[rep stringForKey:kTemplatePlistTemplateKey]];
	return [instance autorelease];
}

- (id)propertyListRepresentation
{
	if (![self displayName] || [[self displayName] length] == 0) return nil;
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:3];

	[dictionary setObject:[self displayName] forKey:kTemplatePlistDisplayNameKey];
	[dictionary setNoneNil:[self shortcutKeyword] forKey:kTemplatePlistShortcutKey];
	[dictionary setNoneNil:[self template] forKey:kTemplatePlistTemplateKey];

	return dictionary;
}
@end
