/**
 * $Id: CMRAppDelegate.h,v 1.18 2007/07/21 19:32:55 tsawada2 Exp $
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
	@private
	BOOL	m_shouldCascadeBrowserWindow;
	NSString *m_threadPath;
}

- (BOOL) shouldCascadeBrowserWindow;
- (void) setShouldCascadeBrowserWindow: (BOOL) flag;

- (IBAction) showPreferencesPane : (id) sender;
- (IBAction) showStandardFindPanel : (id) sender;
- (IBAction) toggleOnlineMode : (id) sender;

- (IBAction) showTaskInfoPanel : (id) sender;
- (IBAction) openURL : (id) sender;
- (IBAction) resetApplication : (id) sender;

- (IBAction) openURLPanel : (id) sender;
//- (IBAction) launchCMLF : (id) sender;

// For History Menu
- (IBAction) clearHistory : (id) sender;
- (IBAction) showThreadFromHistoryMenu: (id) sender;

- (IBAction) showAcknowledgment : (id) sender;

// Available in GrafEisen and later.
- (IBAction) closeAll : (id) sender;
- (IBAction) miniaturizeAll : (id) sender;

- (IBAction) togglePreviewPanel : (id) sender;
- (IBAction) runBoardWarrior: (id) sender;

// Available in Starlight Breaker.
- (void) showThreadsListForBoard: (NSString *) boardName selectThread: (NSString *) path addToListIfNeeded: (BOOL) addToList;
- (IBAction) checkForUpdate: (id) sender;

// For Dock menu
- (IBAction) startHEADCheckDirectly: (id) sender;
@end
