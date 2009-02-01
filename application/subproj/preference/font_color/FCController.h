/**
  * $Id: FCController.h,v 1.13 2009/02/01 13:46:07 tsawada2 Exp $
  * 
  * FCController.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>
#import "PreferencesController.h"

@class BSThemeEditor, BSThemePreView;

@interface FCController : PreferencesController
{	
	IBOutlet NSTableView	*m_themesList;
	IBOutlet BSThemePreView *m_preView;
	BSThemeEditor			*m_themeEditor;

	IBOutlet NSTextField	*m_themeNameField;
	IBOutlet NSTextField	*m_themeStatusField;
	IBOutlet NSButton		*m_deleteBtn;
}

- (NSTableView *)themesList;
- (BSThemeEditor *)themeEditor;
- (BSThemePreView *)preView;
- (NSTextField *)themeNameField;
- (NSTextField *)themeStatusField;
- (NSButton *)deleteButton;

- (IBAction) fixRowHeightToFont : (id) sender;
- (IBAction) fixRowHeightToFontOfBoardList : (id) sender;

//- (IBAction) chooseDefaultTheme: (id) sender;
//- (IBAction) chooseTheme: (id) sender;
- (IBAction) editCustomTheme: (id) sender;

- (IBAction)newTheme:(id)sender;
// Vita Additions
- (int) mailFieldOption;
- (void) setMailFieldOption : (int) selectedTag;

// Private
- (void) deleteTheme: (NSString *) fileName;
- (IBAction)tryDeleteTheme:(id)sender;
//- (void) addMenuItemOfTitle: (NSString *) identifier representedObject: (NSString *) filepath atIndex: (unsigned int) index;
@end
