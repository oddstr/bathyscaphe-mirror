//: SGFixImageButton.m
/**
  * $Id: SGFixImageButtonCell.m,v 1.1.1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGFixImageButtonCell_p.h"




@implementation SGFixImageButtonCell
- (void) setImage : (NSImage *) anImage
{
	NSImage		*image_;
	
	image_ = [anImage copyWithZone : [self zone]];
	[image_ setScalesWhenResized : YES];
	[super setImage : image_];
	[image_ release];
}
- (void) setAlternateImage : (NSImage *) anImage
{
	NSImage		*image_;
	
	image_ = [anImage copyWithZone : [self zone]];
	[image_ setScalesWhenResized : YES];
	[super setAlternateImage : image_];
	[image_ release];
}
- (void) drawInteriorWithFrame : (NSRect  ) cellFrame
						inView : (NSView *) controlView
{
	NSSize		imageSize_;
	NSImage		*image_;
	
	imageSize_ = [controlView bounds].size;
	
	image_ = [self image];
	if(image_ != nil && NO == NSEqualSizes([image_ size], imageSize_))
		[image_ setSize : imageSize_];
	image_ = [self alternateImage];
	if(image_ != nil && NO == NSEqualSizes([image_ size], imageSize_))
		[image_ setSize : imageSize_];
	
	[super drawInteriorWithFrame:cellFrame inView:controlView];
}
@end
