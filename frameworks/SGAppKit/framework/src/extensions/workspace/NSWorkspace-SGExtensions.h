//: NSWorkspace-SGExtensions.h
/**
  * $Id: NSWorkspace-SGExtensions.h,v 1.1.1.1.8.2 2006/11/28 13:29:47 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>
#import <AppKit/NSWorkspace.h>


@interface NSWorkspace(SGExtensionsFileOperation)
- (BOOL) moveFilesToTrash : (NSArray *) filePaths;
- (BOOL) openURL : (NSURL *) url_ inBackGround : (BOOL) inBG;
@end

@interface NSWorkspace(BSIconServicesUtil)
- (NSImage *) systemIconForType: (OSType) iconType;
@end

@interface NSWorkspace(BSDefaultWebBrowserUtils)
- (NSString *) absolutePathForDefaultWebBrowser;
- (NSImage *) iconForDefaultWebBrowser;
- (NSString *) bundleIdentifierForDefaultWebBrowser;
@end
