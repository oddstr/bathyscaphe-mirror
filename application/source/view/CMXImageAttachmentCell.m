//: CMXImageAttachmentCell.m
/**
  * $Id: CMXImageAttachmentCell.m,v 1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "CMXImageAttachmentCell.h"
#import "UTILKit.h"


@implementation CMXImageAttachmentCell
- (id) initImageCell : (NSImage *) anImage
{
	if(self = [super initImageCell : anImage]){
		;
	}
	return self;
}
- (NSImageAlignment) imageAlignment
{
	return _imageAlignment;
}
- (void) setImageAlignment : (NSImageAlignment) anImageAlignment
{
	_imageAlignment = anImageAlignment;
}


- (NSSize) cellSize
{
	NSSize	cellSize_ = [super cellSize];
	
	return cellSize_;
}
- (NSPoint) cellBaselineOffset
{
	NSPoint	cellBaselineOffset_;
	
	cellBaselineOffset_ = [super cellBaselineOffset];
/*
	
	cellBaselineOffset_.y -= 5;
	
*/
	return cellBaselineOffset_;
	
}
- (NSRect) cellFrameForTextContainer : (NSTextContainer *) textContainer
                proposedLineFragment : (NSRect           ) lineFrag
				       glyphPosition : (NSPoint          ) position
					  characterIndex : (unsigned         ) charIndex
{
	NSRect		cellFrame_;
	NSSize		cellSize_;
	float		yOffset_;
	
	cellSize_ = [self cellSize];
	cellFrame_ = [super cellFrameForTextContainer : textContainer
                proposedLineFragment : lineFrag
				       glyphPosition : position
					  characterIndex : charIndex];
	
	yOffset_ = NSHeight(lineFrag) - cellSize_.height;
	
	switch([self imageAlignment]){
	case NSImageAlignCenter :
		yOffset_ /= 2;
		break;
	case NSImageAlignTop :
	case NSImageAlignTopLeft :
	case NSImageAlignTopRight :
		yOffset_ = 0;
		break;
	case NSImageAlignBottom :
	case NSImageAlignBottomLeft :
	case NSImageAlignBottomRight :
		if(yOffset_ > 0)
			yOffset_ = 0;
		break;
	case NSImageAlignLeft :
	case NSImageAlignRight :
	default :
		yOffset_ = 0;
		break;
	}
	
	cellFrame_.origin.y += yOffset_;
	
	return cellFrame_;
}
@end
