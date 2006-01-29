/**
 * $Id: CMRAppDelegate.h,v 1.7.2.2 2006/01/29 12:58:10 masakih Exp $
 * 
 * CMRAppDelegate.h
 *
 * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
 * See the file LICENSE for copying permission.
 */

#import <Cocoa/Cocoa.h>


/*!
 * @class       CMRAppDelegate
 * @abstract    NSApplication delegate, 
                application scope action holder.
 * @discussion  
 */
@interface CMRAppDelegate : NSObject
{
    @private
    NSMutableArray *_queue;
    BOOL _launchingFinished;
}
- (IBAction) showPreferencesPane : (id) sender;
- (IBAction) showStandardFindPanel : (id) sender;
- (IBAction) toggleOnlineMode : (id) sender;

- (IBAction) showTaskInfoPanel : (id) sender;
- (IBAction) openURL : (id) sender;
- (IBAction) resetApplication : (id) sender;

- (IBAction) openURLPanel : (id) sender;
- (IBAction) launchCMLF : (id) sender;

- (IBAction) clearHistory : (id) sender;
- (IBAction) showAcknowledgment : (id) sender;
@end

@interface NSApplication(ScriptingSupport)
/* Property Support (Key-Value coding) */
- (BOOL) isOnlineMode;
- (void) setIsOnlineMode : (BOOL) flag;

/* Who needs these stupid properties... Huh! */
- (NSArray *) browserTableViewColor;
- (void) setBrowserTableViewColor : (NSArray *) colorValue;

- (NSArray *) boardListColor;
- (void) setBoardListColor : (NSArray *) colorValue;

/* Vita Additions */
- (NSString *) searchIgnoreChars;
- (void) setSearchIgnoreChars : (NSString *) someString;

- (BOOL) ignoreSpecificCharsOnSearch;
- (void) setIgnoreSpecificCharsOnSearch : (BOOL) flag;

/* Command Support */
- (void) handleOpenURLCommand : (NSScriptCommand *) command;
@end
