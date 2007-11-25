//
//  SyncPaneController.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/28.
//  Copyright 2006-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>
#import "PreferencesController.h"

@interface SyncPaneController : PreferencesController {
	IBOutlet NSComboBox				*m_comboBox;
	IBOutlet NSImageView			*m_statusIconView;
}

- (NSComboBox *)comboBox;
- (NSImageView *)statusIconView;

- (IBAction)startSync:(id)sender;
- (IBAction)comboBoxDidEndEditing:(id)sender;
- (IBAction)openLogFile:(id)sender;
@end
