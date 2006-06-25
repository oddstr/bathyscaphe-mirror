//:CMRLayoutManager.m

#import "CMRLayoutManager.h"
//#import "AppDefaults.h"

@implementation CMRLayoutManager
- (id) init {
	self = [super init];
	if (self != nil) {
		[self setTextContainerInLiveResize: NO];
		[self setShouldDrawAntiAliasingGlyph: YES];
	}
	return self;
}

// for on/off Anti alias
- (void) drawGlyphsForGlyphRange : (NSRange) glyphRange
                         atPoint : (NSPoint) containerOrigin
{
	NSGraphicsContext	*gcontext_;
	BOOL				shouldAntialias_;
	
//	shouldAntialias_ = [CMRPref shouldThreadAntialias];
	shouldAntialias_ = [self shouldDrawAntiAliasingGlyph];
	gcontext_ = [NSGraphicsContext currentContext];
	
	if(shouldAntialias_ != [gcontext_ shouldAntialias])
		[gcontext_ setShouldAntialias : shouldAntialias_];
	
	
	[super drawGlyphsForGlyphRange : glyphRange
						   atPoint : containerOrigin];
}

- (void)textContainerChangedGeometry:(NSTextContainer *)aTextContainer
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

- (BOOL) shouldDrawAntiAliasingGlyph
{
	return bs_shouldAntiAlias;
}

- (void) setShouldDrawAntiAliasingGlyph: (BOOL) flag
{
	bs_shouldAntiAlias = flag;
}
@end
