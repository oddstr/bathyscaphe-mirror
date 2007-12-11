//
//  BSBoardInfoInspector.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/10/08.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>

/*!
    @class       BSBoardInfoInspector
    @abstract    manage the "Board Info" inspector panel
    @discussion  BSBoardInfoInspector は、「掲示板オプション」（仮称）インスペクタ・パネルのコントローラです。
*/
@class BoardListItem;

@interface BSBoardInfoInspector : NSWindowController {
	NSString	*m_currentTargetBoardName;
	BOOL		m_isDetecting;

	IBOutlet NSButton		*m_addNoNameBtn;
	IBOutlet NSButton		*m_removeNoNameBtn;
	IBOutlet NSButton		*m_editBoardURLButton;
}

+ (id)sharedInstance;

- (void)showInspectorForTargetBoard:(NSString *)boardName;

// Accessor
- (NSString *)currentTargetBoardName;
- (void)setCurrentTargetBoardName:(NSString *)newTarget;

- (NSButton *)addNoNameBtn;
- (NSButton *)removeNoNameBtn;
- (NSButton *)editBoardURLButton;

// IBAction
- (IBAction)addNoName:(id)sender;
- (IBAction)startDetect:(id)sender;
- (IBAction)editBoardURL:(id)sender;
- (IBAction)openHelpForMe:(id)sender;

// Binding
- (NSMutableArray *)noNamesArray;
- (void)setNoNamesArray:(NSMutableArray *)anArray;

- (NSString *)boardURLAsString;
- (BOOL)shouldEnableUI;
- (BOOL)shouldEnableBeBtn;
- (BOOL)shouldEnableURLEditing;

- (NSString *)defaultKotehan;
- (void)setDefaultKotehan:(NSString *)fieldValue;

- (NSString *)defaultMail;
- (void)setDefaultMail:(NSString *)fieldValue;

- (BOOL)shouldAlwaysBeLogin;
- (void)setShouldAlwaysBeLogin:(BOOL)checkboxState;

- (BOOL)shouldAllThreadsAAThread;
- (void)setShouldAllThreadsAAThread:(BOOL)checkboxState;

- (BoardListItem *)boardListItem;

- (int)nanashiAllowed;

- (BOOL)isDetecting;
- (void)setIsDetecting:(BOOL)flag;

// Notification
- (void) mainWindowChanged : (NSNotification *) theNotification;
- (void) browserBoardChanged : (NSNotification *) theNotification;
- (void) viewerThreadChanged : (NSNotification *) theNotification;
@end
