//
//  BSThemeEditor.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/04/22.
//  Copyright 2007-2009 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AppDefaults;

@interface BSThemeEditor : NSWindowController {
//	IBOutlet NSPanel		*m_themeNameSheet;
	IBOutlet NSObjectController *m_themeGreenCube;

	NSString	*m_saveThemeIdentifier;
	id			m_delegate;

	BOOL		m_isNewTheme;
	NSString	*m_fileName;
}

- (id) delegate;
- (void) setDelegate: (id) aDelegate;

//- (NSPanel *) themeNamePanel;
- (NSObjectController *) themeGreenCube;

- (BOOL)isNewTheme;
- (void)setIsNewTheme:(BOOL)flag;
- (NSString *)themeFileName;
- (void)setThemeFileName:(NSString *)filename;

- (IBAction) closePanelAndUseTagForReturnCode: (id) sender;
- (IBAction) saveTheme: (id) sender;

// 「テーマの保存」パネルでテキストフィールドと Binding
- (NSString *) saveThemeIdentifier;
- (void) setSaveThemeIdentifier: (NSString *) aString;

- (IBAction) openHelpForEditingCustomTheme: (id) sender;

- (void) beginSheetModalForWindow: (NSWindow *) window
					modalDelegate: (id) delegate
					  contextInfo: (void *) contextInfo;
@end

@interface NSObject(BSThemeEditorModalDelegate)
- (void) themeEditSheetDidEnd: (NSPanel *) sheet returnCode: (int) returnCode contextInfo: (void *) contextInfo;
- (void) addAndSelectSavedThemeOfTitle: (NSString *) title fileName: (NSString *) fileName;
- (AppDefaults *) preferences;
@end
