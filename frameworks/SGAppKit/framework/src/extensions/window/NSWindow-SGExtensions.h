//
//  NSWindow-SGExtensions.h
//  BathyScaphe
//
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/NSWindow.h>

// Moved from CMRAppDelegate.h
// Available in SGAppKit 1.6.7 and later.
@interface NSWindow(BSAddition)
- (BOOL) isNotMiniaturizedButCanMinimize;
@end

