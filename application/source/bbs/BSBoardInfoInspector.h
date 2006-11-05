//
//  BSBoardInfoInspector.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/10/08.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
    @class       BSBoardInfoInspector
    @abstract    manage the "Board Info" inspector panel
    @discussion  BSBoardInfoInspector は、「掲示板オプション」（仮称）インスペクタ・パネルのコントローラです。
*/

@interface BSBoardInfoInspector : NSWindowController {
	NSString	*_currentTargetBoardName;

	IBOutlet NSButton		*m_addNoNameBtn;
	IBOutlet NSButton		*m_removeNoNameBtn;
	IBOutlet NSButton		*m_editNoNameBtn;
	//IBOutlet NSButton		*m_detectSettingTxtBtn;
	IBOutlet NSButton		*m_helpButton;
	IBOutlet NSButton		*m_lockButton;
	IBOutlet NSTextField	*m_URLField;
	IBOutlet NSView			*m_namesTable;
	IBOutlet NSArrayController	*m_greenCube;
}

+ (id) sharedInstance;

// Accessor
- (NSString *) currentTargetBoardName;
- (void) setCurrentTargetBoardName : (NSString *) newTarget;

- (NSButton *) helpButton;
- (NSButton *) addNoNameBtn;
- (NSButton *) removeNoNameBtn;
- (NSButton *) editNoNameBtn;
//- (NSButton *) detectSettingTxtBtn;
- (NSButton *) lockButton;
- (NSTextField *) URLField;
- (NSArrayController *) greenCube;

// IBAction
- (IBAction) addNoName : (id) sender;
- (IBAction) editNoName: (id) sender;
//- (IBAction) startDetect: (id) sender;
- (IBAction) openHelpForMe : (id) sender;

// Binding
- (NSMutableArray *) noNamesArray;

- (NSString *) boardURLAsString;
- (BOOL) shouldEnableUI;

- (NSString *) defaultKotehan;
- (void) setDefaultKotehan : (NSString *) fieldValue;

- (NSString *) defaultMail;
- (void) setDefaultMail : (NSString *) fieldValue;

- (BOOL) shouldAlwaysBeLogin;
- (void) setShouldAlwaysBeLogin : (BOOL) checkboxState;

// Availabe in LittleWish and later.
- (BOOL) shouldAllThreadsAAThread;
- (void) setShouldAllThreadsAAThread : (BOOL) checkboxState;

- (NSImage *) icon;
- (BOOL) shouldEnableBeBtn;

// method
- (void) showInspectorForTargetBoard : (NSString *) boardName;
- (IBAction) toggleAllowEditingBoardURL: (id) sender;

- (void) mainWindowChanged : (NSNotification *) theNotification;
- (void) browserBoardChanged : (NSNotification *) theNotification;
- (void) viewerThreadChanged : (NSNotification *) theNotification;
@end
