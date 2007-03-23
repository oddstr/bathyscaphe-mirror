/**
  * $Id: FCController.h,v 1.9 2007/03/23 17:27:52 tsawada2 Exp $
  * 
  * FCController.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>
#import "PreferencesController.h"



@interface FCController : PreferencesController
{	
	IBOutlet NSPopUpButton	*m_themesChooser;
	IBOutlet NSPanel		*m_themeEditSheet;
	IBOutlet NSPanel		*m_themeNameSheet;
	IBOutlet NSObjectController *m_themeGreenCube;

	NSString	*m_saveThemeIdentifier;
}

- (IBAction) fixRowHeightToFont : (id) sender;
- (IBAction) fixRowHeightToFontOfBoardList : (id) sender;

- (IBAction) chooseDefaultTheme: (id) sender;
- (IBAction) chooseTheme: (id) sender;
- (IBAction) editCustomTheme: (id) sender;
- (IBAction) closePanelAndUseTagForReturnCode: (id) sender;
- (IBAction) saveTheme: (id) sender;

// 「テーマの保存」パネルでテキストフィールドと Binding
- (NSString *) saveThemeIdentifier;
- (void) setSaveThemeIdentifier: (NSString *) aString;
@end
