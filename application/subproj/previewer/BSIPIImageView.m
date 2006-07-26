//
//  $Id: BSIPIImageView.m,v 1.3 2006/07/26 16:28:25 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/07.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSIPIImageView.h"
#import "BSImagePreviewInspector.h"
#import "BSIPIHistoryManager.h"

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

- (NSImage *) makeDragImage
{
	NSImage *dragImage_ = [[NSImage alloc] init];
	NSImage *baseImage_ = [[self image] copy];
	NSSize	dragImageSize = NSInsetRect([self bounds], 7.0, 8.0).size;
	float initX, initY, dragImgX, dragImgY;
	NSImageRep	*baseImageRep_ = [baseImage_ bestRepresentationForDevice: nil];

	initX = [baseImageRep_ pixelsWide];
	initY = [baseImageRep_ pixelsHigh];

	dragImgY = dragImageSize.height;
	dragImgX = dragImgY * initX / initY;
	
	[baseImageRep_ setSize: NSMakeSize(dragImgX, dragImgY)];
	
	[dragImage_ setSize: dragImageSize];

	[dragImage_ lockFocus];
	[baseImage_ dissolveToPoint: NSZeroPoint fraction: 0.75];
	[dragImage_ unlockFocus];

	[baseImage_ release];
	
	return [dragImage_ autorelease];
}

- (void) mouseDown : (NSEvent *) theEvent
{
	if ([self image] != nil && [[self delegate] respondsToSelector: @selector(imageView:writeSomethingToPasteboard:)]) {
		NSPoint			event_location = [theEvent locationInWindow];
		NSPoint			local_point = [self convertPoint: event_location fromView: nil];
		NSPasteboard	*pboard = [NSPasteboard pasteboardWithName: NSDragPboard];

		if ([[self delegate] imageView: self writeSomethingToPasteboard: pboard]) {
			NSImage *dragImage_ = [self makeDragImage];
			NSSize	dragImgSize = [dragImage_ size];

			local_point.x = local_point.x - dragImgSize.width / 2;
			local_point.y = local_point.y - dragImgSize.height / 2;
			
			[self dragImage: dragImage_
						 at: local_point
					 offset: NSZeroSize
					  event: theEvent
				 pasteboard: pboard
					 source: self
				  slideBack: YES];
		}
		
		return;
	}

	[super mouseDown : theEvent];
}
// キーウインドウにしなくてもドラッグを開始できるように
- (BOOL) acceptsFirstMouse : (NSEvent *) theEvent
{
	return([self image] != nil);
}
@end
