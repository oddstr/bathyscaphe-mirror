//
//  $Id: BSReplyTextView.m,v 1.3 2007/12/24 14:29:09 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/03/13.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSReplyTextView.h"


@implementation BSReplyTextView
- (id)initWithFrame:(NSRect)inFrame textContainer:(NSTextContainer *)inTextContainer
{
    if (self = [super initWithFrame:inFrame textContainer:inTextContainer]) {
		[self setAlphaValue:1.0];
	}
	return self;
}

- (float)alphaValue
{
	return m_alphaValue;
}

- (void)setAlphaValue:(float)floatValue
{
	m_alphaValue = floatValue;
}

- (void)setBackgroundColor:(NSColor *)opaqueColor withAlphaComponent:(float)alpha
{
	NSColor	*actualColor = [opaqueColor colorWithAlphaComponent:alpha];
	[self setBackgroundColor:actualColor];
}

- (void)setBackgroundColor:(NSColor *)aColor
{
	if (aColor) {
		[self setAlphaValue:[aColor alphaComponent]];
	}
	[[self window] setOpaque:([self alphaValue] < 1.0) ? NO : YES];
	[super setBackgroundColor:aColor];
}

- (void)drawRect:(NSRect)aRect
{
	[super drawRect:aRect];
	
	if ([self alphaValue] < 1.0) {
		[[self window] invalidateShadow];
	}
}

static inline BOOL delegateCheck(id delegate)
{
	if (!delegate) return NO;
	if (![delegate respondsToSelector:@selector(availableCompletionPrefixesForTextView:)]) return NO;
	if (![delegate respondsToSelector:@selector(textView:completedStringForCompletionPrefix:)]) return NO;
	return YES;
}

- (NSArray *)completionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(int *)index
{
	id delegate = [self delegate];
	if (delegateCheck(delegate)) {
		NSString *partialString = [[self string] substringWithRange:charRange];
		NSArray *prefixes = [delegate availableCompletionPrefixesForTextView:self];

		if (prefixes && [prefixes containsObject:partialString]) {
			NSString *replacement = [delegate textView:self completedStringForCompletionPrefix:partialString];
			if (replacement && [self shouldChangeTextInRange:charRange replacementString:replacement]) {
				[self replaceCharactersInRange:charRange withString:replacement];
				[self didChangeText];
				return nil;
			}
		}
	}
	return [super completionsForPartialWordRange:charRange indexOfSelectedItem:index];
}
@end
