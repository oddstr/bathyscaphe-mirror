/**
  * $Id: CMRLayoutManager.h,v 1.1.1.1.4.1 2006/09/01 13:46:54 masakih Exp $
  * BathyScaphe
  *
  * @author Takanori Ishikawa (2002-2004)
  * @author Tsutomu Sawada (2005-)
  * @version 1.0.0d1 (02/09/10  5:29:42 AM)
  *
  */
#import <Cocoa/Cocoa.h>


@interface CMRLayoutManager : NSLayoutManager
{
	@private
	BOOL	bs_liveResizing;
	BOOL	bs_shouldAntiAlias;
}

- (BOOL) textContainerInLiveResize;
- (void) setTextContainerInLiveResize: (BOOL) flag;

- (BOOL) shouldDrawAntiAliasingGlyph;
- (void) setShouldDrawAntiAliasingGlyph: (BOOL) flag;
@end
