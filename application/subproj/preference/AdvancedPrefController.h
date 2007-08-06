//
//  $Id: AdvancedPrefController.h,v 1.10 2007/08/06 19:08:14 tsawada2 Exp $
//  BachyScaphe
//
//  Created by tsawada2 on 05/05/22.
//  Copyright 2005-2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>
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

- (void)updateHelperAppUI;
@end
