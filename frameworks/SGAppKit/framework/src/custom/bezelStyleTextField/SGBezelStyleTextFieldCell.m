//: SGBezelStyleTextFieldCell.m
/**
  * $Id: SGBezelStyleTextFieldCell.m,v 1.1.1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGBezelStyleTextFieldCell_p.h"



@implementation SGBezelStyleTextFieldCell(SurfaceImage)
+ (NSImage *) leftSurfaceImage
{
	return [NSImage imageNamed : kLeftSurfaceImageName];
}
+ (NSImage *) middleSurfaceImage
{
	return [NSImage imageNamed : kMiddleSurfaceImageName];
}
+ (NSImage *) rightSurfaceImage
{
	return [NSImage imageNamed : kRightSurfaceImageName];
}
- (NSImage *) compositedSurfaceImageForView : (NSView *) controlView
{
	NSImage					*composited_;
	NSImage					*surface_;
	NSSize					imageSize_;
	NSPoint					point_;
	NSRect					middleFrame_;
	
	middleFrame_ = [self rectExpandSpacing : [controlView bounds]];
	
	composited_ = [[NSImage alloc] initWithSize : middleFrame_.size];
	[composited_ setFlipped : [[controlView superview] isFlipped]];
	
	[composited_ lockFocus];
	
	surface_ = [[self class] leftSurfaceImage];
	imageSize_ = [surface_ size];
	point_ = NSZeroPoint;
	[surface_ drawSourceAtPoint : point_];
	middleFrame_.size.width -= imageSize_.width;
	middleFrame_.origin.x = imageSize_.width;
	
	
	surface_ = [[self class] rightSurfaceImage];
	imageSize_ = [surface_ size];
	point_ = NSZeroPoint;
	point_.x = [composited_ size].width - imageSize_.width;
	[surface_ drawSourceAtPoint : point_];
	middleFrame_.size.width -= imageSize_.width;
	
	
	surface_ = [[self class] middleSurfaceImage];
	imageSize_ = [surface_ size];
	imageSize_.width = middleFrame_.size.width;
	[surface_ setSize : imageSize_];
	point_ = middleFrame_.origin;
	
	[surface_ drawSourceAtPoint : point_];
	[composited_ unlockFocus];
	
	return [composited_ autorelease];
}

- (NSRect) rectExpandSpacing : (NSRect) rect
{
	rect.size.width += ([self leftSpacing] + [self rightSpacing]);
	rect.origin.x -= [self leftSpacing];
	
	return rect;
}
- (NSRect) rectInsetSpacing : (NSRect) rect
{
	rect.size.width -= ([self leftSpacing] + [self rightSpacing]);
	rect.origin.x += [self leftSpacing];
	
	return rect;
}
@end



@implementation SGBezelStyleTextFieldCell(Spacing)
- (void) sizeToFit
{
	NSRect	frame_;
	
	frame_ = [[self controlView] frame];
	frame_ = [self rectInsetSpacing : frame_];
	[[self controlView] setFrame : frame_];
}

- (float) rightSpacing
{
	return m_rightSpacing;
}
- (void) setRightSpacing : (float) aRightSpacing
{
	m_rightSpacing = aRightSpacing;
}
- (float) leftSpacing
{
	return m_leftSpacing;
}
- (void) setLeftSpacing : (float) aLeftSpacing
{
	m_leftSpacing = aLeftSpacing;
}
@end



@implementation SGBezelStyleTextFieldCell

- (void) drawWithFrame : (NSRect  ) cellFrame
				inView : (NSView *) controlView
				 focus : (BOOL	  ) shouldFocus
{
	NSImage		*surface_;
	NSView		*superview_;
	NSPoint		point_;
	
	superview_ = [controlView superview];
	
	[superview_ lockFocus];
	
	if(shouldFocus && [self showsFirstResponder])
		NSSetFocusRingStyle(NSFocusRingAbove);
	
	surface_ = [self compositedSurfaceImageForView : controlView];
	point_ = [controlView frame].origin;
	point_.x -= 10;
	[surface_ drawSourceAtPoint : point_];
	
	[superview_ unlockFocus];
}

// should be fix...
/*- (void) drawWithFrame : (NSRect  ) cellFrame
				inView : (NSView *) controlView
*/- (void) drawInteriorWithFrame : (NSRect  ) cellFrame
				inView : (NSView *) controlView
{
	[self drawWithFrame:cellFrame inView:controlView focus:YES];
	
	if(NO == [self showsFirstResponder])
		[[self attributedStringValue] drawInRect : cellFrame];
}
- (void) endEditing : (NSText *) aFieldEditor
{
	NSRect		reset_;
	
	[super endEditing : aFieldEditor];
	reset_ = [self rectExpandSpacing : [[self controlView] frame]];
	reset_.size.width += 10;
	reset_.origin.x -= 5;
	
	[[[self controlView] superview] setNeedsDisplayInRect : reset_];
}
@end
