/**
  * $Id: SGSplitView.m,v 1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * SGSplitView.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "SGSplitView.h"
#import "SGAppKitFrameworkDefines.h"



@implementation SGSplitView
- (void) mouseDown : (NSEvent *) theEvent
{
	NSPoint			vpoint_;
	NSEnumerator	*iter_;
	NSView       	*subview_;
	
	[super mouseDown : theEvent];
	
	vpoint_ = [self convertPoint : [theEvent locationInWindow]
						fromView : nil];
	
	// subviewへのクリック以外はDivider内でのクリックとみなす
	iter_ = [[self subviews] objectEnumerator];
	while(subview_ = [iter_ nextObject]){
		if([self mouse:vpoint_ inRect:[subview_ frame]])
			return;
	}
	[self mouseDownInDivider : theEvent];
}

// SGSplitView Event Handling
- (void) doubleClickInDivider : (NSEvent *) theEvent
{
	if([self delegate] && [[self delegate] respondsToSelector:@selector(splitView:doubleClickInDivider:)])
		[[self delegate] splitView:self doubleClickInDivider:theEvent];
}

- (void) mouseDownInDivider : (NSEvent *) theEvent
{
	if(NSLeftMouseDown == [theEvent type] && 2 == [theEvent clickCount])
		[self doubleClickInDivider : theEvent];
}
@end
