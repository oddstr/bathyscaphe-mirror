/**
 * $Id: CMRAppDelegate.h,v 1.7.2.4 2006/09/01 13:46:54 masakih Exp $
 * 
 * CMRAppDelegate.h
 *
 * Copyright (c) 2004 Takanori Ishikawa, (c) 2005-2006 tsawada2, All rights reserved.
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
// available in GrafEisen and later.
- (IBAction) closeAll : (id) sender;
- (IBAction) miniaturizeAll : (id) sender;

//- (IBAction) togglePreviewPanel : (id) sender;
- (IBAction) runBoardWarrior: (id) sender;
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

/* Command Support */
- (void) handleOpenURLCommand : (NSScriptCommand *) command;
@end

@interface NSWindow(BSAddition)
- (BOOL) isNotMiniaturizedButCanMinimize;
@end
