//:CMRAccessorySheetController-ViewAccessor.m
/**
  *
  * 
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/09/27  6:10:57 PM)
  *
  */

#import "CMRAccessorySheetController_p.h"



@implementation CMRAccessorySheetController(ViewAccessor)
/* Accessor for m_originalContentView */
- (NSView *) originalContentView
{
	return m_originalContentView;
}
/* Accessor for m_closeButton */
- (NSButton *) closeButton
{
	return m_closeButton;
}

@end



@implementation CMRAccessorySheetController(ViewInitializer)
- (void) setupContentView
{
	m_originalContentView = [m_contentView retain];
}
- (void) setupCloseButton
{
	//write your implementation...
}
- (void) setupWindow
{
	[[[self window] contentView] setAutoresizesSubviews : YES];
	[[[self window] contentView] setAutoresizingMask : 
			(NSViewHeightSizable | NSViewWidthSizable)];
}
- (void) setupUIComponents
{
	[self setupContentView];
	[self setupCloseButton];
}
@end


