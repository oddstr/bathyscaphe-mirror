//
//  BSThreadViewTheme.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/03/22.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import "BSThreadViewTheme.h"

NSString *const kThreadViewThemeDefaultThemeIdentifier = @"jp.tsawada2.BathyScaphe.ThreadViewTheme.default";
NSString *const kThreadViewThemeCustomThemeIdentifier = @"jp.tsawada2.BathyScaphe.ThreadViewTheme.custom";

@implementation BSThreadViewTheme
- (NSMutableDictionary *) themeDict
{
	return m_themeDict;
}
- (void) setThemeDict: (NSMutableDictionary *) mutableDict
{
	[mutableDict retain];
	[m_themeDict release];
	m_themeDict = mutableDict;
}
- (NSString *) identifier
{
	return m_identifier;
}
- (void) setIdentifier: (NSString *) aString
{
	[aString retain];
	[m_identifier release];
	m_identifier = aString;
}

- (id) initWithIdentifier: (NSString *) aString
{
	if (self = [super init]) {
		[self setThemeDict: [NSMutableDictionary dictionary]];
		[self setIdentifier: aString];
	}
	return self;
}

- (id) initWithContentsOfFile: (NSString *) filePath
{
	if (self = [NSKeyedUnarchiver unarchiveObjectWithFile: filePath]) {
		[self retain];
	}
	return self;
}

- (BOOL) writeToFile: (NSString *) filePath atomically: (BOOL) atomically
{
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject: self];
	return [data writeToFile: filePath atomically: atomically];
}

- (id) init
{
	return [self initWithIdentifier: @""];
}

- (void) dealloc
{
	[m_themeDict release];
	[m_identifier release];
	[super dealloc];
}

- (id) initWithCoder: (NSCoder *) coder
{
	if (self = [super init]) {
		[self setThemeDict: [coder decodeObjectForKey: @"themeDict"]];
		[self setIdentifier: [coder decodeObjectForKey: @"identifier"]];
	}
	return self;
}

- (void) encodeWithCoder: (NSCoder *) coder
{
	[coder encodeObject: m_themeDict forKey: @"themeDict"];
	[coder encodeObject: m_identifier forKey: @"identifier"];
}

- (id) copyWithZone: (NSZone *) zone
{
	BSThreadViewTheme *tmpcopy;
	NSString *tmpId = [[self identifier] copyWithZone: zone];
	NSMutableDictionary *tmpDict = [[self themeDict] mutableCopyWithZone: zone];
	
	tmpcopy = [[[self class] allocWithZone: zone] initWithIdentifier: tmpId];
	[tmpcopy setThemeDict: tmpDict];
	[tmpId release];
	[tmpDict release];
	
	return tmpcopy;
}
@end

@implementation BSThreadViewTheme(Accessors)
- (NSFont *) baseFont
{
	return [[self themeDict] objectForKey: @"baseFont"];
}
- (void) setBaseFont: (NSFont *) font
{
	[[self themeDict] setObject: font forKey: @"baseFont"];
}

- (NSColor *) baseColor
{
	return [[self themeDict] objectForKey: @"baseColor"];
}
- (void) setBaseColor: (NSColor *) color
{
	[[self themeDict] setObject: color forKey: @"baseColor"];
}

- (NSColor *) nameColor
{
	return [[self themeDict] objectForKey: @"nameColor"];
}
- (void) setNameColor: (NSColor *) color
{
	[[self themeDict] setObject: color forKey: @"nameColor"];
}

- (NSFont *) titleFont
{
	return [[self themeDict] objectForKey: @"titleFont"];
}
- (void) setTitleFont: (NSFont *) font
{
	[[self themeDict] setObject: font forKey: @"titleFont"];
}
- (NSColor *) titleColor
{
	return [[self themeDict] objectForKey: @"titleColor"];
}
- (void) setTitleColor: (NSColor *) color
{
	[[self themeDict] setObject: color forKey: @"titleColor"];
}

- (NSFont *) hostFont
{
	return [[self themeDict] objectForKey: @"hostFont"];
}
- (void) setHostFont: (NSFont *) font
{
	[[self themeDict] setObject: font forKey: @"hostFont"];
}
- (NSColor *) hostColor
{
	return [[self themeDict] objectForKey: @"hostColor"];
}
- (void) setHostColor: (NSColor *) color
{
	[[self themeDict] setObject: color forKey: @"hostColor"];
}

- (NSFont *) beFont
{
	return [[self themeDict] objectForKey: @"beFont"];
}
- (void) setBeFont: (NSFont *) font
{
	[[self themeDict] setObject: font forKey: @"beFont"];
}

- (NSFont *) messageFont
{
	return [[self themeDict] objectForKey: @"messageFont"];
}
- (void) setMessageFont: (NSFont *) font
{
	[[self themeDict] setObject: font forKey: @"messageFont"];
}
- (NSColor *) messageColor
{
	return [[self themeDict] objectForKey: @"messageColor"];
}
- (void) setMessageColor: (NSColor *) color
{
	[[self themeDict] setObject: color forKey: @"messageColor"];
}

- (NSFont *) AAFont
{
	return [[self themeDict] objectForKey: @"AAFont"];
}
- (void) setAAFont: (NSFont *) font
{
	[[self themeDict] setObject: font forKey: @"AAFont"];
}

- (NSFont *) bookmarkFont
{
	return [[self themeDict] objectForKey: @"bookmarkFont"];
}
- (void) setBookmarkFont: (NSFont *) font
{
	[[self themeDict] setObject: font forKey: @"bookmarkFont"];
}
- (NSColor *) bookmarkColor
{
	return [[self themeDict] objectForKey: @"bookmarkColor"];
}
- (void) setBookmarkColor: (NSColor *) color
{
	[[self themeDict] setObject: color forKey: @"bookmarkColor"];
}

- (NSColor *) linkColor
{
	return [[self themeDict] objectForKey: @"linkColor"];
}
- (void) setLinkColor: (NSColor *) color
{
	[[self themeDict] setObject: color forKey: @"linkColor"];
}

- (NSColor *) backgroundColor
{
	return [[self themeDict] objectForKey: @"backgroundColor"];
}
- (void) setBackgroundColor: (NSColor *) color
{
	[[self themeDict] setObject: color forKey: @"backgroundColor"];
}
@end
