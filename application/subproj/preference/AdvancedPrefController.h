//
//  AdvancedPrefController.h
//  BachyScaphe
//
//  Created by tsawada2 on 05/05/22.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "PreferencesController.h"

@interface AdvancedPrefController : PreferencesController {
	IBOutlet NSButton		*m_openSheetBtn;	
	IBOutlet NSPopUpButton	*m_dlFolderBtn;
	IBOutlet NSPanel		*m_extensionsEditor;
}

- (IBAction)openSheet:(id)sender;
- (IBAction)closeSheet:(id)sender;
- (IBAction)chooseDestination:(id)sender;

- (NSPanel *)extensionsEditor;
- (NSButton *)openSheetBtn;
- (NSPopUpButton *)dlFolderBtn;

// Binding
- (int)previewOption;
- (void)setPreviewOption:(int)selectedTag;

- (void)updateFolderButtonUI;
@end
