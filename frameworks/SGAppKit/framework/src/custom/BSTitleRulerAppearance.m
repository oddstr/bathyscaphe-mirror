//
//  BSTitleRulerAppearance.m
//  SGAppKit (BathyScaphe)
//
//  Created by Tsutomu Sawada on 07/08/25.
//  Copyright 2007-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSTitleRulerAppearance.h"


@implementation BSTitleRulerAppearance
- (void)dealloc
{
	[self setTextColor:nil];
	[self setInfoColor:nil];
	[self setInfoBackgroundColor:nil];

	[self setInactiveColors:nil];
	[self setActiveGraphiteColors:nil];
	[self setActiveBlueColors:nil];

	[super dealloc];
}

- (NSArray *)activeBlueColors
{
	return m_activeBlueColors;
}

- (void)setActiveBlueColors:(NSArray *)colorsArray
{
	[colorsArray retain];
	[m_activeBlueColors release];
	m_activeBlueColors = colorsArray;
}

- (NSArray *)activeGraphiteColors
{
	return m_activeGraphiteColors;
}

- (void)setActiveGraphiteColors:(NSArray *)colorsArray
{
	[colorsArray retain];
	[m_activeGraphiteColors release];
	m_activeGraphiteColors = colorsArray;
}

- (NSArray *)inactiveColors
{
	return m_inactiveColors;
}

- (void)setInactiveColors:(NSArray *)colorsArray
{
	[colorsArray retain];
	[m_inactiveColors release];
	m_inactiveColors = colorsArray;
}

#pragma mark -
- (NSColor *)activeBlueStartColor
{
	return [[self activeBlueColors] objectAtIndex:0];
}

- (void)setActiveBlueStartColor:(NSColor *)color
{
	NSAssert(color, @"color is nil!");
	NSColor *anotherColor = [[self activeBlueColors] objectAtIndex:1];
	NSArray *newArray = [NSArray arrayWithObjects:color, anotherColor, nil];
	[self setActiveBlueColors:newArray];
}
	
- (NSColor *)activeBlueEndColor
{
	return [[self activeBlueColors] objectAtIndex:1];
}

- (void)setActiveBlueEndColor:(NSColor *)color
{
	NSAssert(color, @"color is nil!");
	NSColor *anotherColor = [[self activeBlueColors] objectAtIndex:0];
	NSArray *newArray = [NSArray arrayWithObjects:anotherColor, color, nil];
	[self setActiveBlueColors:newArray];
}
	
- (NSColor *)activeGraphiteStartColor
{
	return [[self activeGraphiteColors] objectAtIndex:0];
}

- (void)setActiveGraphiteStartColor:(NSColor *)color
{
	NSAssert(color, @"color is nil!");
	NSColor *anotherColor = [[self activeGraphiteColors] objectAtIndex:1];
	NSArray *newArray = [NSArray arrayWithObjects:color, anotherColor, nil];
	[self setActiveGraphiteColors:newArray];
}
	
- (NSColor *)activeGraphiteEndColor
{
	return [[self activeGraphiteColors] objectAtIndex:1];
}

- (void)setActiveGraphiteEndColor:(NSColor *)color
{
	NSAssert(color, @"color is nil!");
	NSColor *anotherColor = [[self activeGraphiteColors] objectAtIndex:0];
	NSArray *newArray = [NSArray arrayWithObjects:anotherColor, color, nil];
	[self setActiveGraphiteColors:newArray];
}
	
- (NSColor *)inactiveStartColor
{
	return [[self inactiveColors] objectAtIndex:0];
}

- (void)setInactiveStartColor:(NSColor *)color
{
	NSAssert(color, @"color is nil!");
	NSColor *anotherColor = [[self inactiveColors] objectAtIndex:1];
	NSArray *newArray = [NSArray arrayWithObjects:color, anotherColor, nil];
	[self setInactiveColors:newArray];
}
	
- (NSColor *)inactiveEndColor
{
	return [[self inactiveColors] objectAtIndex:1];
}

- (void)setInactiveEndColor:(NSColor *)color
{
	NSAssert(color, @"color is nil!");
	NSColor *anotherColor = [[self inactiveColors] objectAtIndex:0];
	NSArray *newArray = [NSArray arrayWithObjects:anotherColor, color, nil];
	[self setInactiveColors:newArray];
}

#pragma mark -
- (NSColor *)infoColor
{
	return m_infoTextColor;
}

- (void)setInfoColor:(NSColor *)color
{
	[color retain];
	[m_infoTextColor release];
	m_infoTextColor = color;
}

- (NSColor *)infoBackgroundColor
{
	return m_infoBgColor;
}

- (void)setInfoBackgroundColor:(NSColor *)color
{
	[color retain];
	[m_infoBgColor release];
	m_infoBgColor = color;
}

- (NSColor *)textColor
{
	return m_textColor;
}

- (void)setTextColor:(NSColor *)color
{
	[color retain];
	[m_textColor release];
	m_textColor = color;
}

- (BOOL)drawsCarvedText
{
	return m_drawsCarvedText;
}

- (void)setDrawsCarvedText:(BOOL)flag
{
	m_drawsCarvedText = flag;
}

- (id)initWithCoder:(NSCoder *)coder
{
	if (self = [super init]) {
		if ([coder allowsKeyedCoding]) {
			[self setActiveBlueColors:[coder decodeObjectForKey:@"blue"]];
			[self setActiveGraphiteColors:[coder decodeObjectForKey:@"graphite"]];
			[self setInactiveColors:[coder decodeObjectForKey:@"inactive"]];
			[self setInfoColor:[coder decodeObjectForKey:@"info"]];
			[self setInfoBackgroundColor:[coder decodeObjectForKey:@"info_bg"]];
			[self setTextColor:[coder decodeObjectForKey:@"text"]];
			[self setDrawsCarvedText:[coder decodeBoolForKey:@"carved"]];
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	if ([coder allowsKeyedCoding]) {
		[coder encodeBool:[self drawsCarvedText] forKey:@"carved"];
		[coder encodeObject:[self textColor] forKey:@"text"];
		[coder encodeObject:[self infoBackgroundColor] forKey:@"info_bg"];
		[coder encodeObject:[self infoColor] forKey:@"info"];
		[coder encodeObject:[self inactiveColors] forKey: @"inactive"];
		[coder encodeObject:[self activeGraphiteColors] forKey: @"graphite"];
		[coder encodeObject:[self activeBlueColors] forKey: @"blue"];
	}
}
@end
