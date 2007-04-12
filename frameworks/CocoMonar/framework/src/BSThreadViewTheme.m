//
//  BSThreadViewTheme.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/03/22.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
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
- (NSMutableDictionary *) additionalThemeDict
{
	return m_additionalThemeDict;
}
- (void) setAdditionalThemeDict: (NSMutableDictionary *) mutableDict
{
	[mutableDict retain];
	[m_additionalThemeDict release];
	m_additionalThemeDict = mutableDict;
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
		[self setIdentifier: aString];
		[self setThemeDict: [NSMutableDictionary dictionary]];
		[self setAdditionalThemeDict: [NSMutableDictionary dictionary]];
		[self setPopupUsesAlternateTextColor: NO];
		[self setPopupBackgroundAlphaValue: 1.0];
		[self setReplyBackgroundAlphaValue: 1.0];
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

+ (void) initialize
{
	if (self == [BSThreadViewTheme class]) {
		[self setKeys: [NSArray arrayWithObjects: @"popupBackgroundColorIgnoringAlpha", @"popupBackgroundAlphaValue", nil]
			  triggerChangeNotificationsForDependentKey: @"popupBackgroundColor"];
		[self setKeys: [NSArray arrayWithObjects: @"replyBackgroundColorIgnoringAlpha", @"replyBackgroundAlphaValue", nil]
			  triggerChangeNotificationsForDependentKey: @"replyBackgroundColor"];
	}
}

- (id) init
{
	return [self initWithIdentifier: @""];
}

- (void) dealloc
{
	[m_additionalThemeDict release];
	[m_themeDict release];
	[m_identifier release];
	[super dealloc];
}

+ (NSMutableDictionary *) defaultAdditionalThemeDict
{
	static NSMutableDictionary *g_template = nil;
	if (g_template == nil) {
		g_template = [[NSMutableDictionary alloc] initWithCapacity: 5];
		[g_template setObject: [NSColor colorWithCalibratedRed: 255.0/255.0 green: 255.0/255.0 blue: 160.0/255.0 alpha: 1.0]
					   forKey: @"popupBackgroundColorBase"];
		[g_template setObject: [NSColor blackColor] forKey: @"popupAlternateTextColor"];
		[g_template setObject: [NSFont systemFontOfSize: 13.0] forKey: @"replyFont"];
		[g_template setObject: [NSColor blackColor] forKey: @"replyColor"];
		[g_template setObject: [NSColor whiteColor] forKey: @"replyBackgroundColorBase"];
	}
	return g_template;
}

- (id) initWithCoder: (NSCoder *) coder
{
	if (self = [super init]) {
		if ([coder allowsKeyedCoding]) {
			[self setIdentifier: [coder decodeObjectForKey: @"identifier"]];
			[self setThemeDict: [coder decodeObjectForKey: @"themeDict"]];
			if (NO == [coder containsValueForKey: @"additionalThemeDict"]) { // old format?
				NSLog(@"We should create default value of additionalThemeDict for old theme archive %@.", [self identifier]);
				[self setAdditionalThemeDict: [[self class] defaultAdditionalThemeDict]];
				[self setPopupUsesAlternateTextColor: NO];
				[self setPopupBackgroundAlphaValue: 0.8];
				[self setReplyBackgroundAlphaValue: 1.0];
			} else {
				[self setAdditionalThemeDict: [coder decodeObjectForKey: @"additionalThemeDict"]];
				[self setPopupUsesAlternateTextColor: [coder decodeBoolForKey: @"popupUsesAltTextColor"]];
				[self setPopupBackgroundAlphaValue: [coder decodeFloatForKey: @"popupBgAlpha"]];
				[self setReplyBackgroundAlphaValue: [coder decodeFloatForKey: @"replyBgAlpha"]];
			}
		}
	}
	return self;
}

- (void) encodeWithCoder: (NSCoder *) coder
{
	if ([coder allowsKeyedCoding]) {
		[coder encodeFloat: m_replyBgAlpha forKey: @"replyBgAlpha"];
		[coder encodeFloat: m_popupBgAlpha forKey: @"popupBgAlpha"];
		[coder encodeBool: m_popupUsesAltTextColor forKey: @"popupUsesAltTextColor"];
		[coder encodeObject: m_additionalThemeDict forKey: @"additionalThemeDict"];
		[coder encodeObject: m_themeDict forKey: @"themeDict"];
		[coder encodeObject: m_identifier forKey: @"identifier"];
	}
}

- (id) copyWithZone: (NSZone *) zone
{
	BSThreadViewTheme *tmpcopy;
	NSString *tmpId = [[self identifier] copyWithZone: zone];
	NSMutableDictionary *tmpDict = [[self themeDict] mutableCopyWithZone: zone];
	NSMutableDictionary *tmpAddDict = [[self additionalThemeDict] mutableCopyWithZone: zone];
	
	tmpcopy = [[[self class] allocWithZone: zone] initWithIdentifier: tmpId];
	[tmpcopy setThemeDict: tmpDict];
	[tmpcopy setAdditionalThemeDict: tmpAddDict];
	[tmpcopy setPopupUsesAlternateTextColor: [self popupUsesAlternateTextColor]];
	[tmpcopy setPopupBackgroundAlphaValue: [self popupBackgroundAlphaValue]];
	[tmpcopy setReplyBackgroundAlphaValue: [self replyBackgroundAlphaValue]];

	[tmpId release];
	[tmpDict release];
	[tmpAddDict release];
	
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

@implementation BSThreadViewTheme(Additions)
- (NSColor *) popupBackgroundColor
{
	return [[self popupBackgroundColorIgnoringAlpha] colorWithAlphaComponent: [self popupBackgroundAlphaValue]];
}
- (NSColor *) popupBackgroundColorIgnoringAlpha;
{
	return [[self additionalThemeDict] objectForKey: @"popupBackgroundColorBase"];
}
- (void) setPopupBackgroundColorIgnoringAlpha: (NSColor *) opaqueColor;
{
	[[self additionalThemeDict] setObject: opaqueColor forKey: @"popupBackgroundColorBase"];
}
- (float) popupBackgroundAlphaValue
{
	return m_popupBgAlpha;
}
- (void) setPopupBackgroundAlphaValue: (float) alpha
{
	m_popupBgAlpha = alpha;
}

- (BOOL) popupUsesAlternateTextColor
{
	return m_popupUsesAltTextColor;
}
- (void) setPopupUsesAlternateTextColor: (BOOL) flag
{
	m_popupUsesAltTextColor = flag;
}
- (NSColor *) popupAlternateTextColor;
{
	return [[self additionalThemeDict] objectForKey: @"popupAlternateTextColor"];
}
- (void) setPopupAlternateTextColor: (NSColor *) color;
{
	[[self additionalThemeDict] setObject: color forKey: @"popupAlternateTextColor"];
}

- (NSFont *) replyFont
{
	return [[self additionalThemeDict] objectForKey: @"replyFont"];
}
- (void) setReplyFont: (NSFont *) font
{
	[[self additionalThemeDict] setObject: font forKey: @"replyFont"];
}
- (NSColor *) replyColor;
{
	return [[self additionalThemeDict] objectForKey: @"replyColor"];
}
- (void) setReplyColor: (NSColor *) color;
{
	[[self additionalThemeDict] setObject: color forKey: @"replyColor"];
}

- (NSColor *) replyBackgroundColor
{
	return [[self replyBackgroundColorIgnoringAlpha] colorWithAlphaComponent: [self replyBackgroundAlphaValue]];
}
- (NSColor *) replyBackgroundColorIgnoringAlpha;
{
	return [[self additionalThemeDict] objectForKey: @"replyBackgroundColorBase"];
}
- (void) setReplyBackgroundColorIgnoringAlpha: (NSColor *) opaqueColor;
{
	[[self additionalThemeDict] setObject: opaqueColor forKey: @"replyBackgroundColorBase"];
}
- (float) replyBackgroundAlphaValue
{
	return m_replyBgAlpha;
}
- (void) setReplyBackgroundAlphaValue: (float) alpha
{
	m_replyBgAlpha = alpha;
}
@end
