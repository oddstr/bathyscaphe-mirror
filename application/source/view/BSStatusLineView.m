//
//  BSStatusLineView.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/03/14.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSStatusLineView.h"


@implementation BSStatusLineView
- (id)initWithFrame:(NSRect)frameRect
{
	if (self = [super initWithFrame:frameRect]) {
		[self setRightMargin:0.0];
	}
	return self;
}

- (void)dealloc
{
	[self setMessageText:nil];
	[super dealloc];
}

- (NSDictionary *)titleTextAttributes
{
	static NSDictionary *cachedAttributes = nil;
//	static NSDictionary *cachedAttributesDisabled = nil;
	if (!cachedAttributes) {
		NSArray *objects;
//		NSArray *objectsDisabled;
		NSArray *keys;
		NSMutableParagraphStyle *style;
		NSFont	*font;

		style = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
		[style setLineBreakMode:NSLineBreakByTruncatingMiddle];

		font = [NSFont labelFontOfSize:0];

		keys = [NSArray arrayWithObjects:NSFontAttributeName, NSForegroundColorAttributeName, NSParagraphStyleAttributeName, nil];

		objects = [[NSArray alloc] initWithObjects:font, [NSColor controlTextColor], style, nil];
//		objectsDisabled = [[NSArray alloc] initWithObjects:font, [NSColor disabledControlTextColor], style, nil];
		
		cachedAttributes = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
//		cachedAttributesDisabled = [[NSDictionary alloc] initWithObjects:objectsDisabled forKeys:keys];

		[objects release];
//		[objectsDisabled release];
	}
//	return [[self window] isKeyWindow] ? cachedAttributes : cachedAttributesDisabled;
	return cachedAttributes;
}

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];

	if ([self messageText]) {
		NSRect msgRect = NSMakeRect(rect.origin.x + 5, rect.origin.y, rect.size.width - [self rightMargin], rect.size.height - 5);
		[[self messageText] drawWithRect:msgRect options:NSStringDrawingUsesLineFragmentOrigin attributes:[self titleTextAttributes]];
	}
}

- (NSString *)messageText
{
	return m_messageText;
}

- (void)setMessageText:(NSString *)aString
{
	[aString retain];
	[m_messageText release];
	m_messageText = aString;

	[self setNeedsDisplay:YES];
}

- (float)rightMargin
{
	return m_rightMargin;
}

- (void)setRightMargin:(float)floatValue
{
	m_rightMargin = floatValue;
}
@end
