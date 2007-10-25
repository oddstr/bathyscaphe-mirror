//
//  NSWorkspace-SGExtensions.h
//  BathyScaphe (SGAppKit)
//
//  Updated by Tsutomu Sawada on 07/10/25.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>


@interface NSWorkspace(BSExtensions)
// Tell Finder to move files to Trash - AppleEvent Wrapper
- (BOOL)moveFilesToTrash:(NSArray *)filePaths;

// Deprecated. Use -openURL:inBackground: instead.
- (BOOL)openURL:(NSURL *)url_ inBackGround:(BOOL)inBG;

// Open URL(s) with or without activating default Web browser. 
- (BOOL)openURL:(NSURL *)url inBackground:(BOOL)flag;
- (BOOL)openURLs:(NSArray *)urls inBackground:(BOOL)flag;

// Icon Services Wrapper
- (NSImage *)systemIconForType:(OSType)iconType;

// Utilities for Default Web Browser
- (NSString *)absolutePathForDefaultWebBrowser;
- (NSImage *)iconForDefaultWebBrowser;
- (NSString *)bundleIdentifierForDefaultWebBrowser;
@end
