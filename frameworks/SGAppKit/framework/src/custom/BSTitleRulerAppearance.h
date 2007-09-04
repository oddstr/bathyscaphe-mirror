//
//  BSTitleRulerAppearance.h
//  SGAppKit
//
//  Created by Tsutomu Sawada on 07/08/25.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BSTitleRulerAppearance : NSObject<NSCoding> {
	NSArray *m_activeBlueColors;
	NSArray *m_activeGraphiteColors;
	NSArray *m_inactiveColors;

	NSColor	*m_infoColor;
	NSColor *m_textColor;
}

- (NSArray *)activeBlueColors;
- (void)setActiveBlueColors:(NSArray *)colorsArray;
- (NSArray *)activeGraphiteColors;
- (void)setActiveGraphiteColors:(NSArray *)colorsArray;
- (NSArray *)inactiveColors;
- (void)setInactiveColors:(NSArray *)colorsArray;

- (NSColor *)infoColor;
- (void)setInfoColor:(NSColor *)color;
- (NSColor *)textColor;
- (void)setTextColor:(NSColor *)color;
@end
