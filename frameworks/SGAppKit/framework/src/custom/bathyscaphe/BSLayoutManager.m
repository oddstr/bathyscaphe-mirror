//
//  $Id: BSLayoutManager.m,v 1.1 2006/06/28 18:36:38 tsawada2 Exp $
//  BathyScaphe (SGAppKit)
//
//  Created by Tsutomu Sawada on 06/06/28.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSLayoutManager.h"

@implementation BSLayoutManager
- (id) init {
	self = [super init];
	if (self != nil) {
		[self setTextContainerInLiveResize: NO];
		[self setShouldAntialias: YES];
	}
	return self;
}

// for on/off Anti alias
- (void) drawGlyphsForGlyphRange: (NSRange) glyphRange
                         atPoint: (NSPoint) containerOrigin
{
	NSGraphicsContext	*gcontext_;
	BOOL shouldAntialias_;
	
	gcontext_ = [NSGraphicsContext currentContext];
	shouldAntialias_ = [self shouldAntialias];
	
	if(shouldAntialias_ != [gcontext_ shouldAntialias])
		[gcontext_ setShouldAntialias: shouldAntialias_];
	
	[super drawGlyphsForGlyphRange: glyphRange
						   atPoint: containerOrigin];
}

- (void) textContainerChangedGeometry: (NSTextContainer *)aTextContainer
{
	if (NO == [self textContainerInLiveResize])
		[super textContainerChangedGeometry: aTextContainer];
}

- (BOOL) textContainerInLiveResize
{
	return bs_liveResizing;
}

- (void) setTextContainerInLiveResize: (BOOL) flag
{
	bs_liveResizing = flag;
}

- (BOOL) shouldAntialias
{
	return bs_shouldAntialias;
}

- (void) setShouldAntialias: (BOOL) flag
{
	bs_shouldAntialias = flag;
}
@end
