//: SGBackgroundSurfaceView.m
/**
  * $Id: SGBackgroundSurfaceView.m,v 1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGBackgroundSurfaceView_p.h"


static NSString *const kSurfaceImagesDirectory = @"background";

static NSString *const kLeftSurfaceImageName = @"RoundedTextFieldSurfaceLeft";
static NSString *const kMiddleSurfaceImageName = @"RoundedTextFieldSurfaceMiddle";
static NSString *const kRightSurfaceImageName = @"RoundedTextFieldSurfaceRight";

@implementation SGBackgroundSurfaceView(SurfaceImage)
+ (NSImage *) leftSurfaceImage
{
	return [NSImage imageNamed : kLeftSurfaceImageName
				loadFromBundle : [NSBundle bundleForClass : self]
				   inDirectory : kSurfaceImagesDirectory];
}
+ (NSImage *) middleSurfaceImage
{
	return [NSImage imageNamed : kMiddleSurfaceImageName
				loadFromBundle : [NSBundle bundleForClass : self]
				   inDirectory : kSurfaceImagesDirectory];
}
+ (NSImage *) rightSurfaceImage
{
	return [NSImage imageNamed : kRightSurfaceImageName
				loadFromBundle : [NSBundle bundleForClass : self]
				   inDirectory : kSurfaceImagesDirectory];
}
- (NSImage *) compositedSurfaceImage
{
	NSImage					*surface_;
	NSSize					imageSize_;
	NSPoint					point_;
	NSRect					middleFrame_;
	
	middleFrame_ = [self bounds];
	imageSize_ = middleFrame_.size;
	
	if(nil == m_background){
		m_background = [[NSImage alloc] initWithSize : imageSize_];
	}/*else if(NSEqualSizes(imageSize_, [m_background size])){
		return m_background;
	}*/
	
	[m_background lockFocus];
	
	[m_background setSize:imageSize_];
	[[NSColor clearColor] set];
	NSRectFill(middleFrame_);
	
	surface_ = [[self class] leftSurfaceImage];
	imageSize_ = [surface_ size];
	point_ = NSZeroPoint;
	[surface_ drawSourceAtPoint : point_];
	middleFrame_.size.width -= imageSize_.width;
	middleFrame_.origin.x = imageSize_.width;
	
	surface_ = [[self class] rightSurfaceImage];
	imageSize_ = [surface_ size];
	point_ = NSZeroPoint;
	point_.x = [m_background size].width - imageSize_.width;
	[surface_ drawSourceAtPoint : point_];
	middleFrame_.size.width -= imageSize_.width;
	
	surface_ = [[self class] middleSurfaceImage];
	imageSize_ = [surface_ size];
	imageSize_.width = middleFrame_.size.width;
	[surface_ setSize : imageSize_];
	point_ = middleFrame_.origin;
	
	[surface_ drawSourceAtPoint : point_];
	[m_background unlockFocus];
	
	return m_background;
}
@end



@implementation SGBackgroundSurfaceView
/*- (void) initWithFrame : (NSRect) aRect
{
	if(self = [super initWithFrame : aRect]){
		[[NSNotification
	}
	return self;
}
*/- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver : self];
	[m_background release];
	[super dealloc];
}
- (void) setFrame : (NSRect) frameRect
{
	m_keyboardFocusRingFlag = NO;
	[super setFrame : frameRect];
}
- (void) setFrameSize : (NSSize) newSize
{
	m_keyboardFocusRingFlag = NO;
	[super setFrameSize : newSize];
}
- (void) viewWillMoveToWindow
{
	[[NSNotificationCenter defaultCenter]
		removeObserver : self
				  name : NSWindowDidBecomeMainNotification
				object : [self window]];
}
- (void) viewDidMoveToWindow
{
	[[NSNotificationCenter defaultCenter]
		addObserver : self
		   selector : @selector(windowDidBecomeMain:)
			   name : NSWindowDidBecomeMainNotification
			 object : [self window]];
}
- (void) windowDidBecomeMain : (NSNotification *) notification
{
	if([notification object] != [self window]) return;
	m_keyboardFocusRingFlag = NO;
}

- (void) drawRect : (NSRect) aRect
{
	NSImage					*surface_;
	
	
	[super drawRect : aRect];

	if([self showsFirstResponder]){
		if(NO == m_keyboardFocusRingFlag){
			NSSetFocusRingStyle(NSFocusRingAbove);
			m_keyboardFocusRingFlag = YES;
		}
	}else{
		[self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
		m_keyboardFocusRingFlag = NO;
	}

	surface_ = [self compositedSurfaceImage];
	[surface_ setFlipped : [self isFlipped]];
	[surface_ drawSourceAtPoint : NSZeroPoint];
}
@end



@implementation SGBackgroundSurfaceView(Attributes)
- (id) delegate
{
	return m_delegate;
}
- (void) setDelegate : (id) aDelegate
{
	m_delegate = aDelegate;
}
- (BOOL) showsFirstResponder
{
	id		delegate_	= [self delegate];
	SEL		sel_		=  @selector(backgroundViewShowsKeyboardFocusRing:);
	
	if(nil == delegate_)
		return m_showsFirstResponder;
	if(NO == [delegate_ respondsToSelector : sel_])
		return m_showsFirstResponder;
	
	return [[self delegate] backgroundViewShowsKeyboardFocusRing : self];
}
- (void) setShowsFirstResponder : (BOOL) flag
{
	m_showsFirstResponder = flag;
}
- (void) setNeedsUpdateKeyboardFocusRing : (BOOL) flag
{
	m_keyboardFocusRingFlag = NO;
}
@end
