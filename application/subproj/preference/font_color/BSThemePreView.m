//
//  BSThemePreView.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 09/01/11.
//  Copyright 2009 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSThemePreView.h"
#import "PreferencePanes_Prefix.h"

@implementation BSThemePreView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		m_theme = nil;
    }
    return self;
}

- (NSAttributedString *)attributedStringForPreview
{
	static NSArray *array = nil;
	if (!array) {
		NSBundle *bundle = [NSBundle bundleForClass:[self class]];
		NSString *path = [bundle pathForResource:@"themePreview" ofType:@"plist"];
		if (path) {
			array = [[NSArray alloc] initWithContentsOfFile:path];
		}
	}

	BSThreadViewTheme *t = [self theme];
	NSDictionary *baseattr = [NSDictionary dictionaryWithObjectsAndKeys:[t baseFont], NSFontAttributeName,
		[t baseColor], NSForegroundColorAttributeName, NULL];
	NSDictionary *attr2 = [NSDictionary dictionaryWithObjectsAndKeys:[t titleFont], NSFontAttributeName,
		[t titleColor], NSForegroundColorAttributeName, NULL];
	NSDictionary *attr3 = [NSDictionary dictionaryWithObjectsAndKeys:[t baseFont], NSFontAttributeName,
		[t nameColor], NSForegroundColorAttributeName, NULL];
	
	NSDictionary *attr4 = [NSDictionary dictionaryWithObjectsAndKeys:[t messageFont], NSFontAttributeName,
		[t messageColor], NSForegroundColorAttributeName, NULL];
	NSDictionary *attr5 = [NSDictionary dictionaryWithObjectsAndKeys:[t AAFont], NSFontAttributeName,
		[t messageColor], NSForegroundColorAttributeName, NULL];

	NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"1 " attributes:baseattr];
	NSString *nameTitle = [NSLocalizedStringFromTable(@"Name", @"MessageComposer", @"Name") stringByAppendingString:@": "];
	[attrStr appendString:nameTitle withAttributes:attr2];
	[attrStr appendString:[[array objectAtIndex:0] objectForKey:@"Name"] withAttributes:attr3];
	[attrStr appendString:@" ID: " withAttributes:attr2];
	[attrStr appendString:[[array objectAtIndex:0] objectForKey:@"ID"] withAttributes:baseattr];
	[attrStr appendString:@"\n" withAttributes:baseattr];
	[attrStr appendString:[[array objectAtIndex:0] objectForKey:@"Message"] withAttributes:attr4];
	[attrStr appendString:@"\n\n2 " withAttributes:baseattr];
	[attrStr appendString:nameTitle withAttributes:attr2];
	[attrStr appendString:[[array objectAtIndex:1] objectForKey:@"Name"] withAttributes:attr3];
	[attrStr appendString:@" ID: " withAttributes:attr2];
	[attrStr appendString:[[array objectAtIndex:1] objectForKey:@"ID"] withAttributes:baseattr];
	[attrStr appendString:@"\n" withAttributes:baseattr];
	[attrStr appendString:[[array objectAtIndex:1] objectForKey:@"Message"] withAttributes:attr5];
	return [attrStr autorelease];
}
	

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
	if (![self theme]) {
		[[NSColor whiteColor] set];
		NSRectFill(rect);
		return;
	}

	BSThreadViewTheme *t = [self theme];
/*	NSDictionary *baseattr = [NSDictionary dictionaryWithObjectsAndKeys:[t baseFont], NSFontAttributeName,
		[t baseColor], NSForegroundColorAttributeName, NULL];

	NSAttributedString *text = [[NSMutableAttributedString alloc] initWithString:
		@"1 Name:Nanashi\n\t>>2\n\tSample Text\n\tTenori Tiger" attributes:baseattr];*/
	[[t backgroundColor] set];
	NSRectFill(rect);
	[[self attributedStringForPreview] drawInRect:NSInsetRect(rect, 5.0, 5.0)];
}

- (BSThreadViewTheme *)theme
{
	return m_theme;
}

- (void)setTheme:(BSThreadViewTheme *)aTheme
{
	[self setThemeWithoutNeedingDisplay:aTheme];
	[self display];
}

- (void)setThemeWithoutNeedingDisplay:(BSThreadViewTheme *)aTheme
{
	[aTheme retain];
	[m_theme release];
	m_theme = aTheme;
}
@end
