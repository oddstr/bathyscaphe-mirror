//
//  NSWorkspace-SGExtensions.h
//  BathyScaphe (SGAppKit)
//
//  Updated by Tsutomu Sawada on 07/10/25.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>


@interface NSWorkspace(BSExtensions)
// Tell Finder to move files to Trash - AppleEvent Wrapper
- (BOOL)moveFilesToTrash:(NSArray *)filePaths;

// Tell Finder to reveal files - AppleEvent Wrapper
- (BOOL)revealFilesInFinder:(NSArray *)filePaths; // Available in BathyScaphe 1.6.2 and later.
// Activate Application - AppleEvent Wrapper
// NOTE: This method does nothing if the target application is not running (unlike AppleScript's "tell application Foo to activate".)
- (BOOL)activateAppWithBundleIdentifier:(NSString *)bundleIdentifier; // Available in BathyScaphe 1.6.2 and later.

- (BOOL)attachComment:(NSString *)comment toFile:(NSString *)filePath; // Available in BathyScaphe 1.6.2 and later.

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
