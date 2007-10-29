//
//  BSTitleRulerAppearance.m
//  SGAppKit (BathyScaphe)
//
//  Created by Tsutomu Sawada on 07/08/25.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
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
