//
//  BSTitleRulerAppearance.h
//  SGAppKit (BathyScaphe)
//
//  Created by Tsutomu Sawada on 07/08/25.
//  Copyright 2007-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>


@interface BSTitleRulerAppearance : NSObject<NSCoding> {
	NSArray *m_activeBlueColors;
	NSArray *m_activeGraphiteColors;
	NSArray *m_inactiveColors;

	NSColor *m_infoBgColor;
	NSColor	*m_infoTextColor;
	NSColor *m_textColor;

	BOOL	m_drawsCarvedText;
}

- (NSArray *)activeBlueColors;
- (void)setActiveBlueColors:(NSArray *)colorsArray;
- (NSArray *)activeGraphiteColors;
- (void)setActiveGraphiteColors:(NSArray *)colorsArray;
- (NSArray *)inactiveColors;
- (void)setInactiveColors:(NSArray *)colorsArray;

#pragma mark -
- (NSColor *)activeBlueStartColor;
- (void)setActiveBlueStartColor:(NSColor *)color;
- (NSColor *)activeBlueEndColor;
- (void)setActiveBlueEndColor:(NSColor *)color;
- (NSColor *)activeGraphiteStartColor;
- (void)setActiveGraphiteStartColor:(NSColor *)color;
- (NSColor *)activeGraphiteEndColor;
- (void)setActiveGraphiteEndColor:(NSColor *)color;
- (NSColor *)inactiveStartColor;
- (void)setInactiveStartColor:(NSColor *)color;
- (NSColor *)inactiveEndColor;
- (void)setInactiveEndColor:(NSColor *)color;

#pragma mark -
- (NSColor *)infoColor;
- (void)setInfoColor:(NSColor *)color;
- (NSColor *)infoBackgroundColor;
- (void)setInfoBackgroundColor:(NSColor *)color;
- (NSColor *)textColor;
- (void)setTextColor:(NSColor *)color;

- (BOOL)drawsCarvedText;
- (void)setDrawsCarvedText:(BOOL)flag;
@end
