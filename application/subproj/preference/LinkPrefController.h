//
//  LinkPrefController.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/11/14.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "PreferencesController.h"


@interface LinkPrefController : PreferencesController {
	IBOutlet NSButton		*m_openPreviewerPrefsButton;
	IBOutlet NSPopUpButton	*m_downloadDestinationChooser;
	IBOutlet NSTextField	*m_previewerNameField;
	IBOutlet NSTextField	*m_previewerIdField;
	IBOutlet NSTableColumn	*m_pathExtensionColumn;
}

- (IBAction)chooseDestination:(id)sender;
- (IBAction)openPreviewerPrefs:(id)sender;

- (NSPopUpButton *)downloadDestinationChooser;
- (NSTextField *)previewerNameField;
- (NSTextField *)previewerIdField;

// Binding
- (int)previewOption;
- (void)setPreviewOption:(int)selectedTag;

- (void)updateFolderButtonUI;
@end
