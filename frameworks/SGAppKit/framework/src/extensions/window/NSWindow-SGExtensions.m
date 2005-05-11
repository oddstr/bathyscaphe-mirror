//: NSWindow-SGExtensions.m
/**
  * $Id: NSWindow-SGExtensions.m,v 1.1 2005/05/11 17:51:27 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "NSWindow-SGExtensions_p.h"


@implementation NSWindow(SGExtensions)
- (NSSize) minContentSize
{
	NSRect			minFrame_;
	NSRect			minContentFrame_;
	
	minFrame_ = [self frame];
	minFrame_.size = [self minSize];
	minContentFrame_ = 
		[[self class] contentRectForFrameRect : minFrame_
									styleMask : [self styleMask]];
	
	return minContentFrame_.size;
}

- (void) setFrame : (NSRect) frameRect
          display : (BOOL  ) displayFlag
          animate : (BOOL  ) animationFlag
      autoresizes : (BOOL  ) isAutoresize
{
	BOOL		autoresizesSubviews_;
	
	autoresizesSubviews_ = [[self contentView] autoresizesSubviews];
	[[self contentView] setAutoresizesSubviews : isAutoresize];
	[self setFrame : frameRect
		   display : displayFlag
		   animate : animationFlag];
	[[self contentView] setAutoresizesSubviews : autoresizesSubviews_];
}
@end
