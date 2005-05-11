/**
  * $Id: CMRAttachmentCell.h,v 1.1.1.1 2005/05/11 17:51:04 tsawada2 Exp $
  * 
  * CMRAttachmentCell.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Cocoa/Cocoa.h>


@interface NSTextAttachmentCell(CMRExtetnsions)
- (BOOL) wantsToTrackMouseOver;
@end



@interface CMRAttachmentCell : NSTextAttachmentCell
{
	@private
	NSImage		*_defaultImage;
	NSImage		*_mouseOverImage;
	NSImage		*_mouseDownImage;
	
}
- (NSImage *) mouseOverImage;
- (NSImage *) mouseDownImage;
- (void) setMouseOverImage : (NSImage *) aMouseOverImage;
- (void) setMouseDownImage : (NSImage *) aMouseDownImage;

@end
