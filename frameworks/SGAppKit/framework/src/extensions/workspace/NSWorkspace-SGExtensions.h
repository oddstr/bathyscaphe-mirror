//: NSWorkspace-SGExtensions.h
/**
  * $Id: NSWorkspace-SGExtensions.h,v 1.1.1.1 2005/05/11 17:51:27 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <AppKit/NSWorkspace.h>


@interface NSWorkspace(SGExtensionsFileOperation)
- (BOOL) moveFilesToTrash : (NSArray *) filePaths;
- (BOOL) _openURLsInBackGround : (NSArray *) URLsArray;
- (BOOL) openURL : (NSURL *) url_ inBackGround : (BOOL) inBG;
@end
