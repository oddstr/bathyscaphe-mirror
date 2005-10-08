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

	IBOutlet NSButton		*m_changeKotehanBtn;
	IBOutlet NSButton		*m_helpButton;
	IBOutlet NSTextField	*m_nanashiField;
}

+ (id) sharedInstance;

// Accessor
- (NSString *) currentTargetBoardName;
- (void) setCurrentTargetBoardName : (NSString *) newTarget;

- (NSButton *) helpButton;
- (NSButton *) changeKotehanBtn;
- (NSTextField *) nanashiField;

// IBAction
- (IBAction) changeDefaultNanashi : (id) sender;
- (IBAction) openHelpForMe : (id) sender;

// Binding
- (NSString *) defaultNanashi;

- (NSString *) defaultKotehan;
- (void) setDefaultKotehan : (NSString *) fieldValue;

- (NSString *) defaultMail;
- (void) setDefaultMail : (NSString *) fieldValue;

- (BOOL) shouldAlwaysBeLogin;
- (void) setShouldAlwaysBeLogin : (BOOL) checkboxState;

// method
- (void) showInspectorForTargetBoard : (NSString *) boardName;

- (void) mainWindowChanged : (NSNotification *) theNotification;
- (void) browserBoardChanged : (NSNotification *) theNotification;
- (void) windowWillCloseNow : (NSNotification *) theNotification;
@end
