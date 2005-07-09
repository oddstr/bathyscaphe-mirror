//:CMRLayoutManager.m

#import "CMRLayoutManager.h"
#import "AppDefaults.h"
#import "NSLayoutManager+CMXAdditions.h"



@implementation CMRLayoutManager
// for on/off Anti alias
- (void) drawGlyphsForGlyphRange : (NSRange) glyphRange
                         atPoint : (NSPoint) containerOrigin
{
	NSGraphicsContext	*gcontext_;
	BOOL				shouldAntialias_;
	
	shouldAntialias_ = [CMRPref shouldThreadAntialias];
	gcontext_ = [NSGraphicsContext currentContext];
	
	if(shouldAntialias_ != [gcontext_ shouldAntialias])
		[gcontext_ setShouldAntialias : shouldAntialias_];
	
	
	[super drawGlyphsForGlyphRange : glyphRange
						   atPoint : containerOrigin];
}
@end
