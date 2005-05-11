/**
  * $Id: CMRAttachmentCell.m,v 1.1 2005/05/11 17:51:04 tsawada2 Exp $
  * 
  * CMRAttachmentCell.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRAttachmentCell.h"
#import "CocoMonar_Prefix.h"



@implementation NSTextAttachmentCell(CMRExtetnsions)
- (BOOL) wantsToTrackMouseOver
{
	return NO;
}
@end



@implementation CMRAttachmentCell
- (NSImage *) defaultImage
{
	return _defaultImage;
}
- (void) setDefaultImage : (NSImage *) aDefaultImage
{
	id		tmp;
	
	tmp = _defaultImage;
	_defaultImage = [aDefaultImage retain];
	[tmp release];
}

- (id) initImageCell : (NSImage *) anImage
{
	if (self = [super initImageCell : anImage]) {
		[self setDefaultImage : anImage];
	}
	return self;
}
- (void) dealloc
{
	[_defaultImage release];
	[_mouseOverImage release];
	[_mouseDownImage release];
	[super dealloc];
}
- (NSImage *) mouseOverImage
{
	return _mouseOverImage;
}
- (NSImage *) mouseDownImage
{
	return _mouseDownImage;
}
- (void) setMouseOverImage : (NSImage *) aMouseOverImage
{
	id		tmp;
	
	tmp = _mouseOverImage;
	_mouseOverImage = [aMouseOverImage retain];
	[tmp release];
}
- (void) setMouseDownImage : (NSImage *) aMouseDownImage
{
	id		tmp;
	
	tmp = _mouseDownImage;
	_mouseDownImage = [aMouseDownImage retain];
	[tmp release];
}



/*** Tracking Mouse Event ***/
- (BOOL) wantsToTrackMouseForEvent : (NSEvent *) theEvent
							inRect : (NSRect   ) cellFrame
							ofView : (NSView  *) controlView
				  atCharacterIndex : (unsigned )charIndex
{
	NSEventType		type = [theEvent type];
	
	if (NSMouseEntered == type || NSMouseExited == type) 
		return [self wantsToTrackMouseOver];
	
	return [super wantsToTrackMouseForEvent:theEvent inRect:cellFrame ofView:controlView atCharacterIndex:charIndex];

}
- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)aTextView atCharacterIndex:(unsigned)charIndex untilMouseUp:(BOOL)flag
{
	NSEventType		type = [theEvent type];
	BOOL			result;
	NSPoint			mouseLocation_;
	
	if (NSMouseEntered == type || NSMouseExited == type) {
		if ([self mouseOverImage] != nil) {
			[self setImage : (NSMouseEntered == type)
				? [self mouseOverImage]
				: [self defaultImage]];
			[aTextView setNeedsDisplayInRect : cellFrame];
		}
		return NO;
	}
	
	[self setImage : [self mouseDownImage]];
	[aTextView setNeedsDisplayInRect : cellFrame];
#if 0
	UTILMethodLog;
	UTILDescription(theEvent);
	UTILDescRect(cellFrame);
	UTILDescViewFrame(aTextView);
	UTILDescUnsignedInt(charIndex);
	UTILDescBoolean(flag);
	NSLog(@"");
#endif
	result =  [super trackMouse:theEvent inRect:cellFrame ofView:aTextView atCharacterIndex:charIndex untilMouseUp:flag];
	
	mouseLocation_ = [[aTextView window] mouseLocationOutsideOfEventStream];
	mouseLocation_ = [aTextView convertPoint:mouseLocation_ fromView:nil];
	if ([aTextView mouse:mouseLocation_ inRect:cellFrame])
		[self setImage : [self mouseOverImage]];
	else
		[self setImage : [self defaultImage]];
		
	[aTextView setNeedsDisplayInRect : cellFrame];
	return result;
}
@end



@implementation CMRAttachmentCell(CMRExtetnsions)
- (BOOL) wantsToTrackMouseOver
{
	return ([self mouseOverImage] != nil);
}
@end
