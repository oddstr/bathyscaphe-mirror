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

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
	if (![self theme]) {
		[[NSColor whiteColor] set];
		NSRectFill(rect);
		return;
	}

	BSThreadViewTheme *t = [self theme];
	NSDictionary *baseattr = [NSDictionary dictionaryWithObjectsAndKeys:[t baseFont], NSFontAttributeName,
		[t baseColor], NSForegroundColorAttributeName, NULL];

	NSAttributedString *text = [[NSMutableAttributedString alloc] initWithString:
		@"1 Name:Nanashi\n\t>>2\n\tSample Text" attributes:baseattr];
	[[t backgroundColor] set];
	NSRectFill(rect);
	[text drawInRect:rect];
	[text release];
}

- (BSThreadViewTheme *)theme
{
	return m_theme;
}

- (void)setTheme:(BSThreadViewTheme *)aTheme
{
	[self setThemeWithoutNeedingDisplay:aTheme];
	[self displayIfNeeded];
}

- (void)setThemeWithoutNeedingDisplay:(BSThreadViewTheme *)aTheme
{
	[aTheme retain];
	[m_theme release];
	m_theme = aTheme;
}
@end
