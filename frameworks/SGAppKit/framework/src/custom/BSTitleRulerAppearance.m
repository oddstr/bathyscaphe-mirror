//
//  BSTitleRulerAppearance.m
//  SGAppKit
//
//  Created by Tsutomu Sawada on 07/08/25.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import "BSTitleRulerAppearance.h"


@implementation BSTitleRulerAppearance
- (void)dealloc
{
	[self setTextColor:nil];
	[self setInfoColor:nil];

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
	return m_infoColor;
}

- (void)setInfoColor:(NSColor *)color
{
	[color retain];
	[m_infoColor release];
	m_infoColor = color;
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

- (id)initWithCoder:(NSCoder *)coder
{
	if (self = [super init]) {
		if ([coder allowsKeyedCoding]) {
			[self setActiveBlueColors:[coder decodeObjectForKey:@"blue"]];
			[self setActiveGraphiteColors:[coder decodeObjectForKey:@"graphite"]];
			[self setInactiveColors:[coder decodeObjectForKey:@"inactive"]];
			[self setInfoColor:[coder decodeObjectForKey:@"info"]];
			[self setTextColor:[coder decodeObjectForKey:@"text"]];
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	if ([coder allowsKeyedCoding]) {
		[coder encodeObject:[self textColor] forKey:@"text"];
		[coder encodeObject:[self infoColor] forKey:@"info"];
		[coder encodeObject:[self inactiveColors] forKey: @"inactive"];
		[coder encodeObject:[self activeGraphiteColors] forKey: @"graphite"];
		[coder encodeObject:[self activeBlueColors] forKey: @"blue"];
	}
}
@end
