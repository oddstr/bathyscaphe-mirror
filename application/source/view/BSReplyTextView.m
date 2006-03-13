//
//  $Id: BSReplyTextView.m,v 1.1 2006/03/13 13:24:08 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/03/13.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSReplyTextView.h"


@implementation BSReplyTextView
- (id) initWithFrame : (NSRect) inFrame textContainer : (NSTextContainer *) inTextContainer
{
    if (self = [super initWithFrame : inFrame textContainer : inTextContainer]) {
		m_alphaValue = 1.0;
	}
	return self;
}

- (float) alphaValue
{
	return m_alphaValue;
}

- (void) setBackgroundColor : (NSColor *) opaqueColor withAlphaComponent : (float) alpha
{
	NSColor	*actualColor = [opaqueColor colorWithAlphaComponent : alpha];
	[self setBackgroundColor : actualColor];
}

- (void) setBackgroundColor : (NSColor *) aColor
{
	if(aColor)
		m_alphaValue = [aColor alphaComponent];

	[super setBackgroundColor : aColor];
}

- (void) drawRect : (NSRect) aRect
{
	[super drawRect : aRect];
	
	if (m_alphaValue < 1.0) {
		[[self window] invalidateShadow];
	}
}
@end
