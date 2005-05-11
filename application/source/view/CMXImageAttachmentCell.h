//: CMXImageAttachmentCell.h
/**
  * $Id: CMXImageAttachmentCell.h,v 1.1.1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Cocoa/Cocoa.h>


/*!
 * @class       CMXImageAttachmentCell
 * @discussion  メールアイコン
 */

@interface CMXImageAttachmentCell : NSTextAttachmentCell
{
	@private
	NSImageAlignment _imageAlignment;
}
- (NSImageAlignment) imageAlignment;
- (void) setImageAlignment : (NSImageAlignment) anImageAlignment;
@end
