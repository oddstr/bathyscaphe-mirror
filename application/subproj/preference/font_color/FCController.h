/**
  * $Id: FCController.h,v 1.11 2007/04/22 15:51:30 tsawada2 Exp $
  * 
  * FCController.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>
#import "PreferencesController.h"

@class BSThemeEditor;

@interface FCController : PreferencesController
{	
	IBOutlet NSPopUpButton	*m_themesChooser;
	BSThemeEditor			*m_themeEditor;
}

- (NSPopUpButton *) themesChooser;
- (BSThemeEditor *) themeEditor;

- (IBAction) fixRowHeightToFont : (id) sender;
- (IBAction) fixRowHeightToFontOfBoardList : (id) sender;

- (IBAction) chooseDefaultTheme: (id) sender;
- (IBAction) chooseTheme: (id) sender;
- (IBAction) editCustomTheme: (id) sender;

// Private
- (void) deleteTheme: (NSString *) fileName;
- (void) tryDeleteTheme: (id) sender;
- (void) addMenuItemOfTitle: (NSString *) identifier representedObject: (NSString *) filepath atIndex: (unsigned int) index;
@end
