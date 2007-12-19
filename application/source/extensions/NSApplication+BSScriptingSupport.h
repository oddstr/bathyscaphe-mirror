//
//  NSApplication+BSScriptingSupport.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/12/15.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
    @header NSApplication+BSScriptingSupport
    @abstract   NSApplication category for AppleScript scripting support
    @discussion NSApplication category for AppleScript scripting support.
				Separated from CMRAppDelegate.m.
*/

@interface NSApplication(BSScriptingSupport)
- (BOOL)isOnlineMode;
- (void)setIsOnlineMode:(BOOL)flag;

- (NSArray *)browserTableViewColor;
- (void)setBrowserTableViewColor:(NSArray *)array;
- (NSArray *)boardListColor;
- (void)setBoardListColor:(NSArray *)array;
- (NSArray *)boardListNonActiveColor;
- (void)setBoardListNonActiveColor:(NSArray *)array;

- (void)handleOpenURLCommand:(NSScriptCommand *)command;
- (void)handleRemoveFromDBCommand:(NSScriptCommand *)command;
@end
