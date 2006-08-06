//
//  SyncPaneController.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/28.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesController.h"

@interface SyncPaneController : PreferencesController {
	IBOutlet NSButton				*m_startBtn;
	IBOutlet NSTextField			*m_statusField;
	IBOutlet NSProgressIndicator	*m_statusBar;
	IBOutlet NSTextField			*m_statusTitle;
	IBOutlet NSComboBox				*m_comboBox;
	IBOutlet NSImageView			*m_statusIconView;
}

- (NSButton *) startBtn;
- (NSTextField *) statusField;
- (NSProgressIndicator *) statusBar;
- (NSTextField *) statusTitle;
- (NSComboBox *) comboBox;
- (NSImageView *) statusIconView;

- (IBAction) startSync: (id) sender;

- (IBAction) comboBoxDidEndEditing: (id) sender;
@end
