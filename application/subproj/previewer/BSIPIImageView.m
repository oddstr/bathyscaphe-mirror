//
//  $Id: BSIPIImageView.m,v 1.3.2.1 2006/08/31 10:18:41 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/07.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSIPIImageView.h"

@implementation BSIPIImageView
- (id) delegate
{
	return bsIPIImageView_delegate;
}

- (void) setDelegate: (id) aDelegate
{
	bsIPIImageView_delegate = aDelegate;
}

- (void) dealloc
{
	[self setDelegate: nil];
	[super dealloc];
}

#pragma mark Drag and Drop
- (NSSize)fitSizeForDragging
{
	NSSize targetSize = [self frame].size;
	NSSize originalSize = [[self image] size];
	
 /* フレームサイズより小さい方がいいかも。*/
	targetSize.width -= 5;
	targetSize.height -= 5;
 
	float dx, dy;
	dx = targetSize.width / originalSize.width;
	dy = targetSize.height / originalSize.height;
	if(dx > dy) {
		dx = dy;
	} else {
		dy = dx;
	}
	// オリジナルより大きくしない。
	if(dx > 1) {
		dx = dy = 1;
	}
	
	return NSMakeSize(originalSize.width * dx, originalSize.height * dy);
}

/* サイズ調整された、半透明画像 */
- (NSImage *)imageForDragging
{
	NSImage *image = [[[NSImage alloc] initWithSize:[[self image] size]] autorelease];
	[image lockFocus];
	[[self image] drawAtPoint:NSZeroPoint
					 fromRect:NSZeroRect
					operation:NSCompositeCopy
					 fraction:0.7];//0.5];
	[image unlockFocus];
	
	[image setScalesWhenResized:YES];
	[image setSize:[self fitSizeForDragging]];
	
	return image;
}

/* マウスが四方に delta 移動するまでドラッグを開始しない */
- (void) dragImageFileWithEvent: (NSEvent *)theEvent
//- (void) dragImageFile:(NSString *)path event:(NSEvent *)theEvent
{
	NSRect koreguraiHaNotDragRect;
	NSPoint clickPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	const float delta = 5;
	
	koreguraiHaNotDragRect = NSMakeRect( clickPoint.x - delta / 2.0, clickPoint.y - delta / 2.0, delta, delta );
	
	while( YES ) {
		NSPoint mouse;
		theEvent = [NSApp nextEventMatchingMask:NSLeftMouseUpMask | NSLeftMouseDraggedMask
									  untilDate:[NSDate distantFuture]
										 inMode:NSEventTrackingRunLoopMode
										dequeue:YES];
		if( [theEvent type] == NSLeftMouseUp ) break;
		
		mouse = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		if( !NSMouseInRect( mouse, koreguraiHaNotDragRect, [self isFlipped] ) ) {
			NSImage *image;
			NSPoint imageLoc;
			NSPasteboard *pb;
			NSSize offset;
			
			pb = [NSPasteboard pasteboardWithName:NSDragPboard];
			/*[pb declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType] owner:self];
			[pb setPropertyList:[NSArray arrayWithObject:path]
						forType:NSFilenamesPboardType];
			*/
			[[self delegate] imageView: self writeSomethingToPasteboard: pb];
			
			image = [self imageForDragging];
			
			imageLoc = mouse;
			imageLoc.x -= [image size].width * 0.5;
			imageLoc.y -= [image size].height * 0.5 * ([self isFlipped] ? -1 : 1);
			
			offset = NSMakeSize( mouse.x - clickPoint.x, mouse.y - clickPoint.y );
			
			[self dragImage:image
						 at:imageLoc
					 offset:offset
					  event:theEvent
				 pasteboard:pb
					 source:self
				  slideBack:YES];
			
			break;
		}
	}
}
		
- (void) mouseDown : (NSEvent *) theEvent
{
//	if ([self image] != nil) {
//		BSImagePreviewInspector *tmp_ = [[self window] windowController];
//		NSString				*path_ = [tmp_ downloadedFileDestination];
//		NSPoint					event_location = [theEvent locationInWindow];
//		NSPoint					local_point = [self convertPoint:event_location fromView:nil];
//
//		if(path_)
//			[self dragFile : path_
//				  fromRect : NSMakeRect(local_point.x-16, local_point.y-16, 32, 32)
//				 slideBack : YES
//					 event : theEvent];
	if ([self image] != nil && [[self delegate] respondsToSelector: @selector(imageView:writeSomethingToPasteboard:)]) {
//		if(path_) {
//			[self dragImageFile:path_ event:theEvent];
//		}
        [self dragImageFileWithEvent: theEvent];
	} else {
		[super mouseDown : theEvent];
	}
}

// キーウインドウにしなくてもドラッグを開始できるように
- (BOOL) acceptsFirstMouse : (NSEvent *) theEvent
{
	return([self image] != nil);
}

#pragma mark Perform Key Equivalent
- (BOOL) needsPanelToBecomeKey
{
	return YES;
}

- (BOOL) acceptsFirstResponder
{
	return YES;
}

// 少しだけ丸みを帯びた四角形
- (NSBezierPath *) calcRoundedRectForRect: (NSRect) bgRect
{
    int minX = NSMinX(bgRect);
    int midX = NSMidX(bgRect);
    int maxX = NSMaxX(bgRect);
    int minY = NSMinY(bgRect);
    int midY = NSMidY(bgRect);
    int maxY = NSMaxY(bgRect);
    float radius = 4.5; // 試行錯誤の末の値
    NSBezierPath *bgPath = [NSBezierPath bezierPath];
    
    // Bottom edge and bottom-right curve
    [bgPath moveToPoint:NSMakePoint(midX, minY)];
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY) 
                                     toPoint:NSMakePoint(maxX, midY) 
                                      radius:radius];
    
    // Right edge and top-right curve
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, maxY) 
                                     toPoint:NSMakePoint(midX, maxY) 
                                      radius:radius];
    
    // Top edge and top-left curve
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY) 
                                     toPoint:NSMakePoint(minX, midY) 
                                      radius:radius];
    
    // Left edge and bottom-left curve
    [bgPath appendBezierPathWithArcFromPoint:bgRect.origin 
                                     toPoint:NSMakePoint(midX, minY) 
                                      radius:radius];
    [bgPath closePath];
    
    return bgPath;
}

- (void) drawRect: (NSRect) aRect
{
	[super drawRect: aRect];
	if (([[self window] firstResponder] == self) && [[self window] isKeyWindow]) {
		//NSSetFocusRingStyle(NSFocusRingOnly);
		//NSRectFill(aRect);
	[NSGraphicsContext saveGraphicsState];
	NSSetFocusRingStyle(NSFocusRingOnly);
	//[NSBezierPath setDefaultLineJoinStyle: NSRoundLineJoinStyle];
	[[self calcRoundedRectForRect: aRect] fill];
	[NSGraphicsContext restoreGraphicsState];

	}
}

- (BOOL) performKeyEquivalent: (NSEvent *) theEvent
{
	if([self delegate] && [[self delegate] respondsToSelector: @selector(imageView:shouldPerformKeyEquivalent:)]) {
		return [[self delegate] imageView: self shouldPerformKeyEquivalent: theEvent];
	}

	return [super performKeyEquivalent: theEvent];
}
@end
