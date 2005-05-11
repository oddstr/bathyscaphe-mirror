//: NSTextView+CMXAdditions.h
/**
  * $Id: NSTextView+CMXAdditions.h,v 1.1.1.1 2005/05/11 17:51:05 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Cocoa/Cocoa.h>



@interface NSTextView(CMXAppAdditions)
- (NSRect) boundingRectForCharacterInRange : (NSRange) aRange;
- (NSRange) characterRangeForDocumentVisibleRect;
@end
