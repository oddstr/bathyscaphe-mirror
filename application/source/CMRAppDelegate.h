/**
 * $Id: CMRAppDelegate.h,v 1.4 2005/05/31 13:48:38 tsawada2 Exp $
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
	IBOutlet	NSMenu	*fileMenu;
    @private
    NSMutableArray *_queue;
    BOOL _launchingFinished;
}
- (IBAction) showBoardListEditor : (id) sender;
- (IBAction) showPreferencesPane : (id) sender;
- (IBAction) showStandardFindPanel : (id) sender;
- (IBAction) toggleOnlineMode : (id) sender;

- (IBAction) showTaskInfoPanel : (id) sender;
- (IBAction) openURL : (id) sender;
- (IBAction) resetApplication : (id) sender;

- (IBAction) orderFrontCustomAboutPanel: (id) sender;

- (IBAction) openURLPanel : (id) sender;
- (IBAction) launchCMLF : (id) sender;
@end

@interface NSApplication(ScriptingSupport)
/* Property Support (Key-Value coding) */
- (BOOL) isOnlineMode;
- (void) setIsOnlineMode : (BOOL) flag;

/* Who needs these stupid properties... Huh! */
- (NSArray *) browserTableViewColor;
- (void) setBrowserTableViewColor : (NSArray *) colorValue;

/* Command Support */
- (void) handleOpenURLCommand : (NSScriptCommand *) command;
@end
