/**
  * $Id: FCController.h,v 1.12 2009/01/11 15:15:34 tsawada2 Exp $
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
	IBOutlet NSPopUpButton	*m_themesChooser;
	IBOutlet NSTableView	*m_themesList;
	IBOutlet BSThemePreView *m_preView;
	BSThemeEditor			*m_themeEditor;
}

- (NSPopUpButton *) themesChooser;
- (NSTableView *)themesList;
- (BSThemeEditor *) themeEditor;

- (IBAction) fixRowHeightToFont : (id) sender;
- (IBAction) fixRowHeightToFontOfBoardList : (id) sender;

- (IBAction) chooseDefaultTheme: (id) sender;
- (IBAction) chooseTheme: (id) sender;
- (IBAction) editCustomTheme: (id) sender;

- (IBAction)newTheme:(id)sender;

// Private
- (void) deleteTheme: (NSString *) fileName;
- (IBAction)tryDeleteTheme:(id)sender;
- (void) addMenuItemOfTitle: (NSString *) identifier representedObject: (NSString *) filepath atIndex: (unsigned int) index;
@end
