//
//  $Id: BSIPIImageView.m,v 1.2 2006/04/11 17:31:21 masakih Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/07.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSIPIImageView.h"
#import "BSImagePreviewInspector.h"

@implementation BSIPIImageView
- (void) mouseDown : (NSEvent *) theEvent
{
	if ([self image] != nil) {
		BSImagePreviewInspector *tmp_ = [[self window] windowController];
		NSString				*path_ = [tmp_ downloadedFileDestination];
		NSPoint					event_location = [theEvent locationInWindow];
		NSPoint					local_point = [self convertPoint:event_location fromView:nil];

		if(path_)
			[self dragFile : path_
				  fromRect : NSMakeRect(local_point.x-16, local_point.y-16, 32, 32)
				 slideBack : YES
					 event : theEvent];
	} else {
		[super mouseDown : theEvent];
	}
}

// キーウインドウにしなくてもドラッグを開始できるように
- (BOOL) acceptsFirstMouse : (NSEvent *) theEvent
{
	return([self image] != nil);
}
@end
