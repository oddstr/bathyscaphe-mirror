//: NSPasteboard-SGExtensions.h
/**
  * $Id: NSPasteboard-SGExtensions.h,v 1.2 2007/10/25 13:41:43 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Cocoa/Cocoa.h>

/*
@interface NSPasteboard(SGExtensionsObjectValue)
- (id) unarchivedObjectForType : (NSString *) dataType;
- (BOOL) setObjectByArchived : (id		  ) obj
					 forType : (NSString *) dataType;
- (void *) pointerForType : (NSString *) dataType;
- (BOOL) setPointer : (const void *) aPointer
			forType : (NSString   *) dataType;
@end
*/


@interface NSAttributedString(CMXAdditions)
- (void) writeToPasteboard : (NSPasteboard *) pboard;
@end
